# num_node = 1
# context = Rclex.rclexinit
# node_list = Rclex.create_nodes(context,'test_pub_node',num_node)
# publisher_list = Rclex.create_publishers(node_list, 'testtopic', :single)
# list = GenServer.call(Executor, {:publish_init, publisher_list, fn index -> index end})
# GenServer.call(System, {:publish, "publish"})

# Executor->Subcriber->Loopの順でプロセスを生成、ループ内で購読処理を行う
# Loopが購読したらExecutorにメッセージを贈り、Executorは指定のSubscriberにコールバック実行を要請する

{:ok, id} = Rclex.Executor.start()
context = Rclex.rclexinit
node = Rclex.create_singlenode(context,'test_sub_node')
sub = Rclex.single_create_subscriber(node, 'testtopic')
{:ok, id_list} = Rclex.Executor.subscribe_start([sub], context, fn msg -> Rclex.readdata_string(msg) |> IO.puts end)
require Logger
Logger.debug("genserver")
:timer.sleep(500)
{:ok, text} = Rclex.Executor.stop_process(id_list)
Logger.debug(text)

Rclex.subscriber_finish([sub], [node])
Rclex.node_finish([node])
Rclex.shutdown(context)