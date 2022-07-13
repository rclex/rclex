defmodule Rclex.TestUtils do
  @moduledoc false

  alias Rclex.Nifs

  def get_initialized_context() do
    options = Nifs.rcl_get_zero_initialized_init_options()
    :ok = Nifs.rcl_init_options_init(options)
    context = Nifs.rcl_get_zero_initialized_context()
    Nifs.rcl_init_with_null(options, context)
    Nifs.rcl_init_options_fini(options)

    context
  end

  def get_initialized_no_namespace_node(context, node_name \\ 'node') do
    node = Nifs.rcl_get_zero_initialized_node()
    options = Nifs.rcl_node_get_default_options()

    Nifs.rcl_node_init_without_namespace(node, node_name, context, options)
  end

  def get_initialized_publisher(
        node,
        topic \\ 'topic',
        message_type \\ 'StdMsgs.Msg.String',
        publisher_options \\ Nifs.rcl_publisher_get_default_options()
      ) do
    publisher = Nifs.rcl_get_zero_initialized_publisher()
    typesupport = Rclex.Msg.typesupport(message_type)

    Nifs.rcl_publisher_init(publisher, node, topic, typesupport, publisher_options)
  end

  def get_initialized_subscription(
        node,
        topic \\ 'topic',
        message_type \\ 'StdMsgs.Msg.String',
        subscription_options \\ Nifs.rcl_subscription_get_default_options()
      ) do
    subscription = Nifs.rcl_get_zero_initialized_subscription()
    typesupport = Rclex.Msg.typesupport(message_type)

    Nifs.rcl_subscription_init(subscription, node, topic, typesupport, subscription_options)
  end
end
