defmodule RclEx do
  @on_load :load_nifs
    def load_nifs do
        IO.puts "load_nifs"
        :erlang.load_nif('/home/imanishi/rclex/rclex',0)
    end
  #return rcl_init_options_t
  def rcl_get_zero_initialized_init_options do
    raise "NIF rcl_get_zero_initialized_init_options/0 not implemented"
  end

  #return rcl_context_t
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
  """
  def rcl_init(_a,_b,_c,_d) do
      raise "NIF rcl_init/4 not implemented"
  end

  @doc """
      return {:ok,rcl_ret_t}
      arguments...(
          rcl_context_t)
  """        
  def rcl_shutdown(_a) do
      raise "NIF rcl_shutdown/1 not implemented" 
  end

  #-----------------------node_nif.c---------------
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
  @doc """
      return rcl_ret_t 
      argument...rcl_node_t
  """
  def rcl_node_fini(_a) do
      raise "NIF rcl_node_fini/1 not implemented"
  end

  def create_node do
      con = rcl_get_zero_initialized_context()
      op = rcl_get_zero_initialized_init_options()
      rcl_init(0,'hello',op,con)
      
      node_op = rcl_node_get_default_options()
      zero_node = rcl_get_zero_initialized_node() |> IO.inspect
      IO.puts "unchi"
      
      rcl_node_init(zero_node,'hoge','fuga',con,node_op) |> IO.inspect
      IO.puts "success!"
  end
#------------------------------publisher_nif.c--------------------------
  def rcl_get_zero_initialized_publisher do
      raise "NIF get_zero_initialized_publisher/0 not implemented"
  end

  def rcl_publisher_get_default_options do
      raise "rcl_get_zero_initialized_publisher/0 not implemented"
  end

  def rcl_publisher_get_topic_name(_a) do
      raise "rcl_get_zero_initialized_publisher/0 not implemented"
  end

  def rcl_publisher_fini(_a,_b) do
      raise "rcl_get_zero_initialized_publisher/0 not implemented"
  end

  def rcl_publisher_init(_a,_b,_c,_d,_e) do
      raise "rcl_get_zero_initialized_publisher/0 not implemented"
  end

  def rcl_publisher_is_valid(_a) do
      raise "rcl_get_zero_initialized_publisher/0 not implemented"
  end
  def rcl_publish(_a,_b,_c) do
      raise "rcl_publish/3 not implemented"
  end

  def setting_pub do
    con = rcl_get_zero_initialized_context()
    op = rcl_get_zero_initialized_init_options()
    rcl_init(0,'hello world',op,con)
    node_op = rcl_node_get_default_options()
    node = rcl_get_zero_initialized_node()
    rcl_node_init(node,'test_node','test_namespace_',con,node_op)
    mypub = rcl_get_zero_initialized_publisher()
    mypubop = rcl_publisher_get_default_options()
    #type_support = Int16.get_message_type_from_std_msgs_msg_Int16
    #ret = Publisher.rcl_publisher_init(mypub,node,type_support,"topicname",mypubop)
    IO.puts "success!!"
  end
  def hello do
    :world
  end
end
