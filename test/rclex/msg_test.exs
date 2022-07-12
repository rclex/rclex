defmodule Rclex.MsgTest do
  use ExUnit.Case

  alias Rclex.Msg

  describe "typesupport/1" do
    for message_type <- ['StdMsgs.Msg.String', 'GeometryMsgs.Msg.Twist'] do
      test "return #{message_type} reference" do
        message_type = unquote(message_type)
        assert is_reference(Msg.typesupport(message_type))
      end
    end
  end

  describe "initialize/1" do
    for message_type <- ['StdMsgs.Msg.String', 'GeometryMsgs.Msg.Twist'] do
      test "return #{message_type} reference" do
        message_type = unquote(message_type)
        assert is_reference(Msg.initialize(message_type))
      end
    end
  end

  describe "initialize_msgs/2" do
    for message_type <- ['StdMsgs.Msg.String', 'GeometryMsgs.Msg.Twist'] do
      test "return list of #{message_type} reference" do
        message_type = unquote(message_type)
        assert [h | _t] = Msg.initialize_msgs(2, message_type)
        assert is_reference(h)
      end
    end
  end

  describe "set/3 and read2" do
    alias Rclex.GeometryMsgs.Msg.Twist
    alias Rclex.GeometryMsgs.Msg.Vector3

    for {message_type, ex_struct} <- [
          {'StdMsgs.Msg.String',
           Macro.escape(%Rclex.StdMsgs.Msg.String{
             data: String.to_charlist("data")
           })},
          {'GeometryMsgs.Msg.Twist',
           Macro.escape(%Twist{
             linear: %Vector3{x: 0.0, y: 0.0, z: 0.0},
             angular: %Vector3{x: 0.0, y: 0.0, z: 0.0}
           })}
        ] do
      test "set/3 for #{message_type}, return :ok" do
        message_type = unquote(message_type)
        ex_struct = unquote(ex_struct)
        c_message = Msg.initialize(message_type)
        assert :ok = Msg.set(c_message, ex_struct, message_type)
      end

      test "read/2 for #{message_type} return struct" do
        message_type = unquote(message_type)
        ex_struct = unquote(ex_struct)

        c_message = Msg.initialize(message_type)
        :ok = Msg.set(c_message, ex_struct, message_type)

        assert ^ex_struct = Msg.read(c_message, message_type)
      end
    end
  end
end
