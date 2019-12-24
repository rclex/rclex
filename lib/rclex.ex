defmodule RclEx do
  @on_load :load_nifs
    def load_nifs do
        IO.puts "load_nifs"
        :erlang.load_nif('/home/imanishi/rclex/rclex',0)
    end

  #-----------------------init_nif.c--------------------------
  #return rcl_init_options_t
  def rcl_get_zero_initialized_init_options do
    raise "NIF rcl_get_zero_initialized_init_options/0 not implemented"
  end
  def rcl_init_options_init(_a) do
    raise "NIF rcl_init_options_init/1 is not implemented"
  end

  def rcl_init_options_fini(_a) do
    raise "NIF rcl_init_options_fini/1 is not implemented"
  end
  #return rcl_context_t
  def rcl_get_zero_initialized_context do
      raise "NIF rcl_get_zero_initialized_context/0 not implemented"
  end
  #def nif_read_context(_a) do
  #    raise "NIF nif_read_context/1 is not implemented"
  #end
  @doc """
      return {:ok,rcl_ret_t}
      arguments...(
          int argc,
          char const * const * argv,
          const rcl_init_options_t * options,
          rcl_context_t * context)
        argc,argvに0,NULLを直接入れる関数
  """
  def rcl_init_with_null(_a,_b) do
      raise "NIF rcl_init_with_null/2 not implemented"
  end
  @doc """
      return {:ok,rcl_ret_t}
      arguments...(
          rcl_context_t)
  """        
  def rcl_shutdown(_a) do
      raise "NIF rcl_shutdown/1 not implemented" 
  end

  #-----------------------node_nif.c--------------------------
  #return {:ok,rcl_node_t}
  def rcl_get_zero_initialized_node do
    raise "NIF rcl_get_zero_initialized_node/0 not implemented"
  end

  #return {:ok,rcl_node_options_t}
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
  def rcl_node_init(_a,_b,_c,_d,_e) do
      raise "NIF rcl_node_init/5 not implemented"
  end
  def express_node_init do
      raise "sorry"
  end
  @doc """
      return rcl_ret_t 
      argument...rcl_node_t
  """
  def rcl_node_fini(_a) do
      raise "NIF rcl_node_fini/1 not implemented"
  end

#------------------------------publisher_nif.c--------------------------
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
  def rcl_publisher_fini(_a,_b) do
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
  def rcl_publisher_init(_a,_b,_c,_d) do
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
  #本来は第3引数があるが，一旦NULLにしておく
  def rcl_publish(_a,_b) do
      raise "rcl_publish/2 not implemented"
  end

  #---------------------------subscription_nif.c--------------------------
  def rcl_subscription_get_default_options do
    raise "NIF rcl_subscription_get_default_options is not implemented"
  end
  def rcl_get_zero_initialized_subscription do
    raise "NIF rcl_subscription_get_default_options is not implemented"
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
  def rcl_subscription_init(_a,_b,_c,_d) do
    raise "NIF rcl_subscription_init is not implemented"
  end
  @doc """
      return rcl_ret_t 
      argument...rcl_subscription_t*,rcl_node_t*
  """
  def rcl_subscription_fini(_a,_b) do
    raise "NIF rcl_subscription_fini is not implemented"
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
  def rcl_take(_a,_b,_c,_d) do
    raise "NIF rcl_take is not implemented"
  end
  
  #-----------------------------msg_int16.ex------------------------------
  def std_msgs__msg__Int16__init(_a) do
    raise "NIF std_msgs__msg__Int16__init/0 not implemented"
  end

  def std_msgs__msg__Int16__destroy(_a) do
      raise "NIF std_msgs__msg__Int16__destroy/1 not implemented"
  end

  def get_message_type_from_std_msgs_msg_Int16 do
      raise "NIF get_message_type_from_std_msgs_msg_Int16/0 not implemented"
  end

  #def cre_int16 do
  #    get_message_type_from_std_msgs_msg_Int16()
  #end
end

conn = RclEx.rcl_get_zero_initialized_context()
init_op = RclEx.rcl_get_zero_initialized_init_options()
RclEx.rcl_init_options_init(init_op)
RclEx.rcl_init_with_null(init_op,conn)
RclEx.rcl_init_options_fini(init_op)

node_op = RclEx.rcl_node_get_default_options()
node = RclEx.rcl_get_zero_initialized_node()
RclEx.rcl_node_init(node,'test_node','test_namespace_',conn,node_op)

IO.puts "hello"
#type_support = RclEx.get_message_type_from_std_msgs_msg_Int16()
#sub = RclEx.rcl_get_zero_initialized_subscription()
#sub_op = RclEx.rcl_subscription_get_default_options()
IO.puts "world"
#RclEx.rcl_subscription_init(sub,node,'testtopic',sub_op) #get_message_handle assertion

pub = RclEx.rcl_get_zero_initialized_publisher()
pub_op = RclEx.rcl_publisher_get_default_options()

IO.puts "??"
RclEx.rcl_publisher_init(pub,node,'topicname',pub_op)  #segmentation fault
IO.puts "success!!"
#RclEx.rcl_publish(pub,1)
IO.puts "published"