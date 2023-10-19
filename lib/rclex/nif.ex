defmodule Rclex.Nif do
  @moduledoc false

  @on_load :load

  def load() do
    Application.app_dir(:rclex)
    |> Path.join("priv/rclex.so")
    |> String.replace_suffix(".so", "")
    |> to_charlist()
    |> :erlang.load_nif(_load_info = :any_term)
  end

  def raise!() do
    :erlang.nif_error(:nif_not_loaded)
  end

  def raise_with_message!() do
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

  def rcl_publisher_init!(_node, _type_support, _topic_name) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_publisher_fini!(_publisher, _node) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_publish!(_publisher, _ros_message) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_subscription_init!(_node, _type_support, _topic_name) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_subscription_fini!(_subscription, _node) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_take!(_subscription, _message) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_wait_set_init_subscription!(_context) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_wait_set_fini!(_wait_set) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_wait_subscription!(_wait_set, _timeout_us, _subscription) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def sensor_msgs_msg_point_cloud_type_support!() do
    :erlang.nif_error(:nif_not_loaded)
  end

  def sensor_msgs_msg_point_cloud_create!() do
    :erlang.nif_error(:nif_not_loaded)
  end

  def sensor_msgs_msg_point_cloud_destroy!(_message) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def sensor_msgs_msg_point_cloud_set!(_message, _data) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def sensor_msgs_msg_point_cloud_get!(_message) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def std_msgs_msg_string_type_support!() do
    :erlang.nif_error(:nif_not_loaded)
  end

  def std_msgs_msg_string_create!() do
    :erlang.nif_error(:nif_not_loaded)
  end

  def std_msgs_msg_string_destroy!(_message) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def std_msgs_msg_string_set!(_message, _data) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def std_msgs_msg_string_get!(_message) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def std_msgs_msg_multi_array_dimension_type_support!() do
    :erlang.nif_error(:nif_not_loaded)
  end

  def std_msgs_msg_multi_array_dimension_create!() do
    :erlang.nif_error(:nif_not_loaded)
  end

  def std_msgs_msg_multi_array_dimension_destroy!(_message) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def std_msgs_msg_multi_array_dimension_set!(_message, _data) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def std_msgs_msg_multi_array_dimension_get!(_message) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def std_msgs_msg_multi_array_layout_type_support!() do
    :erlang.nif_error(:nif_not_loaded)
  end

  def std_msgs_msg_multi_array_layout_create!() do
    :erlang.nif_error(:nif_not_loaded)
  end

  def std_msgs_msg_multi_array_layout_destroy!(_message) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def std_msgs_msg_multi_array_layout_set!(_message, _data) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def std_msgs_msg_multi_array_layout_get!(_message) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def std_msgs_msg_u_int32_multi_array_type_support!() do
    :erlang.nif_error(:nif_not_loaded)
  end

  def std_msgs_msg_u_int32_multi_array_create!() do
    :erlang.nif_error(:nif_not_loaded)
  end

  def std_msgs_msg_u_int32_multi_array_destroy!(_message) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def std_msgs_msg_u_int32_multi_array_set!(_message, _data) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def std_msgs_msg_u_int32_multi_array_get!(_message) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def geometry_msgs_msg_vector3_type_support!() do
    :erlang.nif_error(:nif_not_loaded)
  end

  def geometry_msgs_msg_vector3_create!() do
    :erlang.nif_error(:nif_not_loaded)
  end

  def geometry_msgs_msg_vector3_destroy!(_message) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def geometry_msgs_msg_vector3_set!(_message, _data) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def geometry_msgs_msg_vector3_get!(_message) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def geometry_msgs_msg_twist_type_support!() do
    :erlang.nif_error(:nif_not_loaded)
  end

  def geometry_msgs_msg_twist_create!() do
    :erlang.nif_error(:nif_not_loaded)
  end

  def geometry_msgs_msg_twist_destroy!(_message) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def geometry_msgs_msg_twist_set!(_message, _data) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def geometry_msgs_msg_twist_get!(_message) do
    :erlang.nif_error(:nif_not_loaded)
  end
end
