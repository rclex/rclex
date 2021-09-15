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

    @doc """
        購読開始の準備
        監視されるタスクを生成し，購読ループ処理を実行させる
    """
    def subscribe_start(sub_list, context, call_back) do
        id_list = sub_list
                |> Enum.map(fn sub -> GenServer.call(Executor, {:sub_start_link, sub, context, call_back}) end )

        {:ok, id_list}
    end

    @doc """
        プロセスを終了する
    """
    def stop_process(id_list) do
        Enum.map(id_list, fn id -> GenServer.stop(id) end)
    end

    end
    
    def handle_cast({:subscribe, {id, msg}}, state) do
        GenServer.cast(id, {:execute, msg})
        {:noreply, state}
    end

    def handle_call({:sub_start_link, sub, context, call_back}, _from, state) do
        {:ok, pid} = Rclex.Subscriber.start_link(sub, context, call_back)
        {:reply, pid, state}
    end
end