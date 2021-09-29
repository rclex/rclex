# このファイルは後で消す

# Executor->Subcriber->Loopの順でプロセスを生成、ループ内で購読処理を行う
# Loopが購読したらExecutorにメッセージを贈り、Executorは指定のSubscriberにコールバック実行を要請する

context = Rclex.rclexinit
node = Rclex.create_singlenode(context,'test_sub_node')
sub = Rclex.single_create_subscriber(node, 'testtopic')
{:ok, id_list} = Rclex.Executor.subscribe_start([sub], context, fn msg -> Rclex.readdata_string(msg) |> IO.puts end)
require Logger
Logger.debug("genserver")
:timer.sleep(2000)
{:ok, loop_text} = Rclex.Executor.stop_subscribe(id_list)
Logger.debug(loop_text)
{:ok, sub_text} = Rclex.Executor.stop_process(id_list)
Logger.debug(sub_text)

Rclex.subscriber_finish([sub], [node])
Rclex.node_finish([node])
Rclex.shutdown(context)
Logger.debug("buji end")