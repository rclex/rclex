defmodule Rclex.GeometryMsgs.Msg.TwistWithCovariance do
  defstruct twist: %Rclex.GeometryMsgs.Msg.Twist{linear: %Rclex.GeometryMsgs.Msg.Vector3{x: nil, y: nil, z: nil}, angular: %Rclex.GeometryMsgs.Msg.Vector3{x: nil, y: nil, z: nil}}, covariance: nil
  @type t :: %Rclex.GeometryMsgs.Msg.TwistWithCovariance{twist: %Rclex.GeometryMsgs.Msg.Twist{linear: %Rclex.GeometryMsgs.Msg.Vector3{x: float, y: float, z: float}, angular: %Rclex.GeometryMsgs.Msg.Vector3{x: float, y: float, z: float}}, covariance: [float]}
end
