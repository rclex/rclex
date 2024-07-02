defmodule Rclex.Pkgs.StdMsgs.Msg.UInt32MultiArray do
  @moduledoc false
  @behaviour Rclex.MessageBehaviour

  defstruct layout: %Rclex.Pkgs.StdMsgs.Msg.MultiArrayLayout{},
            data: []

  @type t :: %__MODULE__{
          layout: %Rclex.Pkgs.StdMsgs.Msg.MultiArrayLayout{},
          data: list(non_neg_integer())
        }

  alias Rclex.Nif

  def type_support!() do
    Nif.std_msgs_msg_u_int32_multi_array_type_support!()
  end

  def create!() do
    Nif.std_msgs_msg_u_int32_multi_array_create!()
  end

  def destroy!(message) do
    Nif.std_msgs_msg_u_int32_multi_array_destroy!(message)
  end

  def set!(message, %__MODULE__{} = struct) do
    Nif.std_msgs_msg_u_int32_multi_array_set!(message, to_tuple(struct))
  end

  def get!(message) do
    Nif.std_msgs_msg_u_int32_multi_array_get!(message) |> to_struct()
  end

  def to_tuple(%__MODULE__{layout: layout, data: data}) do
    {Rclex.Pkgs.StdMsgs.Msg.MultiArrayLayout.to_tuple(layout), data}
  end

  def to_struct({layout, data}) do
    %__MODULE__{layout: Rclex.Pkgs.StdMsgs.Msg.MultiArrayLayout.to_struct(layout), data: data}
  end
end
