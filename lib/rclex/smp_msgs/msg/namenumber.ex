defmodule Rclex.SmpMsgs.Msg.Namenumber do
  defstruct name: '', number: 0
  @type t :: %Rclex.SmpMsgs.Msg.Namenumber{name: [integer], number: integer}
end
