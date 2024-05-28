defmodule Rclex.Pkgs.MsgsTest do
  use ExUnit.Case

  test "geometry_msgs/msg/Twist" do
    struct = %Rclex.Pkgs.GeometryMsgs.Msg.Twist{
      linear: %Rclex.Pkgs.GeometryMsgs.Msg.Vector3{x: 1.0, y: 2.0, z: 3.0},
      angular: %Rclex.Pkgs.GeometryMsgs.Msg.Vector3{x: 4.0, y: 5.0, z: 6.0}
    }

    Rclex.Pkgs.GeometryMsgs.Msg.Twist.create!()
    |> tap(&Rclex.Pkgs.GeometryMsgs.Msg.Twist.set!(&1, struct))
    |> tap(fn message ->
      assert ^struct = Rclex.Pkgs.GeometryMsgs.Msg.Twist.get!(message)
    end)
    |> tap(&Rclex.Pkgs.GeometryMsgs.Msg.Twist.destroy!(&1))
  end

  test "std_msgs/msg/Empty" do
    struct = %Rclex.Pkgs.StdMsgs.Msg.Empty{}

    Rclex.Pkgs.StdMsgs.Msg.Empty.create!()
    |> tap(&Rclex.Pkgs.StdMsgs.Msg.Empty.set!(&1, struct))
    |> tap(fn message ->
      assert ^struct = Rclex.Pkgs.StdMsgs.Msg.Empty.get!(message)
    end)
    |> tap(&Rclex.Pkgs.StdMsgs.Msg.Empty.destroy!(&1))
  end

  test "std_msgs/msg/UInt8MultiArray" do
    struct = %Rclex.Pkgs.StdMsgs.Msg.UInt8MultiArray{
      layout: %Rclex.Pkgs.StdMsgs.Msg.MultiArrayLayout{
        dim: [
          %Rclex.Pkgs.StdMsgs.Msg.MultiArrayDimension{
            label: "abc",
            size: 123,
            stride: 789
          },
          %Rclex.Pkgs.StdMsgs.Msg.MultiArrayDimension{
            label: "def",
            size: 456,
            stride: 456
          },
          %Rclex.Pkgs.StdMsgs.Msg.MultiArrayDimension{
            label: "ghi",
            size: 789,
            stride: 123
          }
        ],
        data_offset: 123_456_789
      },
      data: <<1, 2, 3, 4, 5, 6, 7, 8, 9>>
    }

    Rclex.Pkgs.StdMsgs.Msg.UInt8MultiArray.create!()
    |> tap(&Rclex.Pkgs.StdMsgs.Msg.UInt8MultiArray.set!(&1, struct))
    |> tap(fn message ->
      assert ^struct = Rclex.Pkgs.StdMsgs.Msg.UInt8MultiArray.get!(message)
    end)
    |> tap(&Rclex.Pkgs.StdMsgs.Msg.UInt8MultiArray.destroy!(&1))
  end

  test "std_msgs/msg/UInt32MultiArray" do
    struct = %Rclex.Pkgs.StdMsgs.Msg.UInt32MultiArray{
      layout: %Rclex.Pkgs.StdMsgs.Msg.MultiArrayLayout{
        dim: [
          %Rclex.Pkgs.StdMsgs.Msg.MultiArrayDimension{
            label: "abc",
            size: 123,
            stride: 789
          },
          %Rclex.Pkgs.StdMsgs.Msg.MultiArrayDimension{
            label: "def",
            size: 456,
            stride: 456
          },
          %Rclex.Pkgs.StdMsgs.Msg.MultiArrayDimension{
            label: "ghi",
            size: 789,
            stride: 123
          }
        ],
        data_offset: 123_456_789
      },
      data: [1, 2, 3, 4, 5, 6, 7, 8, 9]
    }

    Rclex.Pkgs.StdMsgs.Msg.UInt32MultiArray.create!()
    |> tap(&Rclex.Pkgs.StdMsgs.Msg.UInt32MultiArray.set!(&1, struct))
    |> tap(fn message ->
      assert ^struct = Rclex.Pkgs.StdMsgs.Msg.UInt32MultiArray.get!(message)
    end)
    |> tap(&Rclex.Pkgs.StdMsgs.Msg.UInt32MultiArray.destroy!(&1))
  end

  test "sensor_msgs/msg/PointCloud" do
    struct = %Rclex.Pkgs.SensorMsgs.Msg.PointCloud{
      header: %Rclex.Pkgs.StdMsgs.Msg.Header{
        stamp: %Rclex.Pkgs.BuiltinInterfaces.Msg.Time{sec: -1, nanosec: 1},
        frame_id: "frame_id"
      },
      points: [%Rclex.Pkgs.GeometryMsgs.Msg.Point32{x: 0.0, y: 0.0, z: 0.0}],
      channels: [
        %Rclex.Pkgs.SensorMsgs.Msg.ChannelFloat32{name: "name", values: [0.0, 0.0, 0.0]}
      ]
    }

    Rclex.Pkgs.SensorMsgs.Msg.PointCloud.create!()
    |> tap(&Rclex.Pkgs.SensorMsgs.Msg.PointCloud.set!(&1, struct))
    |> tap(fn message ->
      assert ^struct = Rclex.Pkgs.SensorMsgs.Msg.PointCloud.get!(message)
    end)
    |> tap(&Rclex.Pkgs.SensorMsgs.Msg.PointCloud.destroy!(&1))
  end

  test "diagnostic_msgs/msg/DiagnosticStatus" do
    struct = %Rclex.Pkgs.DiagnosticMsgs.Msg.DiagnosticStatus{
      level: 3,
      name: "test",
      message: "test message",
      hardware_id: "test sensor",
      values: [
        %Rclex.Pkgs.DiagnosticMsgs.Msg.KeyValue{key: "key1", value: "value1"},
        %Rclex.Pkgs.DiagnosticMsgs.Msg.KeyValue{key: "key2", value: "value2"}
      ]
    }

    Rclex.Pkgs.DiagnosticMsgs.Msg.DiagnosticStatus.create!()
    |> tap(&Rclex.Pkgs.DiagnosticMsgs.Msg.DiagnosticStatus.set!(&1, struct))
    |> tap(fn message ->
      assert ^struct = Rclex.Pkgs.DiagnosticMsgs.Msg.DiagnosticStatus.get!(message)
    end)
    |> tap(&Rclex.Pkgs.DiagnosticMsgs.Msg.DiagnosticStatus.destroy!(&1))
  end
end
