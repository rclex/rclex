defmodule Rclex do
  @moduledoc """
  User API for `#{__MODULE__}`.
  """

  @namespace_doc "`:namespace` must lead with \"/\". if not specified, the default is \"/\""
  @qos_doc "`:qos` if not specified, applied the default which equals return of `Rclex.QoS.profile_default/0`"
  @topic_name_doc "`topic_name` must lead with \"/\". See all [constraints](https://design.ros2.org/articles/topic_and_service_names.html#ros-2-topic-and-service-name-constraints)"
  @service_name_doc "`service_name` must lead with \"/\". See all [constraints](https://design.ros2.org/articles/topic_and_service_names.html#ros-2-topic-and-service-name-constraints)"

  @typedoc "#{@topic_name_doc}."
  @type topic_name :: String.t()

  @typedoc "#{@service_name_doc}."
  @type service_name :: String.t()

  @doc """
  Start a ROS node. The name of the node must not be `nil` and cannot coincide with another node of the same name.
  Node names must follow these rules:
  - must not be an empty string
  - must only contain alphanumeric characters and underscores (a-z|A-Z|0-9|_)
  - must not start with a number

  ### opts

  - #{@namespace_doc}

  ## Examples

      iex> Rclex.start_node("node", namespace: "/example")
      :ok
      iex> Rclex.start_node("node", namespace: "/example")
      {:error, :already_started}
  """
  @spec start_node(name :: String.t(), opts :: [namespace: String.t()]) ::
          :ok | {:error, :already_started} | {:error, term()}
  def start_node(name, opts \\ []) when is_binary(name) and is_list(opts) do
    context = Rclex.Context.get()
    namespace = Keyword.get(opts, :namespace, "/")

    case Rclex.NodesSupervisor.start_child(context, name, namespace) do
      {:ok, _pid} -> :ok
      {:error, {:already_started, _pid}} -> {:error, :already_started}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Stop a ROS node. And also stop the entities on the node, `publisher`, `subscription`, `service`, `client` and `timer`.

  ### opts

  - #{@namespace_doc}

  ## Examples

      iex> Rclex.stop_node("node", namespace: "/example")
      :ok
      iex> Rclex.stop_node("node", namespace: "/example")
      {:error, :not_found}
  """
  @spec stop_node(name :: String.t(), opts :: [namespace: String.t()]) ::
          :ok | {:error, :not_found}
  def stop_node(name, opts \\ []) when is_binary(name) and is_list(opts) do
    namespace = Keyword.get(opts, :namespace, "/")
    Rclex.NodesSupervisor.terminate_child(name, namespace)
  end

  @doc """
  Start a ROS publisher. fter calling this function for a `topic_name`, the node can be used to publish messages of the given type to the given topic using `publish/4`. The message type module can to be generated from .msg files by calling `mix rclex.gen.msgs`, after adding the type to `config :rclex, ros2_message_types`.

  - #{@topic_name_doc}

  ## Examples

      iex> alias Rclex.Pkgs.StdMsgs
      iex> Rclex.start_publisher(StdMsgs.Msg.String, "/chatter", "node", namespace: "/example")
      :ok
      iex> Rclex.start_publisher(StdMsgs.Msg.String, "/chatter", "node", namespace: "/example")
      {:error, :already_started}
  """
  @spec start_publisher(
          message_type :: module(),
          topic_name :: topic_name(),
          node_name :: String.t(),
          opts :: [namespace: String.t(), qos: Rclex.QoS.t()]
        ) ::
          :ok | {:error, :already_started} | {:error, term()}
  def start_publisher(message_type, topic_name, node_name, opts \\ [])
      when is_atom(message_type) and is_binary(topic_name) and is_binary(node_name) and
             is_list(opts) do
    namespace = Keyword.get(opts, :namespace, "/")
    qos = Keyword.get(opts, :qos, Rclex.QoS.profile_default())

    case Rclex.Node.start_publisher(message_type, topic_name, node_name, namespace, qos) do
      {:ok, _pid} -> :ok
      {:error, {:already_started, _pid}} -> {:error, :already_started}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Stop a ROS publisher. After calling, the node will no longer be advertising that it
  is publishing on this topic (assuming this is the only publisher on this topic) and
  calls to `publish/4` will fail when using this publisher.

  - #{@topic_name_doc}

  ### opts

  - #{@namespace_doc}

  ## Examples

      iex> alias Rclex.Pkgs.StdMsgs
      iex> Rclex.stop_publisher(StdMsgs.Msg.String, "/chatter", "node", namespace: "/example")
      :ok
      iex> Rclex.stop_publisher(StdMsgs.Msg.String, "/chatter", "node", namespace: "/example")
      {:error, :not_found}
  """
  @spec stop_publisher(
          message_type :: module(),
          topic_name :: topic_name(),
          node_name :: String.t(),
          opts :: [namespace: String.t()]
        ) ::
          :ok | {:error, :not_found}
  def stop_publisher(message_type, topic_name, name, opts \\ [])
      when is_atom(message_type) and is_binary(topic_name) and is_binary(name) and is_list(opts) do
    namespace = Keyword.get(opts, :namespace, "/")
    Rclex.Node.stop_publisher(message_type, topic_name, name, namespace)
  end

  @doc """
  Publish a ROS message on a topic using a publisher.

  - #{@topic_name_doc}

  ### opts

  - #{@namespace_doc}

  ## Examples

      iex> alias Rclex.Pkgs.StdMsgs
      iex> Rclex.publish(struct(StdMsgs.Msg.String, %{data: "hello"}), "/chatter", "node", namespace: "/example")
      :ok
      iex> Rclex.publish(struct(StdMsgs.Msg.String, %{data: "hello"}), "/chatter", "node")
      {:error, :not_found}
  """
  @spec publish(
          message :: struct(),
          topic_name :: topic_name(),
          node_name :: String.t(),
          opts :: [namespace: String.t()]
        ) :: :ok | {:error, :not_found}
  def publish(message, topic_name, node_name, opts \\ [])
      when is_struct(message) and is_binary(topic_name) and is_binary(node_name) and is_list(opts) do
    namespace = Keyword.get(opts, :namespace, "/")
    Rclex.Publisher.publish(message, topic_name, node_name, namespace)
  end

  @doc """
  Start a ROS subscription. After calling this function, the callback is called for new messages
  of the given `message_type` to the given `topic_name`. The given `node_name` must be valid and
  the resulting subscription is only valid as long as the given node remains valid.
  The message type module can to be generated from .msg files by calling `mix rclex.gen.msgs`,
  after adding the type to `config :rclex, ros2_message_types`.

  - #{@topic_name_doc}

  ### opts

  - #{@namespace_doc}
  - #{@qos_doc}

  ## Examples

      iex> alias Rclex.Pkgs.StdMsgs
      iex> Rclex.start_subscription(&IO.inspect/1, StdMsgs.Msg.String, "/chatter", "node", namespace: "/example")
      :ok
      iex> Rclex.start_subscription(&IO.inspect/1, StdMsgs.Msg.String, "/chatter", "node", namespace: "/example")
      {:error, :already_started}
  """
  @spec start_subscription(
          callback :: function(),
          message_type :: module(),
          topic_name :: topic_name(),
          node_name :: String.t(),
          opts :: [namespace: String.t(), qos: Rclex.QoS.t()]
        ) ::
          :ok | {:error, :already_started} | {:error, term()}
  def start_subscription(callback, message_type, topic_name, node_name, opts \\ [])
      when is_function(callback) and is_atom(message_type) and is_binary(topic_name) and
             is_binary(node_name) and is_list(opts) do
    namespace = Keyword.get(opts, :namespace, "/")
    qos = Keyword.get(opts, :qos, Rclex.QoS.profile_default())

    case Rclex.Node.start_subscription(
           callback,
           message_type,
           topic_name,
           node_name,
           namespace,
           qos
         ) do
      {:ok, _pid} -> :ok
      {:error, {:already_started, _pid}} -> {:error, :already_started}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Stop a ROS subscription. After calling, the node will no longer be subscribed on this topic. However, the given node is still valid.

  - #{@topic_name_doc}

  ### opts

  - #{@namespace_doc}

  ## Examples

      iex> alias Rclex.Pkgs.StdMsgs
      iex> Rclex.stop_subscription(StdMsgs.Msg.String, "/chatter", "node", namespace: "/example")
      :ok
      iex> Rclex.stop_subscription(StdMsgs.Msg.String, "/chatter", "node", namespace: "/example")
      {:error, :not_found}
  """
  @spec stop_subscription(
          message_type :: module(),
          topic_name :: topic_name(),
          node_name :: String.t(),
          opts :: [namespace: String.t()]
        ) ::
          :ok | {:error, :not_found}
  def stop_subscription(message_type, topic_name, node_name, opts \\ [])
      when is_atom(message_type) and is_binary(topic_name) and is_binary(node_name) and
             is_list(opts) do
    namespace = Keyword.get(opts, :namespace, "/")
    Rclex.Node.stop_subscription(message_type, topic_name, node_name, namespace)
  end

  @doc """
    Start a ROS service. After calling this function for a ROS service type, the callback is called
    with a parameter of the corresponding request type, expecting a result of the response type
    of the service type. The given `node_name` must be valid and the resulting service is only
    valid as long as the given node remains valid.

    The message type modules for request and response can to be generated by running `mix rclex.gen.msgs`,
    after adding the service type to `config :rclex, ros2_service_types`. The service type is generated by
    running `mix rclex.gen.srvs`.

    - #{@service_name_doc}

    ### opts

    - #{@namespace_doc}
    - #{@qos_doc}

    ## Examples

    iex> alias Rclex.Pkgs.StdSrvs
    iex> Rclex.start_service(fn _ -> %StdSrvs.Srv.SetBoolResponse{success: true} end, StdMsgs.Srv.SetBool, "/set_bool", "node", namespace: "/example")
    :ok
    iex> Rclex.start_service(fn _ -> %StdSrvs.Srv.SetBoolResponse{success: true} end, StdMsgs.Srv.SetBool, "/set_bool", "node", namespace: "/example")
    {:error, :already_started}
  """
  @spec start_service(
          callback :: function(),
          service_type :: module(),
          service_name :: service_name(),
          node_name :: String.t(),
          opts :: [namespace: String.t(), qos: Rclex.QoS.t()]
        ) ::
          :ok | {:error, :already_started} | {:error, term()}
  def start_service(callback, service_type, service_name, node_name, opts \\ [])
      when is_function(callback) and is_atom(service_type) and is_binary(service_name) and
             is_binary(node_name) and is_list(opts) do
    namespace = Keyword.get(opts, :namespace, "/")
    qos = Keyword.get(opts, :qos, Rclex.QoS.profile_services_default())

    case Rclex.Node.start_service(
           callback,
           service_type,
           service_name,
           node_name,
           namespace,
           qos
         ) do
      {:ok, _pid} -> :ok
      {:error, {:already_started, _pid}} -> {:error, :already_started}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Stop a ROS service. After calling, the node will no longer listen for requests for this service.

  - #{@service_name_doc}

  ### opts

  - #{@namespace_doc}

  ## Examples

    iex> alias Rclex.Pkgs.StdSrvs
    iex> Rclex.stop_service(StdSrvs.Srvg.SetBool, "/set_bool", "node", namespace: "/example")
    :ok
    iex> Rclex.stop_service(StdSrvs.Srvg.SetBool, "/does_not_exist", "node", namespace: "/example")
    {:error, :not_found}
  """
  @spec stop_service(
          service_type :: module(),
          service_name :: service_name(),
          node_name :: String.t(),
          opts :: [namespace: String.t()]
        ) ::
          :ok | {:error, :not_found}
  def stop_service(service_type, service_name, node_name, opts \\ [])
      when is_atom(service_type) and is_binary(service_name) and is_binary(node_name) and
             is_list(opts) do
    namespace = Keyword.get(opts, :namespace, "/")
    Rclex.Node.stop_service(service_type, service_name, node_name, namespace)
  end

  @doc """
    Start a ROS client. After calling this function for a ROS `service_type`, it can be used to
    send requests of the given type to the service server. If the request is received by
    a (possibly remote) service and if the service sends a response,
    the callback with a response of the service response type is called.
    The given `node_name` must be valid and the resulting client is only valid as long as the given node remains valid.

    The message type modules for request and response can to be generated by running `mix rclex.gen.msgs`,
    after adding the service type to `config :rclex, ros2_service_types`. The service type is generated by
    running `mix rclex.gen.srvs`.

    - #{@service_name_doc}

    ### opts

    - #{@namespace_doc}
    - #{@qos_doc}

    ## Examples

    iex> alias Rclex.Pkgs.StdSrvs
    iex> callback = fn _request, _response -> nil end
    iex> Rclex.start_client(callback, StdSrvs.Srv.SetBool, "/set_test_bool", "name")
    :ok
    iex> Rclex.start_client(callback, StdSrvs.Srv.SetBool, "/set_test_bool", "name")
    {:error, :already_started}
    iex> Rclex.call_async(%StdSrvs.Srv.SetBoolRequest{data: true}, "/set_bool", "node", namespace: "/example")
    :ok
  """
  @spec start_client(
          callback :: function(),
          service_type :: module(),
          service_name :: service_name(),
          node_name :: String.t(),
          opts :: [namespace: String.t(), qos: Rclex.QoS.t()]
        ) ::
          :ok | {:error, :already_started} | {:error, term()}
  def start_client(callback, service_type, service_name, node_name, opts \\ [])
      when is_function(callback) and is_atom(service_type) and is_binary(service_name) and
             is_binary(node_name) and is_list(opts) do
    namespace = Keyword.get(opts, :namespace, "/")
    qos = Keyword.get(opts, :qos, Rclex.QoS.profile_services_default())

    case Rclex.Node.start_client(
           callback,
           service_type,
           service_name,
           node_name,
           namespace,
           qos
         ) do
      {:ok, _pid} -> :ok
      {:error, {:already_started, _pid}} -> {:error, :already_started}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
    Call a ROS service asynchronously using an initialized client. The callback of the client is called with the returned response.


    - #{@service_name_doc}

    ### opts

    - #{@namespace_doc}

    ## Examples

    iex> alias Rclex.Pkgs.StdSrvs
    iex> Rclex.call_async(%StdSrvs.Srv.SetBoolRequest{data: true}, "/set_bool", "node", namespace: "/example")
    :ok
  """
  @spec call_async(
          request :: struct(),
          service_name :: service_name(),
          node_name :: String.t(),
          opts :: [namespace: String.t()]
        ) ::
          :ok | {:error, :not_found} | {:error, term()}
  def call_async(request, service_name, node_name, opts \\ [])
      when is_binary(service_name) and
             is_binary(node_name) and is_list(opts) do
    namespace = Keyword.get(opts, :namespace, "/")

    Rclex.Client.call_async(
      request,
      service_name,
      node_name,
      namespace
    )
  end

  @doc """
  Stop ROS client. After calling this function, calls `call_async/4` will with `{:error, :not_found}` when using this client. However, the given node is still valid.

  - #{@service_name_doc}

  ### opts

  - #{@namespace_doc}

  ## Examples

    iex> alias Rclex.Pkgs.StdSrvs
    iex> Rclex.stop_client(StdSrvs.Srvg.SetBool, "/set_bool", "node", namespace: "/example")
    :ok
    iex> Rclex.stop_client(StdSrvs.Srvg.SetBool, "/does_not_exist", "node", namespace: "/example")
    {:error, :not_found}
  """
  @spec stop_client(
          service_type :: module(),
          service_name :: service_name(),
          node_name :: String.t(),
          opts :: [namespace: String.t()]
        ) ::
          :ok | {:error, :not_found}
  def stop_client(service_type, service_name, node_name, opts \\ [])
      when is_atom(service_type) and is_binary(service_name) and is_binary(node_name) and
             is_list(opts) do
    namespace = Keyword.get(opts, :namespace, "/")
    Rclex.Node.stop_client(service_type, service_name, node_name, namespace)
  end

  @doc """
  Start a timer. A timer required a period in milliseconds, a callback function, a name and a node. The callback gets called, when the defined period passed.

  ### opts

  - #{@namespace_doc}

  ## Examples

      iex> Rclex.start_timer(1000, fn -> IO.inspect("tick") end, "tick", "node", namespace: "/example")
      :ok
      iex> Rclex.start_timer(1000, fn -> IO.inspect("tick") end, "tick", "node", namespace: "/example")
      {:error, :already_started}
  """
  @spec start_timer(
          period_ms :: non_neg_integer(),
          callback :: function(),
          timer_name :: String.t(),
          node_name :: String.t(),
          opts :: [namespace: String.t()]
        ) ::
          :ok | {:error, :already_started} | {:error, term()}
  def start_timer(period_ms, callback, timer_name, node_name, opts \\ [])
      when is_integer(period_ms) and is_function(callback) and is_binary(timer_name) and
             is_binary(node_name) and is_list(opts) do
    namespace = Keyword.get(opts, :namespace, "/")

    case Rclex.Node.start_timer(period_ms, callback, timer_name, node_name, namespace) do
      {:ok, _pid} -> :ok
      {:error, {:already_started, _pid}} -> {:error, :already_started}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Stop a timer. This function will deallocate any memory and make the timer invalid. For a timer that is already invalid, `{:error, :not_found}` is returned.

  ### opts

  - #{@namespace_doc}

  ## Examples

      iex> Rclex.stop_timer("tick", "node", namespace: "/example")
      :ok
      iex> Rclex.stop_timer("tick", "node", namespace: "/example")
      {:error, :not_found}
  """
  @spec stop_timer(
          timer_name :: String.t(),
          node_name :: String.t(),
          opts :: [namespace: String.t()]
        ) ::
          :ok | {:error, :not_found}
  def stop_timer(timer_name, node_name, opts \\ [])
      when is_binary(timer_name) and is_binary(node_name) and is_list(opts) do
    namespace = Keyword.get(opts, :namespace, "/")
    Rclex.Node.stop_timer(timer_name, node_name, namespace)
  end
end
