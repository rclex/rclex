defprotocol Rclex.MsgProt do
  def typesupport(msg_type)
  def initialize(msg_type)
  def set(data, msg)
  def read(msg_type, msg)
end


