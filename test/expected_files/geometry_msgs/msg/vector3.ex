defmodule Rclex.GeometryMsgs.Msg.Vector3 do
  defstruct x: nil, y: nil, z: nil
  @type t :: %Rclex.GeometryMsgs.Msg.Vector3{x: float, y: float, z: float}
end
