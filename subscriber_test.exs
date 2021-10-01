# このファイルは後で消す

# Executor->Subcriber->Loopの順でプロセスを生成、ループ内で購読処理を行う
# Loopが購読したらExecutorにメッセージを贈り、Executorは指定のSubscriberにコールバック実行を要請する

context = Rclex.rclexinit
{:ok, node} = Rclex.Executor.create_singlenode(context,'test_sub_node')
{:ok, sub} = Rclex.Node.single_create_subscriber(node, 'testtopic')
Rclex.Subscriber.subscribe_start(sub, context, fn msg -> Rclex.readdata_string(msg) |> IO.puts end)
require Logger
Logger.debug("genserver")
:timer.sleep(2000)
{:ok, loop_text} = Rclex.Node.stop_subscribe(sub)
Logger.debug(loop_text)
{:ok, sub_text} = Rclex.Executor.stop_process([node])
Logger.debug(sub_text)

# TODO: stop_processをstop_nodeにする
# TODO: subscriber_finishをRclex.Executorに実装する
# TODO: Rclex.node_finishをRclex.Executorに実装する
# TODO: Rclex.shutdownでExecutorを止める

# Rclex.subscriber_finish([sub], [node])
# Rclex.node_finish([node])
# Rclex.shutdown(context)
# Logger.debug("buji end")