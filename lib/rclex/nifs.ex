defmodule Rclex.Nifs do
  @on_load {:load_nifs, 0}
  @compile {:autoload, false}

  @moduledoc false

  def load_nifs do
    nif = Application.app_dir(:rclex, "priv/rclex_nifs")

    :erlang.load_nif(to_charlist(nif), 0)
  end

  # -----------------------init_nif.c--------------------------

  def rcl_get_zero_initialized_init_options do
    :erlang.nif_error("NIF rcl_get_zero_initialized_init_options/0 not implemented")
  end

  def rcl_init_options_init(_a) do
    :erlang.nif_error("NIF rcl_init_options_init/1 is not implemented")
  end

  def rcl_init_options_fini(_a) do
    :erlang.nif_error("NIF rcl_init_options_fini/1 is not implemented")
  end

  def rcl_get_zero_initialized_context do
    :erlang.nif_error("NIF rcl_get_zero_initialized_context/0 not implemented")
  end

  @doc """
      return {:ok,rcl_ret_t}
      arguments...(
          int argc,
          char const * const * argv,
          const rcl_init_options_t * options,
          rcl_context_t * context)
        argc,argvに0,NULLを直接入れる関数
  """
  def rcl_init_with_null(_a, _b) do
    :erlang.nif_error("NIF rcl_init_with_null/2 not implemented")
  end

  @doc """
      return {:ok,rcl_ret_t}
      arguments...(
          rcl_context_t)
  """
  def rcl_shutdown(_a) do
    :erlang.nif_error("NIF rcl_shutdown/1 not implemented")
  end

  # -----------------------node_nif.c--------------------------
  # return {:ok,rcl_node_t}
  def rcl_get_zero_initialized_node do
    :erlang.nif_error("NIF rcl_get_zero_initialized_node/0 not implemented")
  end

  # return {:ok,rcl_node_options_t}
  def rcl_node_get_default_options do
    :erlang.nif_error("NIF rcl_node_get_default_options/0 not implemented")
  end

  @doc """
      return {:ok,rcl_ret_t}
      argument...(
      rcl_node_t * node,
      const char * name,
      const char * namespace_,
      rcl_context_t * context,
      const rcl_node_options_t * options)
  """
  def rcl_node_init(_a, _b, _c, _d, _e) do
    :erlang.nif_error("NIF rcl_node_init/5 not implemented")
  end

  def rcl_node_init_without_namespace(_a, _b, _c, _d) do
    :erlang.nif_error("NIF rcl_node_init_without_namespace/4 is not implemented")
  end

  @doc """
      return rcl_ret_t
      argument...rcl_node_t
  """
  def rcl_node_fini(_a) do
    :erlang.nif_error("NIF rcl_node_fini/1 not implemented")
  end

  def read_guard_condition(_a) do
    :erlang.nif_error("haha")
  end

  @doc """
      return char
  """

  def rcl_node_get_name(_a) do
    :erlang.nif_error("NIF rcl_node_get_name/1 not implemented")
  end

  # ------------------------------publisher_nif.c--------------------------
  @doc """
      return rcl_publisher_t
      argument...void
  """
  def rcl_get_zero_initialized_publisher do
    :erlang.nif_error("NIF get_zero_initialized_publisher/0 not implemented")
  end

  @doc """
      return rcl_publisher_options_t
      argument...void
  """
  def rcl_publisher_get_default_options do
    :erlang.nif_error("rcl_get_zero_initialized_publisher/0 not implemented")
  end

  @doc """
      return const char*
      argument...rcl_publisher_t*
  """
  def rcl_publisher_get_topic_name(_a) do
    :erlang.nif_error("rcl_get_zero_initialized_publisher/0 not implemented")
  end

  @doc """
      return rcl_ret_t
      argument...rcl_publisher_t*,rcl_node_t*
  """
  def rcl_publisher_fini(_a, _b) do
    :erlang.nif_error("rcl_get_zero_initialized_publisher/0 not implemented")
  end

  @doc """
      return rcl_ret_t
      argument...rcl_publisher_t * publisher,
                  const rcl_node_t * node,
                  const rosidl_message_type_support_t * type_support,
                  const char * topic_name,
                  const rcl_publisher_options_t * options
  """
  def rcl_publisher_init(_a, _b, _c, _d, _e) do
    :erlang.nif_error("rcl_publisher_init/4 not implemented")
  end

  @doc """
      return bool
      argument...rcl_publisher_t*
  """
  def rcl_publisher_is_valid(_a) do
    :erlang.nif_error("rcl_publisher_is_valid/1 not implemented")
  end

  @doc """
    rcl_ret_t
    rcl_publish(
      const rcl_publisher_t * publisher,
      const void * ros_message,
      rmw_publisher_allocation_t * allocation
    );
  """
  def rcl_publish(_a, _b, _c) do
    :erlang.nif_error("rcl_publish/3 is not implemented")
  end

  def create_pub_alloc do
    :erlang.nif_error("NIF create_pub_alloc/0 is not implemented")
  end

  # ---------------------------subscription_nif.c--------------------------
  def rcl_subscription_get_default_options do
    :erlang.nif_error("NIF rcl_subscription_get_default_options is not implemented")
  end

  def rcl_get_zero_initialized_subscription do
    :erlang.nif_error("NIF rcl_subscription_get_default_options is not implemented")
  end

  def create_sub_alloc do
    :erlang.nif_error("NIF create_suballoc/0 is not implemented")
  end

  @doc """
    rcl_ret_t
    rcl_subscription_init(
      rcl_subscription_t * subscription,
      const rcl_node_t * node,
      const rosidl_message_type_support_t * type_support,
      const char * topic_name,
      const rcl_subscription_options_t * options
  );
  """
  def rcl_subscription_init(_a, _b, _c, _d, _e) do
    :erlang.nif_error("NIF rcl_subscription_init is not implemented")
  end

  @doc """
      return rcl_ret_t
      argument...rcl_subscription_t*,rcl_node_t*
  """
  def rcl_subscription_fini(_a, _b) do
    :erlang.nif_error("NIF rcl_subscription_fini is not implemented")
  end

  def rcl_subscription_get_topic_name(_a) do
    :erlang.nif_error("NIF rcl_subscription_get_topic_name/1 is not implemented")
  end

  @doc """
    rcl_ret_t
    rcl_take(
      const rcl_subscription_t * subscription,
      void * ros_message,
      rmw_message_info_t * message_info,
      rmw_subscription_allocation_t * allocation
    );
  """
  def rcl_take(_a, _b, _c, _d) do
    :erlang.nif_error("NIF rcl_take is not implemented")
  end

  # -----------------------------graph_nif.c------------------------------
  @doc """
    rcl_ret_t
    rcl_get_topic_names_and_types(
      const rcl_node_t * node,
      rcl_allocator_t * allocator,
      bool no_demangle,
      rcl_names_and_types_t * topic_names_and_types);
  """
  def rcl_get_topic_names_and_types(_a, _b, _c) do
    :erlang.nif_error("NIF rcl_get_topic_names_and_types is not implemented")
  end

  # -----------------------------wait_nif.c------------------------------
  def rcl_get_default_allocator do
    :erlang.nif_error("NIF rcl_get_default_allocator/0 is not implemented")
  end

  def rcl_get_zero_initialized_wait_set do
    :erlang.nif_error("NIF rcl_get_zero_initialized_wait_set/0 is not implemented")
  end

  def rcl_wait_set_init(_a, _b, _c, _d, _e, _f, _g, _h, _i) do
    :erlang.nif_error("NIF rcl_wait_set_init/9 is not implemented")
  end

  def rcl_wait_set_fini(_a) do
    :erlang.nif_error("NIF rcl_wait_set_fini/1 is not implemented")
  end

  def rcl_wait_set_clear(_a) do
    :erlang.nif_error("NIF rcl_wait_set_clear/1 is not implemented")
  end

  def rcl_wait_set_add_subscription(_a, _b) do
    :erlang.nif_error("NIF rcl_wait_set_add_subscription/2 is not implemented")
  end

  def rcl_wait(_a, _b) do
    :erlang.nif_error("NIF rcl_wait/0 is not implemented")
  end

  def check_subscription(_a) do
    :erlang.nif_error("NIF check_subscription/1 is not implemented")
  end

  def check_waitset(_a, _b) do
    :erlang.nif_error("NIF check_waitset/2 is not implemented")
  end

  def get_sublist_from_waitset(_a) do
    :erlang.nif_error("NIF get_sublist_from_waitset/1 is not implemented")
  end

  # ------------------------------msg_nif.c----------------------------
  def create_msginfo do
    :erlang.nif_error("NIF create_msginfo/0 is not implemented")
  end

  # -----<custom_msgtype>_nif.c-----start-----
  def get_typesupport_geometry_msgs_msg_twist,
    do: :erlang.nif_error("NIF get_typesupport_geometry_msgs_msg_twist/0 is not implemented")

  def create_empty_msg_geometry_msgs_msg_twist,
    do: :erlang.nif_error("NIF create_empty_msg_geometry_msgs_msg_twist/0 is not implemented")

  def init_msg_geometry_msgs_msg_twist(_),
    do: :erlang.nif_error("NIF init_msg_geometry_msgs_msg_twist/1 is not implemented")

  def setdata_geometry_msgs_msg_twist(_, _),
    do: :erlang.nif_error("NIF setdata_geometry_msgs_msg_twist/2 is not implemented")

  def readdata_geometry_msgs_msg_twist(_),
    do: :erlang.nif_error("NIF readdata_geometry_msgs_msg_twist/1 is not implemented")

  def get_typesupport_std_msgs_msg_string,
    do: :erlang.nif_error("NIF get_typesupport_std_msgs_msg_string/0 is not implemented")

  def create_empty_msg_std_msgs_msg_string,
    do: :erlang.nif_error("NIF create_empty_msg_std_msgs_msg_string/0 is not implemented")

  def init_msg_std_msgs_msg_string(_),
    do: :erlang.nif_error("NIF init_msg_std_msgs_msg_string/1 is not implemented")

  def setdata_std_msgs_msg_string(_, _),
    do: :erlang.nif_error("NIF setdata_std_msgs_msg_string/2 is not implemented")

  def readdata_std_msgs_msg_string(_),
    do: :erlang.nif_error("NIF readdata_std_msgs_msg_string/1 is not implemented")

  # -----<custom_msgtype>_nif.c-----end-----
end
