defmodule Rclex.Pkgs.StdMsgs.Msg.MultiArrayLayout do
  @moduledoc false
  @behaviour Rclex.MessageBehaviour

  defstruct dim: [],
            data_offset: 0

  @type t :: %__MODULE__{
          dim: list(%Rclex.Pkgs.StdMsgs.Msg.MultiArrayDimension{}),
          data_offset: non_neg_integer()
        }

  alias Rclex.Nif

  def type_support!() do
    Nif.std_msgs_msg_multi_array_layout_type_support!()
  end

  def create!() do
    Nif.std_msgs_msg_multi_array_layout_create!()
  end

  def destroy!(message) do
    Nif.std_msgs_msg_multi_array_layout_destroy!(message)
  end

  def set!(message, %__MODULE__{} = struct) do
    Nif.std_msgs_msg_multi_array_layout_set!(message, to_tuple(struct))
  end

  def get!(message) do
    Nif.std_msgs_msg_multi_array_layout_get!(message) |> to_struct()
  end

  def to_tuple(%__MODULE__{dim: dim, data_offset: data_offset}) do
    {for struct <- dim do
       Rclex.Pkgs.StdMsgs.Msg.MultiArrayDimension.to_tuple(struct)
     end, data_offset}
  end

  def to_struct({dim, data_offset}) do
    %__MODULE__{
      dim:
        for tuple <- dim do
          Rclex.Pkgs.StdMsgs.Msg.MultiArrayDimension.to_struct(tuple)
        end,
      data_offset: data_offset
    }
  end
end
