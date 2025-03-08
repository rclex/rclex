alias Rclex.Pkgs.StdMsgs

struct = %Rclex.Pkgs.StdMsgs.Msg.String{
  data: for(_ <- 1..(2 ** 16), into: <<>>, do: <<0x30>>)
}

Benchee.run(%{
  "create!/0" => {
    fn ->
      StdMsgs.Msg.String.create!()
    end,
    after_each: fn message ->
      StdMsgs.Msg.String.destroy!(message)
    end
  },
  "set!/2" => {
    fn message ->
      StdMsgs.Msg.String.set!(message, struct)
      message
    end,
    before_each: fn _ ->
      StdMsgs.Msg.String.create!()
    end,
    after_each: fn message ->
      StdMsgs.Msg.String.destroy!(message)
    end
  },
  "get!/1" => {
    fn message ->
      StdMsgs.Msg.String.get!(message)
      message
    end,
    before_each: fn _ ->
      message = StdMsgs.Msg.String.create!()
      StdMsgs.Msg.String.set!(message, struct)
      message
    end,
    after_each: fn message ->
      StdMsgs.Msg.String.destroy!(message)
    end
  },
  "destroy!/1" => {
    fn message -> StdMsgs.Msg.String.destroy!(message) end,
    before_each: fn _ ->
      message = StdMsgs.Msg.String.create!()
      StdMsgs.Msg.String.set!(message, struct)
      message
    end
  }
})
