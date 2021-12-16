defimpl Rclex.MsgProt, for: Rclex.StdMsgs.Msg.Int16 do
  alias Rclex.Nifs, as: Nifs

  def typesupport(_) do
    Nifs.get_typesupport_std_msgs__msg__Int16()
  end
  def initialize(_) do
    Nifs.create_empty_msg_std_msgs__msg__Int16()
    |> Nifs.init_msg_std_msgs__msg__Int16()
  end
  def set(data, msg) do
    Nifs.setdata_std_msgs__msg__Int16(msg, data.data)
  end
  def read(_, msg) do
    %Rclex.StdMsgs.Msg.Int16{data: Nifs.readdata_std_msgs__msg__Int16(msg)}
  end
end
