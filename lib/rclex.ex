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
