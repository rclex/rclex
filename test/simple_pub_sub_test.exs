defmodule SimplePubSubTest do
  use ExUnit.Case

  test "publish and subscribe message" do
    
    num_node = 1
    context = Rclex.rclexinit()
    node_list = Rclex.create_nodes(context, 'test_pub_node', num_node)
    
    sub_pid = spawn(Test.App.SimplePubSub, :sub_main, [node_list, context])
    assert Process.alive?(sub_pid)

    pub_pid = spawn(Test.App.SimplePubSub, :pub_main, [node_list])
    assert Process.alive?(pub_pid)

    Process.sleep(2000)

    Rclex.node_finish(node_list)
    Rclex.shutdown(context)

    input_file = File.read("pub.txt")
    output_file = File.read("sub.txt")
    input_msg = elem(input_file, 1)
    output_msg = elem(output_file, 1)
    assert input_msg == output_msg
  end
end
