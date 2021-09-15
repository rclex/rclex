defmodule Rclex.Executor do
    require Rclex.Macros
    require Logger
    use GenServer

    def start() do
        GenServer.start_link(__MODULE__, {}, name: Executor)
    end

    def init(_) do
        {:ok, {}} 
    end
    
    def publish(pub_list, msg_list) do
        Logger.debug("publish queue!!!!")
        Enum.map((0..length(pub_list) - 1), fn index ->
            GenServer.call(Executor, {:set_queue, {Enum.at(pub_list, index), :publish, {Enum.at(msg_list, index)}}},500)
        end)
    end

    @doc """
        購読開始の準備
        監視されるタスクを生成し，購読ループ処理を実行させる
    """
    def subscribe_start(sub_list, context, call_back) do
        id_list = sub_list
                |> Enum.map(fn sub -> Rclex.Subscriber.start_link(sub, context, call_back)end )
                |> Enum.map(fn {:ok, pid} -> pid end)

        {:ok, id_list}
    end

    @doc """
        プロセスを終了する
    """
    def stop_process(id_list) do
        Enum.map(fn id -> GenServer.stop(id) end)
    end
    
    def handle_cast({:subscribe, {id, msg}}, state) do
        GenServer.cast(id, {:execute, msg})
        {:noreply, state}
    end

    def handle_call({:sub_start_link, sub, context, call_back}, _from, state) do
        {:ok, pid} = Rclex.Subscriber.start_link(sub, context, call_back)
        {:ok, pid, state}
    end

end