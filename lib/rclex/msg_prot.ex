defprotocol Rclex.MsgProt do
  @moduledoc """
  Defines protocol which supports arbitrary message types.
  Modules implementing this protocol should define relationships between Elixir structure data and C structure data.
  """

  @doc """
  Should return typesupport reference.
  """
  @spec typesupport(msg_type :: struct()) :: reference()
  def typesupport(msg_type)

  @doc """
  Should return reference to C struct instance.
  """
  @spec initialize(msg_type :: struct()) :: reference()
  def initialize(msg_type)

  @doc """
  Should set Elixir struct to C struct instance.
  """
  @spec set(data :: struct(), msg :: reference()) :: :ok
  def set(data, msg)

  @doc """
  Should return Elixir struct loaded with data from C struct instance.
  """
  @spec read(msg_type :: struct(), msg :: reference()) :: struct()
  def read(msg_type, msg)
end
