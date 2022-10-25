defimpl Rclex.MsgProt, for: Rclex.StdMsgs.Msg.String do
  alias Rclex.Nifs, as: Nifs

  @spec typesupport(any) :: reference()
  def typesupport(_) do
    Nifs.get_typesupport_std_msgs_msg_string()
  end

  @spec initialize(any) :: reference()
  def initialize(_) do
    Nifs.create_empty_msg_std_msgs_msg_string()
    |> Nifs.init_msg_std_msgs_msg_string()
  end

  @spec set(Rclex.StdMsgs.Msg.String.t(), any) :: :ok
  def set(data, msg) do
    Nifs.setdata_std_msgs_msg_string(msg, {data.data})
  end

  @spec read(any, any) :: Rclex.StdMsgs.Msg.String.t()
  def read(_, msg) do
    {data_0} = Nifs.readdata_std_msgs_msg_string(msg)
    %Rclex.StdMsgs.Msg.String{data: data_0}
  end
end
