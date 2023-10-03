defmodule Rclex do
  @moduledoc """
  Documentation for `Rclex`.
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

  @spec start_publisher(
          message_type :: module(),
          topic_name :: String.t(),
          name :: String.t(),
          namespace :: String.t()
        ) ::
          :ok | {:error, :already_started} | {:error, term()}
  def start_publisher(message_type, topic_name, name, namespace \\ "/")
      when is_atom(message_type) and is_binary(topic_name) and is_binary(name) and
             is_binary(namespace) do
    case Rclex.Node.start_publisher(message_type, topic_name, name, namespace) do
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
          namespace :: String.t()
        ) ::
          :ok | {:error, :already_started} | {:error, term()}
  def start_subscription(callback, message_type, topic_name, name, namespace \\ "/")
      when is_function(callback) and is_atom(message_type) and is_binary(topic_name) and
             is_binary(name) and
             is_binary(namespace) do
    case Rclex.Node.start_subscription(callback, message_type, topic_name, name, namespace) do
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
end
