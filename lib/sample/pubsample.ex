defmodule PubSample do
  @moduledoc """
    任意の数のPublisherを作成するサンプル
  """
  def pubmain(num_node) do
    RclEx.rclexinit                                   #|> context
    |> RclEx.create_nodes('test_pub_node',num_node)   #|> node_list
    |> RclEx.create_publishers('testtopic',:single)   #|> publisher_list
    |> RclEx.Timer.timer_start(1000,&callback/1,100)
    #timer_start/2,3ではタイマー処理を何回行うかの設定が可能．回数を指定しなければ永遠にループを続ける
  end
  @doc """
    ユーザー定義のタイマーイベントコールバック関数
  """
  def callback(publisher_list) do
    #publisherのかずに応じてメッセージを作成する
    n = length(publisher_list)
    msg_list = RclEx.initialize_msgs(n,:string)
    {:ok,data} = File.read("textdata/test.txt")
    #データをセット
    Enum.map(0..n-1,fn(index)->
      RclEx.setdata(Enum.at(msg_list,index),data,:string)
    end)

    #出版
    #IO.puts("pub time:#{:os.system_time(:microsecond)}")
    RclEx.Publisher.publish(publisher_list,msg_list)
  end
end
