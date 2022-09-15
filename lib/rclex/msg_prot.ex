defprotocol Rclex.MsgProt do
  @moduledoc """
  Defines protocol which supports arbitrary message types.
  Modules implementing this protocol should define relationships between Elixir structure data and C structure data.
  """

  alias Rclex.Nifs

  @doc """
  Should return typesupport reference.
  """
  @spec typesupport(msg_type :: struct()) :: Nifs.rosidl_message_type_support()
  def typesupport(msg_type)

  @doc """
  Should return reference to C struct instance.
  """
  @spec initialize(msg_type :: struct()) :: Nifs.ros_message()
  def initialize(msg_type)

  @doc """
  Should set Elixir struct to C struct instance.
  """
  @spec set(data :: struct(), msg :: Nifs.ros_message()) :: :ok
  def set(data, msg)

  @doc """
  Should return Elixir struct loaded with data from C struct instance.
  """
  @spec read(msg_type :: struct(), msg :: Nifs.ros_message()) :: struct()
  def read(msg_type, msg)
end
