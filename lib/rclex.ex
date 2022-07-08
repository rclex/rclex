defmodule Rclex do
  alias Rclex.Nifs
  require Logger

  @moduledoc """
  Defines functions to manage ROS client resources.
  """

  @type rcl_context :: reference()
  @type rcl_allocator :: reference()
  @type rcl_ret :: reference()

  @doc """
  Initialize Rclex, return initialized context.
  """
  @spec rclexinit() :: rcl_context()
  def rclexinit() do
    children = [Rclex.ResourceServer]
    opts = [strategy: :one_for_one, name: :resource_server]

    Supervisor.start_link(children, opts)

    get_initialized_context()
  end

  @spec get_initialized_context() :: rcl_context()
  def get_initialized_context() do
    init_op = Nifs.rcl_get_zero_initialized_init_options()
    context = Nifs.rcl_get_zero_initialized_context()
    Nifs.rcl_init_options_init(init_op)
    Nifs.rcl_init_with_null(init_op, context)
    Nifs.rcl_init_options_fini(init_op)

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
  Shutdown Rclex,
  this function does not have to be called on exit,
  but does have to be called making a repeat call to rclexinit.
  """
  @spec shutdown(context :: reference()) :: {:ok, rcl_ret()}
  def shutdown(context) when is_reference(context) do
    Supervisor.stop(:resource_server)
    Nifs.rcl_shutdown(context)
  end

  @doc """
  Return a properly initialized allocator with default values.
  """
  @spec get_default_allocator :: rcl_allocator()
  def get_default_allocator do
    Nifs.rcl_get_default_allocator()
  end
end
