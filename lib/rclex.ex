defmodule Rclex do
  alias Rclex.Nifs
  require Logger

  @moduledoc """
  T.B.A
  """

  # ------------------------ユーザAPI群-------------------
  @doc """
    Rclex初期化
    RCLのコンテキストを有効化
  """
  def rclexinit do
    init_op = Nifs.rcl_get_zero_initialized_init_options()
    context = Nifs.rcl_get_zero_initialized_context()
    Nifs.rcl_init_options_init(init_op)
    Nifs.rcl_init_with_null(init_op, context)
    Nifs.rcl_init_options_fini(init_op)
    children = [
      Rclex.Executor
    ]
    opts = [strategy: :one_for_one, name: :executor]
    Supervisor.start_link(children, opts)
    context
  end

  @doc """
    ノードをひとつだけ作成
    名前空間の有無を設定可能
  """
  def create_singlenode(context, node_name, node_namespace) do
    node = Nifs.rcl_get_zero_initialized_node()
    node_op = Nifs.rcl_node_get_default_options()
    Nifs.rcl_node_init(node, node_name, node_namespace, context, node_op)
    node
  end

  def create_singlenode(context, node_name) do
    node = Nifs.rcl_get_zero_initialized_node()
    node_op = Nifs.rcl_node_get_default_options()
    Nifs.rcl_node_init_without_namespace(node, node_name, context, node_op)
    node
  end

  @doc """
    複数ノード生成
    create_nodes/4ではcreate_nodes/3に加えて名前空間の指定が可能
  """
  def create_nodes(context, node_name, namespace, num_node) do
    node_list =
      Enum.map(0..(num_node - 1), fn n ->
        Nifs.rcl_node_init(
          Nifs.rcl_get_zero_initialized_node(),
          node_name ++ Integer.to_charlist(n),
          namespace,
          context,
          Nifs.rcl_node_get_default_options()
        )
      end)

    node_list
  end

  def create_nodes(context, node_name, num_node) do
    node_list =
      Enum.map(1..num_node, fn n ->
        Nifs.rcl_node_init_without_namespace(
          Nifs.rcl_get_zero_initialized_node(),
          node_name ++ Integer.to_charlist(n),
          context,
          Nifs.rcl_node_get_default_options()
        )
      end)

    node_list
  end

  @doc """
    パブリッシャおよびサブスクライバをひとつだけ生成
  """
  def single_create_publisher(pub_node, topic_name) do
    publisher = Nifs.rcl_get_zero_initialized_publisher()
    pub_op = Nifs.rcl_publisher_get_default_options()
    Nifs.rcl_publisher_init(publisher, pub_node, topic_name, pub_op)
    publisher
  end

  def single_create_subscriber(sub_node, topic_name) do
    subscriber = Nifs.rcl_get_zero_initialized_subscription()
    sub_op = Nifs.rcl_subscription_get_default_options()
    Nifs.rcl_subscription_init(subscriber, sub_node, topic_name, sub_op)
    subscriber
  end

  @doc """
    パブリッシャおよびサブスクライバを複数生成
    :singleもしくは:multiを指定する．
    :single...一つのトピックに複数の出版者または購読者
    :multi...1つのトピックに出版者または購読者1つのペアを複数
  """
  def create_publishers(node_list, topic_name, :single) do
    Enum.map(node_list, fn node ->
      Nifs.rcl_publisher_init(
        Nifs.rcl_get_zero_initialized_publisher(),
        node,
        topic_name,
        Nifs.rcl_publisher_get_default_options()
      )
    end)
  end

  def create_publishers(node_list, topic_name, :multi) do
    Enum.map(0..(length(node_list) - 1), fn index ->
      Rclex.single_create_publisher(
        Enum.at(node_list, index),
        topic_name ++ Integer.to_charlist(index)
      )
    end)
  end

  def create_subscribers(node_list, topic_name, :single) do
    Enum.map(node_list, fn node ->
      Nifs.rcl_subscription_init(
        Nifs.rcl_get_zero_initialized_subscription(),
        node,
        topic_name,
        Nifs.rcl_subscription_get_default_options()
      )
    end)
  end

  def create_subscribers(node_list, topic_name, :multi) do
    Enum.map(0..(length(node_list) - 1), fn index ->
      Rclex.single_create_subscriber(
        Enum.at(node_list, index),
        topic_name ++ Integer.to_charlist(index)
      )
    end)
  end

  @doc """
    ノード間通信に用いるメッセージの初期化
    :int16
  """
  def initialize_msg do
    Nifs.create_empty_string()
    |> Nifs.string_init()
  end

  @doc """
    ノード間通信に用いるメッセージの初期化
    :stringであればstring型が使えるようにする(現在使用可能な型)
  """
  def initialize_msgs(msg_count, :string) do
    Enum.map(1..msg_count, fn _ ->
      initialize_msg()
    end)
  end

  # TODO: :int16であればInt16型が使えるようにする(目標)
  def initialize_msgs(msg_count, :int16) do
    Enum.map(1..msg_count, fn _ ->
      Nifs.create_empty_int16()
    end)
  end

  @doc """
    メッセージからstringデータを取得する
  """
  def readdata_string(msg) do
    Nifs.readdata_string(msg)
  end

  @doc """
    メッセージにデータをセットする
    現在はstring型のみのサポートになっている
  """
  def setdata(msg, data, :string) do
    data_size = String.length(data)
    Nifs.setdata_string(msg, String.to_charlist(data), data_size + 1)
  end

  @doc """
    ユーザのタスク終了入力を受け付けるAPI.
    0を入力するとchildに渡されたPIDのタスクを終了する
  """
  def waiting_input(sv, child) do
    num =
      IO.gets("")
      |> String.replace("\n", "")
      |> String.to_integer()

    case num do
      0 -> Rclex.Timer.terminate_timer(sv, child)
      _ -> waiting_input(sv, child)
    end
  end

  @doc """
    パブリッシャの終了
  """
  def publisher_finish(pub_list, node_list) do
    Logger.debug("publishers finish")
    n = length(pub_list)

    Enum.map(0..(n - 1), fn index ->
      Nifs.rcl_publisher_fini(Enum.at(pub_list, index), Enum.at(node_list, index))
    end)
  end

  @doc """
    サブスクライバの終了
  """
  def subscriber_finish(sub_list, node_list) do
    Logger.debug("subscribers finish")
    n = length(sub_list)

    Enum.map(0..(n - 1), fn index ->
      Nifs.rcl_subscription_fini(Enum.at(sub_list, index), Enum.at(node_list, index))
    end)
  end

  @doc """
    ノードの終了
    ノード関連のメモリを解放する
  """
  def node_finish(node_list) do
    Logger.debug("node finish")

    Enum.map(node_list, fn node ->
      Nifs.rcl_node_fini(node)
    end)
  end

  @doc """
    Rclexの終了
  """
  def shutdown(context) do
    Nifs.rcl_shutdown(context)
  end

  @doc """
    ノード名の取得
  """
  def node_get_name(node) do
    Nifs.rcl_node_get_name(node)
  end

  @doc """
    トピックの名前と型の取得
  """
  def get_topic_names_and_types(node, allocator, no_demangle) do
    Nifs.rcl_get_topic_names_and_types(node, allocator, no_demangle)
  end

  def get_default_allocator do
    Nifs.rcl_get_default_allocator()
  end
end
