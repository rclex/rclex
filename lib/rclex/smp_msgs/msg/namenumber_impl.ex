defimpl Rclex.MsgProt, for: Rclex.SmpMsgs.Msg.Namenumber do
  alias Rclex.Nifs, as: Nifs

  def typesupport(_) do
    Nifs.get_typesupport_smp_msgs__msg__Namenumber()
  end
  def initialize(_) do
    Nifs.create_empty_msg_smp_msgs__msg__Namenumber()
    |> Nifs.init_msg_smp_msgs__msg__Namenumber()
  end
  def set(data, msg) do
    Nifs.setdata_smp_msgs__msg__Namenumber(msg, data.name, length(data.name) + 1, data.number)
  end
  def read(_, msg) do
    {name, number} = Nifs.readdata_smp_msgs__msg__Namenumber(msg)
    %Rclex.SmpMsgs.Msg.Namenumber{name: name, number: number}
  end
end

