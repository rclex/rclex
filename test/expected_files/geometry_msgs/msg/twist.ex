defmodule Rclex.Pkgs.GeometryMsgs.Msg.Twist do
  @moduledoc false
  @behaviour Rclex.MessageBehaviour

  defstruct linear: %Rclex.Pkgs.GeometryMsgs.Msg.Vector3{},
            angular: %Rclex.Pkgs.GeometryMsgs.Msg.Vector3{}

  @type t :: %__MODULE__{
          linear: %Rclex.Pkgs.GeometryMsgs.Msg.Vector3{},
          angular: %Rclex.Pkgs.GeometryMsgs.Msg.Vector3{}
        }

  alias Rclex.Nif

  def type_support!() do
    Nif.geometry_msgs_msg_twist_type_support!()
  end

  def create!() do
    Nif.geometry_msgs_msg_twist_create!()
  end

  def destroy!(message) do
    Nif.geometry_msgs_msg_twist_destroy!(message)
  end

  def set!(message, %__MODULE__{} = struct) do
    Nif.geometry_msgs_msg_twist_set!(message, to_tuple(struct))
  end

  def get!(message) do
    Nif.geometry_msgs_msg_twist_get!(message) |> to_struct()
  end

  def to_tuple(%__MODULE__{linear: linear, angular: angular}) do
    {
      Rclex.Pkgs.GeometryMsgs.Msg.Vector3.to_tuple(linear),
      Rclex.Pkgs.GeometryMsgs.Msg.Vector3.to_tuple(angular)
    }
  end

  def to_struct({linear, angular}) do
    %__MODULE__{
      linear: Rclex.Pkgs.GeometryMsgs.Msg.Vector3.to_struct(linear),
      angular: Rclex.Pkgs.GeometryMsgs.Msg.Vector3.to_struct(angular)
    }
  end
end
