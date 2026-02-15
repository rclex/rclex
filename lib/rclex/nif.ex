defmodule Rclex.Nif do
  @moduledoc false

  require Logger

  @on_load :load
  @compile {:autoload, false}

  defp on_host? do
    if function_exported?(Nerves.Runtime, :mix_target, 0) do
      apply(Nerves.Runtime, :mix_target, []) == :host
    else
      true
    end
  end

  defp error_message(reason) do
    if on_host?() do
      """
      Failed to load NIF library for Rclex.

      This usually means ROS environment is not initialized.

      Please run: source /opt/ros/<ROS_DISTRO>/setup.bash

      Original error: #{inspect(reason)}
      """
    else
      """
      Failed to load NIF library for Rclex on Nerves.

      This usually means ROS 2 resources are not properly prepared on the Nerves device.

      Please ensure:
        1. You have run: mix rclex.prep.ros2 --arch <your_arch>
        2. The ROS 2 libraries are available on the device
        3. LD_LIBRARY_PATH is properly set to include the ROS 2 library paths

      For more details, see: USE_ON_NERVES.md

      Original error: #{inspect(reason)}
      """
    end
  end

  def load() do
    path =
      Application.app_dir(:rclex)
      |> Path.join("priv/rclex.so")
      |> String.replace_suffix(".so", "")
      |> to_charlist()

    case :erlang.load_nif(path, _load_info = :any_term) do
      :ok ->
        :ok

      {:error, reason} ->
        Logger.error(error_message(reason))
        {:error, reason}
    end
  end

  def test_raise!() do
    :erlang.nif_error(:nif_not_loaded)
  end

  def test_raise_with_message!() do
    :erlang.nif_error(:nif_not_loaded)
  end

  def test_qos_profile!(_qos) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_init!() do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_fini!(_context) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_node_init!(_context, _name, _namespace) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_node_fini!(_node) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_publisher_init!(_node, _type_support, _topic_name, _qos) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_publisher_fini!(_publisher, _node) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_publish!(_publisher, _ros_message) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_subscription_init!(_node, _type_support, _topic_name, _qos) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_subscription_fini!(_subscription, _node) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_subscription_set_on_new_message_callback!(_subscription) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_subscription_clear_message_callback!(_subscription, _callback_resource) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_clock_init!() do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_clock_fini!(_clock) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_timer_init!(_context, _clock, _period_ms) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_timer_fini!(_timer) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_timer_is_ready!(_timer) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_timer_call!(_timer) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_take!(_subscription, _message) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_wait_set_init_subscription!(_context) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_wait_set_init_timer!(_context) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_wait_set_fini!(_wait_set) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_wait_subscription!(_wait_set, _timeout_us, _subscription) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_wait_timer!(_wait_set, _timeout_us, _timer) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rmw_qos_profile_sensor_data!() do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rmw_qos_profile_parameters!() do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rmw_qos_profile_default!() do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rmw_qos_profile_services_default!() do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rmw_qos_profile_parameter_events!() do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rmw_qos_profile_system_default!() do
    :erlang.nif_error(:nif_not_loaded)
  end

  @before_compile Rclex.MsgFuncs
end
