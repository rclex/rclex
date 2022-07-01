defmodule Rclex.Msg do
  @moduledoc """
  Defines functions which call `Rclex.MsgProt` implementation.
  """

  @doc """
  Return typesupport reference.
  """
  @spec typesupport(msg_type :: charlist()) :: reference()
  def typesupport(msg_type) do
    get_struct(msg_type) |> Rclex.MsgProt.typesupport()
  end

  @doc """
  Return reference which refers to initialized msg_type C struct instance.
  """
  @spec initialize(msg_type :: charlist()) :: reference()
  def initialize(msg_type) do
    get_struct(msg_type) |> Rclex.MsgProt.initialize()
  end

  @doc """
  Return list of reference which refers to initialized msg_type C struct instance.
  """
  @spec initialize_msgs(msg_count :: integer(), msg_type :: charlist()) :: [reference()]
  def initialize_msgs(msg_count, msg_type) do
    str = get_struct(msg_type)

    Enum.map(1..msg_count, fn _ ->
      Rclex.MsgProt.initialize(str)
    end)
  end

  @doc """
  Set Elixir struct to C struct instance.
  """
  @spec set(msg :: reference(), data :: struct(), _msg_type :: charlist()) :: :ok
  def set(msg, data, _msg_type) do
    Rclex.MsgProt.set(data, msg)
  end

  @doc """
  Return msg_type struct loaded with data from C struct instance.
  """
  @spec read(msg :: reference(), msg_type :: charlist()) :: struct()
  def read(msg, msg_type) do
    get_struct(msg_type) |> Rclex.MsgProt.read(msg)
  end

  @spec get_struct(struct_name :: charlist()) :: struct()
  defp get_struct(struct_name) do
    ["Rclex", List.to_string(struct_name)]
    |> Module.concat()
    |> struct()
  end
end

"""
--------Field Types--------
Type name	Elixir
---------------------------
bool 		bool(atom)
byte		integer
char		integer
float32		float
float64		float
int8		integer
uint8		integer
int16		integer
uint16		integer
int32		integer
uint32		integer
int64		integer
uint64		integer
string		list
wstring		list
"""
