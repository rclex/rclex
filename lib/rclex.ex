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
    Rclexの終了
  """
  def shutdown(context) do
    Supervisor.stop(:executor)
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
