defmodule Rclex.Pkgs.StdMsgs.Msg.String do
  @moduledoc false
  @behaviour Rclex.MessageBehaviour

  defstruct data: nil

  @type t :: %__MODULE__{
          data: String.t()
        }

  alias Rclex.Nif

  def type_support!() do
    Nif.std_msgs_msg_string_type_support!()
  end

  def create!() do
    Nif.std_msgs_msg_string_create!()
  end

  def destroy!(message) do
    Nif.std_msgs_msg_string_destroy!(message)
  end

  def set!(message, %__MODULE__{} = struct) do
    Nif.std_msgs_msg_string_set!(message, to_tuple(struct))
  end

  def get!(message) do
    Nif.std_msgs_msg_string_get!(message) |> to_struct()
  end

  def to_tuple(%__MODULE__{data: data}) do
    {
      ~c"#{data}"
    }
  end

  def to_struct({data}) do
    %__MODULE__{
      data: "#{data}"
    }
  end
end
