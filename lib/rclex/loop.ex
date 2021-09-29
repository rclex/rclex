defmodule Rclex.Loop do
    alias Rclex.Nifs
    require Rclex.Macros
    require Logger
    use GenServer, restart: :transient

    def start_link({sub_id, sub, context, call_back}) do
        Logger.debug("loop link start")
        GenServer.start_link(__MODULE__, {sub_id, sub, context, call_back})
    end

    def init({sub_id, sub, context, call_back}) do
        wait_set = Nifs.rcl_get_zero_initialized_wait_set()
        |> Nifs.rcl_wait_set_init(
            1,
            0,
            0,
            0,
            0,
            0,
            context,
            Nifs.rcl_get_default_allocator()
        )
        Logger.debug("init")
        GenServer.cast(self(), {:loop})
        Logger.debug("loop start")
        {:ok, {sub_id, wait_set, sub, call_back}}
    end

    def start_sub(id_list) do
        id_list
        |> Enum.map(fn pid -> GenServer.cast(pid, {:loop}) end)
    end

    @doc """
        購読処理関数
        購読が正常に行われれば，引数に受け取っていたコールバック関数を実行
    """
    def each_subscribe(sub, call_back, sub_id) do
        #Logger.debug("each subscribe")
        if Nifs.check_subscription(sub) do
            msg = Rclex.initialize_msg()
            msginfo = Nifs.create_msginfo()
            sub_alloc = Nifs.create_sub_alloc()

            case Nifs.rcl_take(sub, msg, msginfo, sub_alloc) do
                {Rclex.Macros.rcl_ret_ok(), _, _, _} ->
                GenServer.cast(Executor, {:subscribe, {sub_id, msg}})

                {Rclex.Macros.rcl_ret_subscription_invalid(), _, _, _} ->
                Logger.error("subscription invalid")

                {Rclex.Macros.rcl_ret_subscription_take_failed(), _, _, _} ->
                do_nothing
            end
        end
    end

    def handle_cast({:loop}, {sub_id, wait_set, sub, call_back}) do
        {:noreply, {sub_id, wait_set, sub, call_back}, {:continue, :loop} }
    end

    def handle_continue(:loop, {sub_id, wait_set, sub, call_back}) do
        Nifs.rcl_wait_set_clear(wait_set)
        # waitsetにサブスクライバを追加する
        Nifs.rcl_wait_set_add_subscription(wait_set, sub)

        # wait_setからsubのリストを取りだす
        [waitset_sub]= Nifs.get_sublist_from_waitset(wait_set)

        # 待機時間によってCPU使用率，購読までの時間は変わる
        Nifs.rcl_wait(wait_set, 50)

        each_subscribe(waitset_sub, call_back, sub_id)

        # 
        receive do
            :stop ->
                Process.send(sub_id, :terminate, [:noconnect])
                {:stop, :normal, {sub_id, wait_set, sub, call_back}}
        after
        # Optional timeout
            50 ->
                {:noreply, {sub_id, wait_set, sub, call_back}, {:continue, :loop}}
        end
    end

    def terminate(:normal, state) do
        Logger.debug("loop process killed : normal")
    end

    def terminate(:shutdown, state) do
        Logger.debug("loop process killed : shutdown")
    end

    def do_nothing() do
    end
end