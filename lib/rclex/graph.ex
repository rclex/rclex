defmodule Rclex.Graph do
  require Logger

  alias Rclex.Nif

  def count_publishers(node, topic_name) do
    Nif.rcl_count_publishers!(node, topic_name)
  end

  def count_subscribers(node, topic_name) do
    Nif.rcl_count_subscribers!(node, topic_name)
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

  def get_subscriber_names_and_types_by_node(node, node_name, namespace, no_demangle) do
    Nif.rcl_get_subscriber_names_and_types_by_node!(node, node_name, namespace, no_demangle)
  end

  def get_subscribers_info_by_topic(node, topic_name, no_mangle) do
    Nif.rcl_get_subscribers_info_by_topic!(node, topic_name, no_mangle)
  end

  def get_topic_names_and_types(node, no_demangle) do
    Nif.rcl_get_topic_names_and_types!(node, no_demangle)
  end
end
