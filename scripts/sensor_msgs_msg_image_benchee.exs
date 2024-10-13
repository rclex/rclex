alias Rclex.Pkgs.SensorMsgs

struct = %Rclex.Pkgs.SensorMsgs.Msg.Image{
  header: %Rclex.Pkgs.StdMsgs.Msg.Header{
    stamp: %Rclex.Pkgs.BuiltinInterfaces.Msg.Time{sec: 872_037, nanosec: 631_914},
    frame_id: "image"
  },
  height: 240,
  width: 320,
  encoding: "8UC1",
  is_bigendian: 0,
  step: 320 * 1,
  data: for(_ <- 1..(240 * 320 * 1), into: <<>>, do: <<:rand.uniform(256) - 1>>)
}

Benchee.run(%{
  "create!/0" => {
    fn ->
      SensorMsgs.Msg.Image.create!()
    end,
    after_each: fn message ->
      SensorMsgs.Msg.Image.destroy!(message)
    end
  },
  "set!/2" => {
    fn message ->
      SensorMsgs.Msg.Image.set!(message, struct)
      message
    end,
    before_each: fn _ ->
      SensorMsgs.Msg.Image.create!()
    end,
    after_each: fn message ->
      SensorMsgs.Msg.Image.destroy!(message)
    end
  },
  "get!/1" => {
    fn message ->
      SensorMsgs.Msg.Image.get!(message)
      message
    end,
    before_each: fn _ ->
      message = SensorMsgs.Msg.Image.create!()
      SensorMsgs.Msg.Image.set!(message, struct)
      message
    end,
    after_each: fn message ->
      SensorMsgs.Msg.Image.destroy!(message)
    end
  },
  "destroy!/1" => {
    fn message -> SensorMsgs.Msg.Image.destroy!(message) end,
    before_each: fn _ ->
      message = SensorMsgs.Msg.Image.create!()
      SensorMsgs.Msg.Image.set!(message, struct)
      message
    end
  }
})
