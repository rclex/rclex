defmodule Rclex do
  @moduledoc """
  User API for `#{__MODULE__}`.
  """

  @namespace_doc "`:namespace` must lead with \"/\". if not specified, the default is \"/\""
  @qos_doc "`:qos` if not specified, applied the default which equals return of `Rclex.QoS.profile_default/0`"
  @topic_name_doc "`topic_name` must lead with \"/\". See all [constraints](https://design.ros2.org/articles/topic_and_service_names.html#ros-2-topic-and-service-name-constraints)"
  @service_name_doc "`service_name` must lead with \"/\". See all [constraints](https://design.ros2.org/articles/topic_and_service_names.html#ros-2-topic-and-service-name-constraints)"
  @no_demangle_doc "`:no_demangle` if `true`, return all topics without any demangling. if not specified, the default is `false`"
  @no_mangle_doc "`:no_mangle` if `true`, `topic_name` needs to be a valid middleware topic name, otherwise it should be a valid ROS topic name. if not specified, the default is `false`"

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

  ### Examples

      iex> Rclex.start_node("node", namespace: "/example")
      :ok
      iex> Rclex.start_node("node", namespace: "/example")
      {:error, :already_started}
  """
  @doc section: :node
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

  ### Examples

      iex> Rclex.stop_node("node", namespace: "/example")
      :ok
      iex> Rclex.stop_node("node", namespace: "/example")
      {:error, :not_found}
  """
  @doc section: :node
  @spec stop_node(name :: String.t(), opts :: [namespace: String.t()]) ::
          :ok | {:error, :not_found}
  def stop_node(name, opts \\ []) when is_binary(name) and is_list(opts) do
    namespace = Keyword.get(opts, :namespace, "/")
    Rclex.NodesSupervisor.terminate_child(name, namespace)
  end

  @doc """
  Start a ROS publisher. fter calling this function for a `topic_name`, the node can be used to publish messages of the given type to the given topic using `publish/4`. The message type module can to be generated from .msg files by calling `mix rclex.gen.msgs`, after adding the type to `config :rclex, ros2_message_types`.

  - #{@topic_name_doc}

  ### Examples

      iex> alias Rclex.Pkgs.StdMsgs
      iex> Rclex.start_publisher(StdMsgs.Msg.String, "/chatter", "node", namespace: "/example")
      :ok
      iex> Rclex.start_publisher(StdMsgs.Msg.String, "/chatter", "node", namespace: "/example")
      {:error, :already_started}
  """
  @doc section: :publisher
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

  ### Examples

      iex> alias Rclex.Pkgs.StdMsgs
      iex> Rclex.stop_publisher(StdMsgs.Msg.String, "/chatter", "node", namespace: "/example")
      :ok
      iex> Rclex.stop_publisher(StdMsgs.Msg.String, "/chatter", "node", namespace: "/example")
      {:error, :not_found}
  """
  @doc section: :publisher
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

  ### Examples

      iex> alias Rclex.Pkgs.StdMsgs
      iex> Rclex.publish(struct(StdMsgs.Msg.String, %{data: "hello"}), "/chatter", "node", namespace: "/example")
      :ok
      iex> Rclex.publish(struct(StdMsgs.Msg.String, %{data: "hello"}), "/chatter", "node")
      {:error, :not_found}
  """
  @doc section: :publisher
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

  ### Examples

      iex> alias Rclex.Pkgs.StdMsgs
      iex> Rclex.start_subscription(&IO.inspect/1, StdMsgs.Msg.String, "/chatter", "node", namespace: "/example")
      :ok
      iex> Rclex.start_subscription(&IO.inspect/1, StdMsgs.Msg.String, "/chatter", "node", namespace: "/example")
      {:error, :already_started}
  """
  @doc section: :subscription
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

  ### Examples

      iex> alias Rclex.Pkgs.StdMsgs
      iex> Rclex.stop_subscription(StdMsgs.Msg.String, "/chatter", "node", namespace: "/example")
      :ok
      iex> Rclex.stop_subscription(StdMsgs.Msg.String, "/chatter", "node", namespace: "/example")
      {:error, :not_found}
  """
  @doc section: :subscription
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

  ### Examples

      iex> alias Rclex.Pkgs.StdSrvs
      iex> Rclex.start_service(fn _ -> %StdSrvs.Srv.SetBoolResponse{success: true} end, StdMsgs.Srv.SetBool, "/set_bool", "node", namespace: "/example")
      :ok
      iex> Rclex.start_service(fn _ -> %StdSrvs.Srv.SetBoolResponse{success: true} end, StdMsgs.Srv.SetBool, "/set_bool", "node", namespace: "/example")
      {:error, :already_started}
  """
  @doc section: :service
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

  ### Examples

      iex> alias Rclex.Pkgs.StdSrvs
      iex> Rclex.stop_service(StdSrvs.Srvg.SetBool, "/set_bool", "node", namespace: "/example")
      :ok
      iex> Rclex.stop_service(StdSrvs.Srvg.SetBool, "/does_not_exist", "node", namespace: "/example")
      {:error, :not_found}
  """
  @doc section: :service
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

  ### Examples

      iex> alias Rclex.Pkgs.StdSrvs
      iex> callback = fn _request, _response -> nil end
      iex> Rclex.start_client(callback, StdSrvs.Srv.SetBool, "/set_test_bool", "name")
      :ok
      iex> Rclex.start_client(callback, StdSrvs.Srv.SetBool, "/set_test_bool", "name")
      {:error, :already_started}
      iex> Rclex.call_async(%StdSrvs.Srv.SetBoolRequest{data: true}, "/set_bool", "node", namespace: "/example")
      :ok
  """
  @doc section: :client
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

  ### Examples

      iex> alias Rclex.Pkgs.StdSrvs
      iex> Rclex.call_async(%StdSrvs.Srv.SetBoolRequest{data: true}, "/set_bool", "node", namespace: "/example")
      :ok
  """
  @doc section: :client
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

  ### Examples

      iex> alias Rclex.Pkgs.StdSrvs
      iex> Rclex.stop_client(StdSrvs.Srvg.SetBool, "/set_bool", "node", namespace: "/example")
      :ok
      iex> Rclex.stop_client(StdSrvs.Srvg.SetBool, "/does_not_exist", "node", namespace: "/example")
      {:error, :not_found}
  """
  @doc section: :client
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

  ### Examples

      iex> Rclex.start_timer(1000, fn -> IO.inspect("tick") end, "tick", "node", namespace: "/example")
      :ok
      iex> Rclex.start_timer(1000, fn -> IO.inspect("tick") end, "tick", "node", namespace: "/example")
      {:error, :already_started}
  """
  @doc section: :time
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

  ### Examples

      iex> Rclex.stop_timer("tick", "node", namespace: "/example")
      :ok
      iex> Rclex.stop_timer("tick", "node", namespace: "/example")
      {:error, :not_found}
  """
  @doc section: :time
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

  @doc """
  Return the number of publishers on a given topic.

  - #{@topic_name_doc}

  ### opts

  - #{@namespace_doc}

  ### Examples

      iex> alias Rclex.Pkgs.StdMsgs
      iex> Rclex.start_publisher(StdMsgs.Msg.String, "/chatter", "node", namespace: "/example")
      :ok
      iex> Rclex.count_publishers("node", "/chatter", namespace: "/example")
      1
  """
  @doc section: :graph
  @spec count_publishers(
          name :: String.t(),
          topic_name :: topic_name(),
          opts :: [namespace: String.t()]
        ) :: non_neg_integer()
  def count_publishers(name, topic_name, opts \\ [])
      when is_binary(name) and is_binary(topic_name) and is_list(opts) do
    namespace = Keyword.get(opts, :namespace, "/")
    Rclex.Node.count_publishers(name, namespace, topic_name)
  end

  @doc """
  Return the number of subscriptions on a given topic.

  - #{@topic_name_doc}

  ### opts

  - #{@namespace_doc}

  ### Examples

      iex> alias Rclex.Pkgs.StdMsgs
      iex> Rclex.start_subscription(&IO.inspect/1, StdMsgs.Msg.String, "/chatter", "node", namespace: "/example")
      :ok
      iex> Rclex.count_subscribers("node", "/chatter", namespace: "/example")
      1
  """
  @doc section: :graph
  @spec count_subscribers(
          name :: String.t(),
          topic_name :: topic_name(),
          opts :: [namespace: String.t()]
        ) :: non_neg_integer()
  def count_subscribers(name, topic_name, opts \\ [])
      when is_binary(name) and is_binary(topic_name) and is_list(opts) do
    namespace = Keyword.get(opts, :namespace, "/")
    Rclex.Node.count_subscribers(name, namespace, topic_name)
  end

  @doc """
  Return a list of discovered service client topics and its types for a remote node.

  ### opts

  - #{@namespace_doc}

  ### Examples

      iex> Rclex.get_client_names_and_types_by_node("node", "example_node", namespace: "/example")
      [{"node","/example"}]
  """
  @doc section: :graph
  @spec get_client_names_and_types_by_node(
          name :: String.t(),
          node_name :: String.t(),
          node_namespace :: String.t(),
          opts :: [namespace: String.t()]
        ) :: list()
  def get_client_names_and_types_by_node(
        name,
        node_name,
        node_namespace,
        opts \\ []
      )
      when is_binary(name) and is_binary(node_name) and is_binary(node_namespace) and
             is_list(opts) do
    namespace = Keyword.get(opts, :namespace, "/")
    Rclex.Node.get_client_names_and_types_by_node(name, namespace, node_name, node_namespace)
  end

  @doc """
  Return a list of available nodes in the ROS graph.

  ### opts

  - #{@namespace_doc}

  ### Examples

      iex> Rclex.get_node_names("node", namespace: "/example")
      [{"node","/example"}]
  """
  @doc section: :graph
  @spec get_node_names(name :: String.t(), opts :: [namespace: String.t()]) :: [
          {String.t(), String.t()}
        ]
  def get_node_names(name, opts \\ [])
      when is_binary(name) and is_list(opts) do
    namespace = Keyword.get(opts, :namespace, "/")
    Rclex.Node.get_node_names(name, namespace)
  end

  @doc """
  Return a list of available nodes in the ROS graph, including their enclave names.

  ### opts

  - #{@namespace_doc}

  ### Examples

      iex> Rclex.get_node_names_with_enclaves("node", namespace: "/example")
      [{"node", "/example", "/"}]
  """
  @doc section: :graph
  @spec get_node_names_with_enclaves(name :: String.t(), opts :: [namespace: String.t()]) :: [
          {String.t(), String.t(), String.t()}
        ]
  def get_node_names_with_enclaves(name, opts \\ [])
      when is_binary(name) and is_list(opts) do
    namespace = Keyword.get(opts, :namespace, "/")
    Rclex.Node.get_node_names_with_enclaves(name, namespace)
  end

  @doc """
  Return a list of topic names and types for publishers associated with a node.

  ### opts

  - #{@namespace_doc}
  - #{@no_demangle_doc}

  ### Examples

      iex> Rclex.get_publisher_names_and_types_by_node("node", "node", "/example", namespace: "/example")
      [{"/chatter", ["std_msgs/msg/String"]}]
  """
  @doc section: :graph
  @spec get_publisher_names_and_types_by_node(
          name :: String.t(),
          node_name :: String.t(),
          node_namespace :: String.t(),
          opts :: [namespace: String.t(), no_demangle: boolean()]
        ) :: [{String.t(), [String.t()]}] | {:error, :not_found}
  def get_publisher_names_and_types_by_node(name, node_name, node_namespace, opts \\ []) do
    namespace = Keyword.get(opts, :namespace, "/")
    no_demangle = Keyword.get(opts, :no_demangle, false)

    Rclex.Node.get_publisher_names_and_types_by_node(
      name,
      namespace,
      node_name,
      node_namespace,
      no_demangle
    )
  end

  @doc """
  Return a list of all publishers to a topic.

  ### opts

  - #{@namespace_doc}
  - #{@no_mangle_doc}

  ### Examples

      iex> Rclex.get_publishers_info_by_topic("node", "/chatter", "/example")
      [
              %{
                node_name: "node",
                node_namespace: "/example",
                topic_type: "std_msgs/msg/String",
                endpoint_type: 1,
                endpoint_gid: ...,
                qos_profile: ...
              }
      ]
  """
  @doc section: :graph
  @spec get_publishers_info_by_topic(
          name :: String.t(),
          topic_name :: topic_name(),
          opts :: [namespace: String.t(), no_mangle: boolean()]
        ) :: list()
  def get_publishers_info_by_topic(name, topic_name, opts \\ []) do
    namespace = Keyword.get(opts, :namespace, "/")
    no_mangle = Keyword.get(opts, :no_mangle, false)

    Rclex.Node.get_publishers_info_by_topic(
      name,
      namespace,
      topic_name,
      no_mangle
    )
  end

  @doc """
  Return a list of service names and their types.

  ### opts

  - #{@namespace_doc}

  ### Examples

      iex> Rclex.get_service_names_and_types("node", namespace: "/example")
      [{"/set_test_bool", ["std_srvs/srv/SetBool"]}]
  """
  @doc section: :graph
  @spec get_service_names_and_types(
          name :: String.t(),
          opts :: [namespace: String.t()]
        ) :: list()
  def get_service_names_and_types(name, opts \\ []) do
    namespace = Keyword.get(opts, :namespace, "/")
    Rclex.Node.get_service_names_and_types(name, namespace)
  end

  @doc """
  Return a list of service names and types associated with a node.

  ### opts

  - #{@namespace_doc}

  ### Examples

      iex> Rclex.get_service_names_and_types_by_node("node", "example_node", "/example", namespace: "/example")
      [{"/set_test_bool", ["std_srvs/srv/SetBool"]}]
  """
  @doc section: :graph
  @spec get_service_names_and_types_by_node(
          name :: String.t(),
          node_name :: String.t(),
          node_namespace :: String.t(),
          opts :: [namespace: String.t()]
        ) :: list()
  def get_service_names_and_types_by_node(name, node_name, node_namespace, opts \\ []) do
    namespace = Keyword.get(opts, :namespace, "/")
    Rclex.Node.get_service_names_and_types_by_node(name, namespace, node_name, node_namespace)
  end

  @doc """
  Return a list of topic names and types for subscriptions associated with a node.

  ### opts

  - #{@namespace_doc}
  - #{@no_demangle_doc}

  ### Examples

      iex> Rclex.get_subscriber_names_and_types_by_node("node", "node", "/example", namespace: "/example")
      [{"/chatter", ["std_msgs/msg/String"]}]
  """
  @doc section: :graph
  @spec get_subscriber_names_and_types_by_node(
          name :: String.t(),
          node_name :: String.t(),
          node_namespace :: String.t(),
          opts :: [namespace: String.t(), no_demangle: boolean()]
        ) :: [{String.t(), [String.t()]}] | {:error, :not_found}
  def get_subscriber_names_and_types_by_node(name, node_name, node_namespace, opts \\ []) do
    namespace = Keyword.get(opts, :namespace, "/")
    no_demangle = Keyword.get(opts, :no_demangle, false)

    Rclex.Node.get_subscriber_names_and_types_by_node(
      name,
      namespace,
      node_name,
      node_namespace,
      no_demangle
    )
  end

  @doc """
  Return a list of all subscribers to a topic.

  ### opts

  - #{@namespace_doc}
  - #{@no_mangle_doc}

  ### Examples

      iex> Rclex.get_subscribers_info_by_topic("node", "/chatter", "/example")
      [
              %{
                node_name: "node",
                node_namespace: "/example",
                topic_type: "std_msgs/msg/String",
                endpoint_type: 1,
                endpoint_gid: ...,
                qos_profile: ...
              }
      ]
  """
  @doc section: :graph
  @spec get_subscribers_info_by_topic(
          name :: String.t(),
          topic_name :: topic_name(),
          opts :: [namespace: String.t(), no_mangle: boolean()]
        ) :: list()
  def get_subscribers_info_by_topic(name, topic_name, opts \\ []) do
    namespace = Keyword.get(opts, :namespace, "/")
    no_mangle = Keyword.get(opts, :no_mangle, false)

    Rclex.Node.get_subscribers_info_by_topic(
      name,
      namespace,
      topic_name,
      no_mangle
    )
  end

  @doc """
  Return a list of topic names and their types.

  ### opts

  - #{@namespace_doc}
  - #{@no_demangle_doc}

  ### Examples

      iex> Rclex.get_subscriber_names_and_types_by_node("node", "node", "/example", namespace: "/example")
      [{"/chatter", ["std_msgs/msg/String"]}]
  """
  @doc section: :graph
  @spec get_topic_names_and_types(
          name :: String.t(),
          opts :: [namespace: String.t(), no_demangle: boolean()]
        ) :: [{String.t(), [String.t()]}]
  def get_topic_names_and_types(name, opts \\ []) do
    namespace = Keyword.get(opts, :namespace, "/")
    no_demangle = Keyword.get(opts, :no_demangle, false)
    Rclex.Node.get_topic_names_and_types(name, namespace, no_demangle)
  end

  @doc """
  Check if a service server is available for the given service client.
  This function will return true, if there is a service server available for the given client.

  - #{@service_name_doc}

  ### opts

  - #{@namespace_doc}

  ### Examples

      iex> Rclex.service_server_available?("node", "/set_bool", namespace: "/example")
      :false
  """
  @doc section: :graph
  @spec service_server_available?(
          name :: String.t(),
          service_type :: module(),
          service_name :: service_name(),
          opts :: [namespace: String.t()]
        ) :: boolean
  def service_server_available?(service_type, service_name, name, opts \\ []) do
    namespace = Keyword.get(opts, :namespace, "/")
    Rclex.Client.service_server_available?(service_type, service_name, name, namespace)
  end
end
