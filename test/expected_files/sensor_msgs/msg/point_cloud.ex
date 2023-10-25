defmodule Rclex.Pkgs.SensorMsgs.Msg.PointCloud do
  @moduledoc false
  @behaviour Rclex.MessageBehaviour

  defstruct header: %Rclex.Pkgs.StdMsgs.Msg.Header{},
            points: [],
            channels: []

  @type t :: %__MODULE__{
          header: %Rclex.Pkgs.StdMsgs.Msg.Header{},
          points: list(%Rclex.Pkgs.GeometryMsgs.Msg.Point32{}),
          channels: list(%Rclex.Pkgs.SensorMsgs.Msg.ChannelFloat32{})
        }

  alias Rclex.Nif

  def type_support!() do
    Nif.sensor_msgs_msg_point_cloud_type_support!()
  end

  def create!() do
    Nif.sensor_msgs_msg_point_cloud_create!()
  end

  def destroy!(message) do
    Nif.sensor_msgs_msg_point_cloud_destroy!(message)
  end

  def set!(message, %__MODULE__{} = struct) do
    Nif.sensor_msgs_msg_point_cloud_set!(message, to_tuple(struct))
  end

  def get!(message) do
    Nif.sensor_msgs_msg_point_cloud_get!(message) |> to_struct()
  end

  def to_tuple(%__MODULE__{header: header, points: points, channels: channels}) do
    {
      Rclex.Pkgs.StdMsgs.Msg.Header.to_tuple(header),
      for struct <- points do
        Rclex.Pkgs.GeometryMsgs.Msg.Point32.to_tuple(struct)
      end,
      for struct <- channels do
        Rclex.Pkgs.SensorMsgs.Msg.ChannelFloat32.to_tuple(struct)
      end
    }
  end

  def to_struct({header, points, channels}) do
    %__MODULE__{
      header: Rclex.Pkgs.StdMsgs.Msg.Header.to_struct(header),
      points:
        for tuple <- points do
          Rclex.Pkgs.GeometryMsgs.Msg.Point32.to_struct(tuple)
        end,
      channels:
        for tuple <- channels do
          Rclex.Pkgs.SensorMsgs.Msg.ChannelFloat32.to_struct(tuple)
        end
    }
  end
end
