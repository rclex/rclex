defmodule SimplePubSubTest do
  use ExUnit.Case

  test "publish and subscribe message" do
    spawn(Test.App.SimplePubSub, :pub_main, [1]);

    pid = spawn(Test.App.SimplePubSub, :sub_main, [1]);

    assert Process.alive?(pid)

    Process.sleep(1000)

    input_file = File.read("pub.txt")
    output_file = File.read("sub.txt")
    input_msg = elem(input_file, 1)
    output_msg = elem(output_file, 1)
    assert input_msg == output_msg
  end
end
