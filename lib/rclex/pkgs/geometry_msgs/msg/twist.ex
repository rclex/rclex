defmodule Rclex.Pkgs.GeometryMsgs.Msg.Twist do
  @moduledoc false
  @behaviour Rclex.MessageBehaviour

  defstruct linear: %Rclex.Pkgs.GeometryMsgs.Msg.Vector3{x: nil, y: nil, z: nil},
            angular: %Rclex.Pkgs.GeometryMsgs.Msg.Vector3{x: nil, y: nil, z: nil}

  @type t :: %__MODULE__{
          linear: %Rclex.Pkgs.GeometryMsgs.Msg.Vector3{x: float(), y: float(), z: float()},
          angular: %Rclex.Pkgs.GeometryMsgs.Msg.Vector3{x: float(), y: float(), z: float()}
        }

  alias Rclex.Nif

  def type_support!() do
    Nif.rosidl_get_geometry_msgs_msg_twist_type_support!()
  end

  def create!() do
    Nif.geometry_msgs_msg_twist_create!()
  end

  def destroy!(message) do
    Nif.geometry_msgs_msg_twist_destroy!(message)
  end

  def set!(message, %__MODULE__{} = struct) do
    Nif.geometry_msgs_msg_twist_set!(
      message,
      {{struct.linear.x, struct.linear.y, struct.linear.z},
       {struct.angular.x, struct.angular.y, struct.angular.z}}
    )
  end

  def get!(message) do
    {{linear_x, linear_y, linear_z}, {angular_x, angular_y, angular_z}} =
      Nif.geometry_msgs_msg_twist_get!(message)

    %__MODULE__{
      linear: %Rclex.Pkgs.GeometryMsgs.Msg.Vector3{x: linear_x, y: linear_y, z: linear_z},
      angular: %Rclex.Pkgs.GeometryMsgs.Msg.Vector3{x: angular_x, y: angular_y, z: angular_z}
    }
  end
end
