defmodule Rclex.Generators.Util do
  @moduledoc false

  def templates_dir_path(interface \\ :msg) do
    case interface do
      :msg -> Path.join(Application.app_dir(:rclex), "priv/templates/rclex.gen.msgs")
      :srv -> Path.join(Application.app_dir(:rclex), "priv/templates/rclex.gen.srvs")
      :action -> Path.join(Application.app_dir(:rclex), "priv/templates/rclex.gen.action")
      _ -> raise "ros2 interface type not supported"
    end
  end

  @doc """
  iex> Rclex.Generators.Util.type_down_snake("std_msgs/msg/String")
  "std_msgs_msg_string"

  iex> Rclex.Generators.Util.type_down_snake("std_msgs/msg/UInt32MultiArray")
  "std_msgs_msg_u_int32_multi_array"
  """
  def type_down_snake(ros2_message_type) do
    [interfaces, interface_type, type] = ros2_message_type |> String.split("/")
    [interfaces, interface_type, to_down_snake(type)] |> Enum.join("_")
  end

  @doc """
  iex> Rclex.Generators.Util.to_down_snake("Vector3")
  "vector3"

  iex> Rclex.Generators.Util.to_down_snake("TwistWithCovariance")
  "twist_with_covariance"

  iex> Rclex.Generators.Util.to_down_snake("UInt32MultiArray")
  "u_int32_multi_array"

  iex> Rclex.Generators.Util.to_down_snake("TF2Error")
  "tf2_error"
  """
  def to_down_snake(type_name) do
    # NOTE: conversion rule is described followings,
    # https://github.com/ros2/rosidl/blob/humble/rosidl_cmake/cmake/string_camel_case_to_lower_case_underscore.cmake#L23-L32
    # We just described it as Elixir
    type_name
    |> String.replace(~r/(.)([A-Z][a-z]+)/, "\\1_\\2")
    |> String.replace(~r/([a-z0-9])([A-Z])/, "\\1_\\2")
    |> String.downcase()
  end

  @doc """
  iex> Rclex.Generators.Util.module_name("std_msgs/msg/String")
  "StdMsgs.Msg.String"
  """
  def module_name(ros2_message_type) do
    [pkg, msg, type] = String.split(ros2_message_type, "/")

    pkg =
      pkg
      |> String.replace("/", "_")
      |> String.split("_")
      |> Enum.map_join(&String.capitalize(&1))

    type =
      type
      |> String.replace_trailing("_Feedback", ".Feedback")
      |> String.replace_trailing("_Goal", ".Goal")
      |> String.replace_trailing("_Result", ".Result")
      |> String.replace_trailing("_FeedbackMessage", ".FeedbackMessage")
      |> String.replace_trailing("_SendGoal_Request", ".SendGoal.Request")
      |> String.replace_trailing("_SendGoal_Response", ".SendGoal.Response")
      |> String.replace_trailing("_GetResult_Request", ".GetResult.Request")
      |> String.replace_trailing("_GetResult_Response", ".GetResult.Response")
      |> String.replace_trailing("_Response", ".Response")
      |> String.replace_trailing("_Request", ".Request")

    Enum.join([pkg, String.capitalize(msg), type], ".")
  end
end
