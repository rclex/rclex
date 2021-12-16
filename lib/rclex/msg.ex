defmodule Rclex.Msg do
  def typesupport(msg_type) do
    get_struct(msg_type) |> Rclex.MsgProt.typesupport()
  end

  def initialize(msg_type) do
    get_struct(msg_type) |> Rclex.MsgProt.initialize()
  end

  def initialize_msgs(msg_count, msg_type) do
    str = get_struct(msg_type);
    Enum.map(1..msg_count, fn _ ->
      Rclex.MsgProt.initialize(str)
    end)
  end

  def set(msg, data, _msg_type) do
    Rclex.MsgProt.set(data, msg)
  end

  def read(msg, msg_type) do
    get_struct(msg_type) |> Rclex.MsgProt.read(msg)
  end

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
byte		binary
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
