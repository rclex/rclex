defmodule Rclex do
  @moduledoc """
  User API of `Rclex` to use ROS 2 in elixir.

  For now it allows to create publisher, subscribers and timers.

  ## Usage

  Invoke `Rclex.start_node/2` with a name and namespace.

  ```elixir
  iex> :ok = Rclex.start_node("name", "/")
  iex> :ok = Rclex.start_publisher(StdMsgs.Msg.String, topic_name, "name", "/", [reliability: :reliable])
  iex> :ok = Rclex.stop_node("name", "/")
  ```
  """



  @spec start_node(name :: String.t(), namespace :: String.t()) ::
          :ok | {:error, :already_started} | {:error, term()}
  def start_node(name, namespace \\ "/") when is_binary(name) and is_binary(namespace) do
    context = Rclex.Context.get()

    case Rclex.NodesSupervisor.start_child(context, name, namespace) do
      {:ok, _pid} -> :ok
      {:error, {:already_started, _pid}} -> {:error, :already_started}
      {:error, reason} -> {:error, reason}
    end
  end

  @spec stop_node(name :: String.t(), namespace :: String.t()) ::
          :ok | {:error, :not_found}
  def stop_node(name, namespace \\ "/") when is_binary(name) and is_binary(namespace) do
    Rclex.NodesSupervisor.terminate_child(name, namespace)
  end


  @doc """
  Start a new publisher. Before a publisher can be started a node with according name has to be started in the same namespace.

  ## ROS 2 publisher

  A ROS 2 publisher send messages of a specific type This message type is represented by the elixir module name, that was generated for the ROS 2 message by `mix rclex.gen.msgs`.
  Only messages of this type can be published by this publisher. Message a published to a topic. Topics names are expected to start with a leading slash.

  ## QoS Options

        * `:history` - Possible values are:

          * `:keep_all` - Store all samples, subject to resource limits.
          * `:keep_last` - Only store up to a maximum number of samples, dropping oldest

        * `:depth` - 123,

        * `:reliability` - Possible values are:

          * `:best_effort` - Attempt to deliver samples, but some may be lost if the network is not robust.
          * `:reliable` - Guarantee that samples are delivered, may retry multiple times.

        * `:durability` - Possible values are:

          * `:transient_local` - The rmw publisher is responsible for persisting samples for “late-joining” subscribers.
          * `:volatile` - Samples are not persistent.


        * `:deadline` - 123,
        * `:lifespan` - 123,
        * `:liveliness` - Possible values are:

          * `:automatic` - The signal that establishes a Topic is alive comes from the ROS rmw layer.
          * `:manual_by_topic` - The signal that establishes a topic is alive is at the topic level.
                                 Only publishing a message on the topic or an explicit signal from the
                                 application to assert liveliness on the topic will mark the topic as
                                 being alive.

        * `:liveliness_lease_duration` - 123,

        * `:avoid_ros_namespace_conventions` - true

  ## Compability of QoS Options


  ## Examples

  iex> :ok = Rclex.start_node("name", "/")
  iex> :ok = Rclex.start_publisher(StdMsgs.Msg.String, topic_name, "name", "/", [reliability: :reliable])
  iex> :ok = Rclex.stop_node("name", "/")
  """
  @spec start_publisher(
          message_type :: module(),
          topic_name :: String.t(),
          name :: String.t(),
          namespace :: String.t(),
          qos :: list()
        ) ::
          :ok | {:error, :already_started} | {:error, term()}
  def start_publisher(message_type, topic_name, name, namespace \\ "/", qos \\ [])
      when is_atom(message_type) and is_binary(topic_name) and is_binary(name) and
             is_binary(namespace) and is_list(qos) do
    case Rclex.Node.start_publisher(message_type, topic_name, name, namespace, qos) do
      {:ok, _pid} -> :ok
      {:error, {:already_started, _pid}} -> {:error, :already_started}
      {:error, reason} -> {:error, reason}
    end
  end

  @spec stop_publisher(
          message_type :: module(),
          topic_name :: String.t(),
          name :: String.t(),
          namespace :: String.t()
        ) ::
          :ok | {:error, :not_found}
  def stop_publisher(message_type, topic_name, name, namespace \\ "/")
      when is_atom(message_type) and is_binary(topic_name) and is_binary(name) and
             is_binary(namespace) do
    Rclex.Node.stop_publisher(message_type, topic_name, name, namespace)
  end

  @spec publish(
          message :: struct(),
          topic_name :: String.t(),
          name :: String.t(),
          namespace :: String.t()
        ) ::
          :ok
  def publish(message, topic_name, name, namespace \\ "/")
      when is_struct(message) and is_binary(topic_name) and is_binary(name) and
             is_binary(namespace) do
    Rclex.Publisher.publish(message, topic_name, name, namespace)
  end

  @spec start_subscription(
          callback :: function(),
          message_type :: module(),
          topic_name :: String.t(),
          name :: String.t(),
          namespace :: String.t(),
          qos :: list()
        ) ::
          :ok | {:error, :already_started} | {:error, term()}
  def start_subscription(callback, message_type, topic_name, name, namespace \\ "/", qos \\ [])
      when is_function(callback) and is_atom(message_type) and is_binary(topic_name) and
             is_binary(name) and
             is_binary(namespace) and is_list(qos) do
    case Rclex.Node.start_subscription(callback, message_type, topic_name, name, namespace, qos) do
      {:ok, _pid} -> :ok
      {:error, {:already_started, _pid}} -> {:error, :already_started}
      {:error, reason} -> {:error, reason}
    end
  end

  @spec stop_subscription(
          message_type :: module(),
          topic_name :: String.t(),
          name :: String.t(),
          namespace :: String.t()
        ) ::
          :ok | {:error, :not_found}
  def stop_subscription(message_type, topic_name, name, namespace \\ "/")
      when is_atom(message_type) and is_binary(topic_name) and is_binary(name) and
             is_binary(namespace) do
    Rclex.Node.stop_subscription(message_type, topic_name, name, namespace)
  end

  @spec start_timer(
          period_ms :: non_neg_integer(),
          callback :: function(),
          timer_name :: String.t(),
          name :: String.t(),
          namespace :: String.t()
        ) ::
          :ok | {:error, :already_started} | {:error, term()}
  def start_timer(period_ms, callback, timer_name, name, namespace \\ "/")
      when is_integer(period_ms) and is_function(callback) and is_binary(timer_name) and
             is_binary(name) and is_binary(namespace) do
    case Rclex.Node.start_timer(period_ms, callback, timer_name, name, namespace) do
      {:ok, _pid} -> :ok
      {:error, {:already_started, _pid}} -> {:error, :already_started}
      {:error, reason} -> {:error, reason}
    end
  end

  @spec stop_timer(
          timer_name :: String.t(),
          name :: String.t(),
          namespace :: String.t()
        ) ::
          :ok | {:error, :not_found}
  def stop_timer(timer_name, name, namespace \\ "/")
      when is_binary(timer_name) and is_binary(name) and is_binary(namespace) do
    Rclex.Node.stop_timer(timer_name, name, namespace)
  end
end
