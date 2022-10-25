defimpl Rclex.MsgProt, for: Rclex.GeometryMsgs.Msg.Twist do
  alias Rclex.Nifs, as: Nifs

  @spec typesupport(any) :: reference()
  def typesupport(_) do
    Nifs.get_typesupport_geometry_msgs_msg_twist()
  end

  @spec initialize(any) :: reference()
  def initialize(_) do
    Nifs.create_empty_msg_geometry_msgs_msg_twist()
    |> Nifs.init_msg_geometry_msgs_msg_twist()
  end

  @spec set(Rclex.GeometryMsgs.Msg.Twist.t(), any) :: :ok
  def set(data, msg) do
    Nifs.setdata_geometry_msgs_msg_twist(msg, {{data.linear.x, data.linear.y, data.linear.z}, {data.angular.x, data.angular.y, data.angular.z}})
  end

  @spec read(any, any) :: Rclex.GeometryMsgs.Msg.Twist.t()
  def read(_, msg) do
    {{data_0_0, data_0_1, data_0_2}, {data_1_0, data_1_1, data_1_2}} = Nifs.readdata_geometry_msgs_msg_twist(msg)
    %Rclex.GeometryMsgs.Msg.Twist{linear: %Rclex.GeometryMsgs.Msg.Vector3{x: data_0_0, y: data_0_1, z: data_0_2}, angular: %Rclex.GeometryMsgs.Msg.Vector3{x: data_1_0, y: data_1_1, z: data_1_2}}
  end
end
