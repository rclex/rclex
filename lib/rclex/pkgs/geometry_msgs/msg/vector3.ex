defmodule Rclex.Pkgs.GeometryMsgs.Msg.Vector3 do
  @moduledoc false
  @behaviour Rclex.MessageBehaviour

  defstruct x: nil, y: nil, z: nil
  @type t :: %__MODULE__{x: float(), y: float(), z: float()}

  alias Rclex.Nif

  def type_support!() do
    Nif.rosidl_get_geometry_msgs_msg_vector3_type_support!()
  end

  def create!() do
    Nif.geometry_msgs_msg_vector3_create!()
  end

  def destroy!(message) do
    Nif.geometry_msgs_msg_vector3_destroy!(message)
  end

  def set!(message, %__MODULE__{} = struct) do
    Nif.geometry_msgs_msg_vector3_set!(message, {struct.x, struct.y, struct.z})
  end

  def get!(message) do
    {x, y, z} = Nif.geometry_msgs_msg_vector3_get!(message)
    %__MODULE__{x: x, y: y, z: z}
  end
end
