defimpl Rclex.MsgProt, for: Rclex.StdMsgs.Msg.String do
  alias Rclex.Nifs, as: Nifs

  def typesupport(_) do
    Nifs.get_typesupport_std_msgs__msg__String()
  end
  def initialize(_) do
    Nifs.create_empty_msg_std_msgs__msg__String()
    |> Nifs.init_msg_std_msgs__msg__String()
  end
  def set(data, msg) do
    Nifs.setdata_std_msgs__msg__String(msg, data.data, length(data.data) + 1)
  end
  def read(_, msg) do
    %Rclex.StdMsgs.Msg.String{data: Nifs.readdata_std_msgs__msg__String(msg)}
  end
end
