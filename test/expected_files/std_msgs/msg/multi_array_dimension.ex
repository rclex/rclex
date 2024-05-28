defmodule Rclex.Pkgs.StdMsgs.Msg.MultiArrayDimension do
  @moduledoc false
  @behaviour Rclex.MessageBehaviour

  defstruct label: nil,
            size: nil,
            stride: nil

  @type t :: %__MODULE__{label: String.t(), size: non_neg_integer(), stride: non_neg_integer()}

  alias Rclex.Nif

  def type_support!() do
    Nif.std_msgs_msg_multi_array_dimension_type_support!()
  end

  def create!() do
    Nif.std_msgs_msg_multi_array_dimension_create!()
  end

  def destroy!(message) do
    Nif.std_msgs_msg_multi_array_dimension_destroy!(message)
  end

  def set!(message, %__MODULE__{} = struct) do
    Nif.std_msgs_msg_multi_array_dimension_set!(message, to_tuple(struct))
  end

  def get!(message) do
    Nif.std_msgs_msg_multi_array_dimension_get!(message) |> to_struct()
  end

  def to_tuple(%__MODULE__{label: label, size: size, stride: stride}) do
    {~c"#{label}", size, stride}
  end

  def to_struct({label, size, stride}) do
    %__MODULE__{label: "#{label}", size: size, stride: stride}
  end
end
