defmodule Rclex.Pkgs.StdMsgs.Msg.Empty do
  @moduledoc false
  @behaviour Rclex.MessageBehaviour

  defstruct []

  @type t :: %__MODULE__{}

  alias Rclex.Nif

  def type_support!() do
    Nif.std_msgs_msg_empty_type_support!()
  end

  def create!() do
    Nif.std_msgs_msg_empty_create!()
  end

  def destroy!(message) do
    Nif.std_msgs_msg_empty_destroy!(message)
  end

  def set!(message, %__MODULE__{} = struct) do
    Nif.std_msgs_msg_empty_set!(message, to_tuple(struct))
  end

  def get!(message) do
    Nif.std_msgs_msg_empty_get!(message) |> to_struct()
  end

  def to_tuple(%__MODULE__{}) do
    {}
  end

  def to_struct({}) do
    %__MODULE__{}
  end
end
