defimpl Rclex.MsgProt, for: Rclex.GeometryMsgs.Msg.TwistWithCovariance do
  alias Rclex.Nifs, as: Nifs

  @spec typesupport(any) :: reference()
  def typesupport(_) do
    Nifs.get_typesupport_geometry_msgs_msg_twist_with_covariance()
  end

  @spec initialize(any) :: reference()
  def initialize(_) do
    Nifs.create_empty_msg_geometry_msgs_msg_twist_with_covariance()
    |> Nifs.init_msg_geometry_msgs_msg_twist_with_covariance()
  end

  @spec set(Rclex.GeometryMsgs.Msg.TwistWithCovariance.t(), any) :: :ok
  def set(data, msg) do
    Nifs.setdata_geometry_msgs_msg_twist_with_covariance(msg, {{{data.twist.linear.x, data.twist.linear.y, data.twist.linear.z}, {data.twist.angular.x, data.twist.angular.y, data.twist.angular.z}}, data.covariance})
  end

  @spec read(any, any) :: Rclex.GeometryMsgs.Msg.TwistWithCovariance.t()
  def read(_, msg) do
    {{{data_0_0_0, data_0_0_1, data_0_0_2}, {data_0_1_0, data_0_1_1, data_0_1_2}}, data_1} = Nifs.readdata_geometry_msgs_msg_twist_with_covariance(msg)
    %Rclex.GeometryMsgs.Msg.TwistWithCovariance{twist: %Rclex.GeometryMsgs.Msg.Twist{linear: %Rclex.GeometryMsgs.Msg.Vector3{x: data_0_0_0, y: data_0_0_1, z: data_0_0_2}, angular: %Rclex.GeometryMsgs.Msg.Vector3{x: data_0_1_0, y: data_0_1_1, z: data_0_1_2}}, covariance: data_1}
  end
end
