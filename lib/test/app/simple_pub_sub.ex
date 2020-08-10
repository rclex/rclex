defmodule Test.App.SimplePubSub do
  @moduledoc """
    The sample which makes any number of publishers.
  """
  def pub_main(node_list) do
    publisher_list = Rclex.create_publishers(node_list, 'testtopic', :single)
    {sv, child} = Rclex.Timer.timer_start(publisher_list, 500, &pub_callback/1, 100)

    # In timer_start/2,3, the number of times that the timer process is executed can be set.
    # If it is not set, the timer process loops forever.
    Process.sleep(1000)
    Rclex.Timer.terminate_timer(sv, child)
    Rclex.publisher_finish(publisher_list, node_list)
  end

  @doc """
    Timer event callback function defined by user.
  """
  def pub_callback(publisher_list) do
    # Create messages according to the number of publishers.
    n = length(publisher_list)
    msg_list = Rclex.initialize_msgs(n, :string)
    data = Test.Helper.String.random_string(10)
    IO.puts("publish message:#{data}")
    File.write("pub.txt", data)
    # Set data.
    Enum.map(0..(n - 1), fn index ->
      Rclex.setdata(Enum.at(msg_list, index), data, :string)
    end)

    # Publish topics.
    # IO.puts("pub time:#{:os.system_time(:microsecond)}")
    Rclex.Publisher.publish(publisher_list, msg_list)
  end

  def sub_main(node_list, context) do
    # Create as many nodes as you specify in num_node
    subscriber_list = Rclex.create_subscribers(node_list, 'testtopic', :single)
    {sv, child} = Rclex.Subscriber.subscribe_start(subscriber_list, context, &sub_callback/1)

    Process.sleep(1000)
    Rclex.Timer.terminate_timer(sv, child)
    Rclex.subscriber_finish(subscriber_list, node_list)
  end

  # Describe callback function.
  def sub_callback(msg) do
    # IO.puts("sub time:#{:os.system_time(:microsecond)}")
    received_msg = Rclex.readdata_string(msg)
    IO.puts("received msg:#{received_msg}")
    File.write("sub.txt", received_msg)
  end
end
