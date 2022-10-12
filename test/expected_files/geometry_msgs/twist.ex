defmodule Rclex.GeometryMsgs.Msg.Twist do
  defstruct linear: %Rclex.GeometryMsgs.Msg.Vector3{x: nil, y: nil, z: nil}, angular: %Rclex.GeometryMsgs.Msg.Vector3{x: nil, y: nil, z: nil}
  @type t :: %Rclex.GeometryMsgs.Msg.Twist{linear: %Rclex.GeometryMsgs.Msg.Vector3{x: float, y: float, z: float}, angular: %Rclex.GeometryMsgs.Msg.Vector3{x: float, y: float, z: float}}
end
