defmodule Rclex.Nifs do
  @on_load :load_nifs
  @compile {:autoload, false}

  @moduledoc """
  T.B.A
  """

  def load_nifs do
    nif = Application.app_dir(:rclex, "priv/rclex")

    :erlang.load_nif(to_charlist(nif), 0)
  end

  # -----------------------init_nif.c--------------------------

  def rcl_get_zero_initialized_init_options do
    raise "NIF rcl_get_zero_initialized_init_options/0 not implemented"
  end

  def rcl_init_options_init(_a) do
    raise "NIF rcl_init_options_init/1 is not implemented"
  end

  def rcl_init_options_fini(_a) do
    raise "NIF rcl_init_options_fini/1 is not implemented"
  end

  def rcl_get_zero_initialized_context do
    raise "NIF rcl_get_zero_initialized_context/0 not implemented"
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
    raise "NIF rcl_init_with_null/2 not implemented"
  end

  @doc """
      return {:ok,rcl_ret_t}
      arguments...(
          rcl_context_t)
  """
  def shutdown(_a) do
    raise "NIF rcl_shutdown/1 not implemented"
  end

  # -----------------------node_nif.c--------------------------
  # return {:ok,rcl_node_t}
  def rcl_get_zero_initialized_node do
    raise "NIF rcl_get_zero_initialized_node/0 not implemented"
  end

  # return {:ok,rcl_node_options_t}
  def rcl_node_get_default_options do
    raise "NIF rcl_node_get_default_options/0 not implemented"
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
    raise "NIF rcl_node_init/5 not implemented"
  end

  def rcl_node_init_without_namespace(_a, _b, _c, _d) do
    raise "NIF rcl_node_init_without_namespace/4 is not implemented"
  end

  @doc """
      return rcl_ret_t
      argument...rcl_node_t
  """
  def rcl_node_fini(_a) do
    raise "NIF rcl_node_fini/1 not implemented"
  end

  def read_guard_condition(_a) do
    raise "haha"
  end

  @doc """
      return char
  """

  def rcl_node_get_name(_a) do
    raise "NIF rcl_node_get_name/1 not implemented"
  end

  # ------------------------------publisher_nif.c--------------------------
  @doc """
      return rcl_publisher_t
      argument...void
  """
  def rcl_get_zero_initialized_publisher do
    raise "NIF get_zero_initialized_publisher/0 not implemented"
  end

  @doc """
      return rcl_publisher_options_t
      argument...void
  """
  def rcl_publisher_get_default_options do
    raise "rcl_get_zero_initialized_publisher/0 not implemented"
  end

  @doc """
      return const char*
      argument...rcl_publisher_t*
  """
  def rcl_publisher_get_topic_name(_a) do
    raise "rcl_get_zero_initialized_publisher/0 not implemented"
  end

  @doc """
      return rcl_ret_t
      argument...rcl_publisher_t*,rcl_node_t*
  """
  def rcl_publisher_fini(_a, _b) do
    raise "rcl_get_zero_initialized_publisher/0 not implemented"
  end

  @doc """
      return rcl_ret_t
      argument...rcl_publisher_t * publisher,
                  const rcl_node_t * node,
                  const rosidl_message_type_support_t * type_support,
                  const char * topic_name,
                  const rcl_publisher_options_t * options
  """
  def rcl_publisher_init(_a, _b, _c, _d) do
    raise "rcl_publisher_init/4 not implemented"
  end

  @doc """
      return bool
      argument...rcl_publisher_t*
  """
  def rcl_publisher_is_valid(_a) do
    raise "rcl_publisher_is_valid/1 not implemented"
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
    raise "rcl_publish/3 is not implemented"
  end

  def create_pub_alloc do
    raise "NIF create_pub_alloc/0 is not implemented"
  end

  # ---------------------------subscription_nif.c--------------------------
  def rcl_subscription_get_default_options do
    raise "NIF rcl_subscription_get_default_options is not implemented"
  end

  def rcl_get_zero_initialized_subscription do
    raise "NIF rcl_subscription_get_default_options is not implemented"
  end

  def create_sub_alloc do
    raise "NIF create_suballoc/0 is not implemented"
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
  def rcl_subscription_init(_a, _b, _c, _d) do
    raise "NIF rcl_subscription_init is not implemented"
  end

  @doc """
      return rcl_ret_t
      argument...rcl_subscription_t*,rcl_node_t*
  """
  def rcl_subscription_fini(_a, _b) do
    raise "NIF rcl_subscription_fini is not implemented"
  end

  def rcl_subscription_get_topic_name(_a) do
    raise "NIF rcl_subscription_get_topic_name/1 is not implemented"
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
    raise "NIF rcl_take is not implemented"
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
    raise "NIF rcl_get_topic_names_and_types is not implemented"
  end

  # -----------------------------msg_int16.c------------------------------
  def create_empty_int16 do
    raise "NIF create_empty_int16/0 is not implemented"
  end

  def create_msginfo do
    raise "NIF create_msginfo/0 is not implemented"
  end

  def int16_init(_a) do
    raise "NIF std_msgs__msg__Int16__init/0 not implemented"
  end

  def int16_destroy(_a) do
    raise "NIF std_msgs__msg__Int16__destroy/1 not implemented"
  end

  def get_message_type_from_std_msgs_msg_int16 do
    raise "NIF get_message_type_from_std_msgs_msg_Int16/0 not implemented"
  end

  def readdata_int16(_a) do
    raise "NIF readdata_int16/1 is not implemented"
  end

  def setdata_int16(_a, _b) do
    raise "NIF setdata_int16/2 is not implemented"
  end

  # -----------------------msg_string_nif.c-----------------------------

  def create_empty_string do
    raise "NIF create_empty_string/0 is not implemented"
  end

  def string_init(_a) do
    raise "NIF string_init/1 is not implemented"
  end

  # arg..(initialized msg,string)
  def setdata_string(_a, _b, _c) do
    raise "NIF setdata_string/3 is not implemented"
  end

  # -----------------------------wait_nif.c------------------------------
  def rcl_get_default_allocator do
    raise "NIF rcl_get_default_allocator/0 is not implemented"
  end

  def rcl_get_zero_initialized_wait_set do
    raise "NIF rcl_get_zero_initialized_wait_set/0 is not implemented"
  end

  def rcl_wait_set_init(_a, _b, _c, _d, _e, _f, _g, _h, _i) do
    raise "NIF rcl_wait_set_init/9 is not implemented"
  end

  def rcl_wait_set_fini(_a) do
    raise "NIF rcl_wait_set_fini/1 is not implemented"
  end

  def rcl_wait_set_clear(_a) do
    raise "NIF rcl_wait_set_clear/1 is not implemented"
  end

  def rcl_wait_set_add_subscription(_a, _b) do
    raise "NIF rcl_wait_set_add_subscription/2 is not implemented"
  end

  def rcl_wait(_a, _b) do
    raise "NIF rcl_wait/0 is not implemented"
  end

  def check_subscription(_a) do
    raise "NIF check_subscription/1 is not implemented"
  end

  def check_waitset(_a, _b) do
    raise "NIF check_waitset/2 is not implemented"
  end

  def get_sublist_from_waitset(_a) do
    raise "NIF get_sublist_from_waitset/1 is not implemented"
  end

  @doc """
    メッセージからstringデータを取得する
  """
  def readdata_string(_a) do
    raise "NIF readdata_string/1 is not implemented"
  end

end
