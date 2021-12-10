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
  """
  def initialize_msg(:string) do
    Nifs.create_empty_string()
    |> Nifs.string_init()
  end
  def initialize_msg(:int16) do
    Nifs.create_empty_int16()
  end

  @doc """
    ノード間通信に用いるメッセージリストの初期化
  """
  def initialize_msgs(msg_count, :string) do
    Enum.map(1..msg_count, fn _ ->
      initialize_msg(:string)
    end)
  end
  def initialize_msgs(msg_count, :int16) do
    Enum.map(1..msg_count, fn _ ->
      initialize_msg(:int16)
    end)
  end

  @doc """
    メッセージからデータを取得する
  """
  def readdata(msg, :string) do
    Nifs.readdata_string(msg)
  end
 def readdata(msg, :int16) do
    Nifs.readdata_int16(msg)
  end

  @doc """
    メッセージにデータをセットする
  """
  def setdata(msg, data, :string) do
    data_size = String.length(data)
    Nifs.setdata_string(msg, String.to_charlist(data), data_size + 1)
  end
 def setdata(msg, data, :int16) do
    Nifs.setdata_int16(msg, data)
  end

  @doc """
    型サポートを取得する
  """
  def get_typesupport(:string) do
    Nifs.getmsgtype_String()
  end
  def get_typesupport(:int16) do
    Nifs.getmsgtype_int16()
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
      0 -> Rclex.Timer.terminate(sv, child)
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

  def get_default_allocator do
    Nifs.rcl_get_default_allocator()
  end
end
