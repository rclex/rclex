defmodule Rclex.Graph do
  @moduledoc false

  require Logger

  alias Rclex.Nif

  def count_publishers(node, topic_name) do
    Nif.rcl_count_publishers!(node, topic_name)
  end

  def count_subscribers(node, topic_name) do
    Nif.rcl_count_subscribers!(node, topic_name)
  end

  def get_client_names_and_types_by_node(node, node_name, namespace) do
    Nif.rcl_get_client_names_and_types_by_node!(node, node_name, namespace)
  end

  def get_node_names(node) do
    Nif.rcl_get_node_names!(node)
  end

  def get_node_names_with_enclaves(node) do
    Nif.rcl_get_node_names_with_enclaves!(node)
  end

  def get_publisher_names_and_types_by_node(node, node_name, namespace, no_demangle) do
    Nif.rcl_get_publisher_names_and_types_by_node!(node, node_name, namespace, no_demangle)
  end

  def get_publishers_info_by_topic(node, topic_name, no_mangle) do
    Nif.rcl_get_publishers_info_by_topic!(node, topic_name, no_mangle)
  end

  def get_service_names_and_types(node) do
    Nif.rcl_get_service_names_and_types!(node)
  end

  def get_service_names_and_types_by_node(node, node_name, namespace) do
    Nif.rcl_get_service_names_and_types_by_node!(node, node_name, namespace)
  end

  def get_subscriber_names_and_types_by_node(node, node_name, namespace, no_demangle) do
    Nif.rcl_get_subscriber_names_and_types_by_node!(node, node_name, namespace, no_demangle)
  end

  def get_subscribers_info_by_topic(node, topic_name, no_mangle) do
    Nif.rcl_get_subscribers_info_by_topic!(node, topic_name, no_mangle)
  end

  def get_topic_names_and_types(node, no_demangle) do
    Nif.rcl_get_topic_names_and_types!(node, no_demangle)
  end

  def service_server_is_available(node, client) do
    Nif.rcl_service_server_is_available!(node, client)
  end

  def action_get_client_names_and_types_by_node(node, node_name, namespace) do
    Nif.rcl_action_get_client_names_and_types_by_node!(node, node_name, namespace)
  end

  def action_get_names_and_types(node) do
    Nif.rcl_action_get_names_and_types!(node)
  end

  def action_get_server_names_and_types_by_node(node, node_name, namespace) do
    Nif.rcl_action_get_server_names_and_types_by_node!(node, node_name, namespace)
  end
end
