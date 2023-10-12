defmodule Rclex.Pkgs.Test do
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
end
