defmodule Rclex.NifTest do
  use ExUnit.Case

  alias Rclex.Nif

  describe "raise" do
    test "raise!/0" do
      try do
        Nif.raise!()
      rescue
        ex in [ErlangError] ->
          %ErlangError{original: charlist, reason: nil} = ex
          assert "at src/terms.c:21" <> _ = to_string(charlist)
      end
    end

    test "raise_with_message!/0" do
      try do
        Nif.raise_with_message!()
      rescue
        ex in [ErlangError] ->
          %ErlangError{original: charlist, reason: nil} = ex
          assert "at src/terms.c:28" <> _ = to_string(charlist)
          assert String.ends_with?(to_string(charlist), "test")
      end
    end
  end

  describe "context" do
    test "rcl_init!/0, rcl_fini!/1" do
      context = Nif.rcl_init!()
      assert is_reference(context)
      assert Nif.rcl_fini!(context) == :ok
    end
  end

  describe "node" do
    setup do
      context = Nif.rcl_init!()
      on_exit(fn -> Nif.rcl_fini!(context) end)
      %{context: context}
    end

    test "rcl_node_init!/3, rcl_node_fini!/1", %{context: context} do
      node = Nif.rcl_node_init!(context, ~c"name", ~c"/namespace")
      assert is_reference(node)
      assert Nif.rcl_node_fini!(node) == :ok
    end

    test "rcl_node_init!/3 raise due to wrong node name", %{context: context} do
      try do
        Nif.rcl_node_init!(context, ~c"/name", ~c"/namespace")
      rescue
        ex ->
          %ErlangError{original: charlist, reason: nil} = ex

          assert "#{charlist}" =~
                   "node name must not contain characters other than alphanumerics or '_'"
      end
    end

    test "rcl_node_init!/3 raise due to wrong namespace", %{context: context} do
      try do
        Nif.rcl_node_init!(context, ~c"name", ~c"namespace")
      rescue
        ex ->
          %ErlangError{original: charlist, reason: nil} = ex

          assert "#{charlist}" =~ "namespace must be absolute, it must lead with a '/'"
      end
    end
  end

  describe "sensor_msgs_msg_point_cloud" do
    test "sensor_msgs_msg_point_cloud_type_support!/0" do
      assert is_reference(Nif.sensor_msgs_msg_point_cloud_type_support!())
    end

    test "sensor_msgs_msg_point_cloud_create!/1, sensor_msgs_msg_point_cloud_destroy!/1" do
      message = Nif.sensor_msgs_msg_point_cloud_create!()
      assert is_reference(message)
      assert Nif.sensor_msgs_msg_point_cloud_destroy!(message) == :ok
    end

    test "sensor_msgs_msg_point_cloud_set!/1, sensor_msgs_msg_point_cloud_get!/1" do
      message = Nif.sensor_msgs_msg_point_cloud_create!()

      assert Nif.sensor_msgs_msg_point_cloud_set!(
               message,
               {{{-9, 8}, ~c"test"}, [{0.1, 0.2, 0.3}, {0.4, 0.5, 0.6}, {0.7, 0.8, 0.9}],
                [{~c"channels_name", [0.0]}]}
             ) == :ok

      # assert Nif.sensor_msgs_msg_point_cloud_get!(message) ==
      #          {{{-9, 8}, ~c"test"}, [{0.1, 0.2, 0.3}, {0.4, 0.5, 0.6}, {0.7, 0.8, 0.9}],
      #           [{~c"channels_name", [0.0]}]}

      :ok = Nif.sensor_msgs_msg_point_cloud_destroy!(message)
    end
  end

  describe "std_msgs_msg_string" do
    test "std_msgs_msg_string_type_support!/0" do
      assert is_reference(Nif.std_msgs_msg_string_type_support!())
    end

    test "std_msgs_msg_string_create!/1, std_msgs_msg_string_destroy!/1" do
      message = Nif.std_msgs_msg_string_create!()
      assert is_reference(message)
      assert Nif.std_msgs_msg_string_destroy!(message) == :ok
    end

    test "std_msgs_msg_string_set!/1, std_msgs_msg_string_get!/1" do
      message = Nif.std_msgs_msg_string_create!()
      assert Nif.std_msgs_msg_string_set!(message, {~c"test"}) == :ok
      assert Nif.std_msgs_msg_string_get!(message) == {~c"test"}
      :ok = Nif.std_msgs_msg_string_destroy!(message)
    end
  end

  describe "std_msgs_msg_mutli_array_dimension" do
    test "std_msgs_msg_multi_array_dimension_type_support!/0" do
      assert is_reference(Nif.std_msgs_msg_multi_array_dimension_type_support!())
    end

    test "std_msgs_msg_multi_array_dimension_create!/1, std_msgs_msg_multi_array_dimension_destroy!/1" do
      message = Nif.std_msgs_msg_multi_array_dimension_create!()
      assert is_reference(message)
      assert Nif.std_msgs_msg_multi_array_dimension_destroy!(message) == :ok
    end

    test "std_msgs_msg_multi_array_dimension_set!/1, std_msgs_msg_multi_array_dimension_get!/1" do
      message = Nif.std_msgs_msg_multi_array_dimension_create!()
      assert Nif.std_msgs_msg_multi_array_dimension_set!(message, {~c"1", 2, 3}) == :ok
      assert Nif.std_msgs_msg_multi_array_dimension_get!(message) == {~c"1", 2, 3}
      :ok = Nif.std_msgs_msg_multi_array_dimension_destroy!(message)
    end
  end

  describe "std_msgs_msg_mutli_array_layout" do
    test "std_msgs_msg_multi_array_layout_type_support!/0" do
      assert is_reference(Nif.std_msgs_msg_multi_array_layout_type_support!())
    end

    test "std_msgs_msg_multi_array_layout_create!/1, std_msgs_msg_multi_array_layout_destroy!/1" do
      message = Nif.std_msgs_msg_multi_array_layout_create!()
      assert is_reference(message)
      assert Nif.std_msgs_msg_multi_array_layout_destroy!(message) == :ok
    end

    test "std_msgs_msg_multi_array_layout_set!/1, std_msgs_msg_multi_array_layout_get!/1" do
      message = Nif.std_msgs_msg_multi_array_layout_create!()

      assert Nif.std_msgs_msg_multi_array_layout_set!(
               message,
               {[{~c"1", 2, 3}, {~c"4", 5, 6}, {~c"7", 8, 9}], 10}
             ) == :ok

      assert Nif.std_msgs_msg_multi_array_layout_get!(message) ==
               {[{~c"1", 2, 3}, {~c"4", 5, 6}, {~c"7", 8, 9}], 10}

      :ok = Nif.std_msgs_msg_multi_array_layout_destroy!(message)
    end
  end

  describe "std_msgs_msg_u_int32_multi_array" do
    test "std_msgs_msg_u_int32_multi_array_type_support!/0" do
      assert is_reference(Nif.std_msgs_msg_u_int32_multi_array_type_support!())
    end

    test "std_msgs_msg_u_int32_multi_array_create!/1, std_msgs_msg_u_int32_multi_array_destroy!/1" do
      message = Nif.std_msgs_msg_u_int32_multi_array_create!()
      assert is_reference(message)
      assert Nif.std_msgs_msg_u_int32_multi_array_destroy!(message) == :ok
    end

    test "std_msgs_msg_u_int32_multi_array_set!/1, std_msgs_msg_u_int32_multi_array_get!/1" do
      message = Nif.std_msgs_msg_u_int32_multi_array_create!()

      assert Nif.std_msgs_msg_u_int32_multi_array_set!(
               message,
               {{[{~c"test", 2, 3}, {~c"4", 5, 6}, {~c"7", 8, 9}], 10}, [1, 2, 3]}
             ) == :ok

      assert Nif.std_msgs_msg_u_int32_multi_array_get!(message) ==
               {{[{~c"test", 2, 3}, {~c"4", 5, 6}, {~c"7", 8, 9}], 10}, [1, 2, 3]}

      :ok = Nif.std_msgs_msg_u_int32_multi_array_destroy!(message)
    end
  end

  describe "geometry_msgs_msg_vector3" do
    test "geometry_msgs_msg_vector3_type_support!/0" do
      assert is_reference(Nif.geometry_msgs_msg_vector3_type_support!())
    end

    test "geometry_msgs_msg_vector3_create!/1, geometry_msgs_msg_vector3_destroy!/1" do
      message = Nif.geometry_msgs_msg_vector3_create!()
      assert is_reference(message)
      assert Nif.geometry_msgs_msg_vector3_destroy!(message) == :ok
    end

    test "geometry_msgs_msg_vector3_set!/1, geometry_msgs_msg_vector3_get!/1" do
      message = Nif.geometry_msgs_msg_vector3_create!()
      assert Nif.geometry_msgs_msg_vector3_set!(message, {1.0, 2.0, 3.0}) == :ok
      assert Nif.geometry_msgs_msg_vector3_get!(message) == {1.0, 2.0, 3.0}
      :ok = Nif.geometry_msgs_msg_vector3_destroy!(message)
    end
  end

  describe "geometry_msgs_msg_twist" do
    test "geometry_msgs_msg_twist_type_support!/0" do
      assert is_reference(Nif.geometry_msgs_msg_twist_type_support!())
    end

    test "geometry_msgs_msg_twist_create!/1, geometry_msgs_msg_twist_destroy!/1" do
      message = Nif.geometry_msgs_msg_twist_create!()
      assert is_reference(message)
      assert Nif.geometry_msgs_msg_twist_destroy!(message) == :ok
    end

    test "geometry_msgs_msg_twist_set!/1, geometry_msgs_msg_twist_get!/1" do
      message = Nif.geometry_msgs_msg_twist_create!()
      assert Nif.geometry_msgs_msg_twist_set!(message, {{1.0, 2.0, 3.0}, {4.0, 5.0, 6.0}}) == :ok
      assert Nif.geometry_msgs_msg_twist_get!(message) == {{1.0, 2.0, 3.0}, {4.0, 5.0, 6.0}}
      :ok = Nif.geometry_msgs_msg_twist_destroy!(message)
    end
  end

  describe "publisher" do
    setup do
      context = Nif.rcl_init!()
      node = Nif.rcl_node_init!(context, ~c"name", ~c"/namespace")
      type_support = Nif.std_msgs_msg_string_type_support!()

      on_exit(fn ->
        Nif.rcl_node_fini!(node)
        Nif.rcl_fini!(context)
      end)

      %{node: node, type_support: type_support}
    end

    test "rcl_publisher_init!/3, rcl_publisher_fini!/2", %{node: node, type_support: type_support} do
      publisher = Nif.rcl_publisher_init!(node, type_support, ~c"/topic")
      assert is_reference(publisher)
      assert Nif.rcl_publisher_fini!(publisher, node) == :ok
    end

    test "rcl_publisher_init!/3 raise due to wrong topic name", %{
      node: node,
      type_support: type_support
    } do
      assert_raise ErlangError, fn ->
        Nif.rcl_publisher_init!(node, type_support, ~c"topic")
      end
    end
  end

  describe "publish/take" do
    setup do
      context = Nif.rcl_init!()
      node = Nif.rcl_node_init!(context, ~c"name", ~c"/namespace")
      type_support = Nif.std_msgs_msg_string_type_support!()
      publisher = Nif.rcl_publisher_init!(node, type_support, ~c"/chatter")
      subscription = Nif.rcl_subscription_init!(node, type_support, ~c"/chatter")
      wait_set = Nif.rcl_wait_set_init_subscription!(context)
      message = Nif.std_msgs_msg_string_create!()
      :ok = Nif.std_msgs_msg_string_set!(message, {~c"Hello from Rclex"})

      on_exit(fn ->
        Nif.std_msgs_msg_string_destroy!(message)
        Nif.rcl_wait_set_fini!(wait_set)
        Nif.rcl_publisher_fini!(publisher, node)
        Nif.rcl_subscription_fini!(subscription, node)
        Nif.rcl_node_fini!(node)
        Nif.rcl_fini!(context)
      end)

      %{publisher: publisher, subscription: subscription, wait_set: wait_set, message: message}
    end

    test "publish!/2", %{publisher: publisher, message: message} do
      assert Nif.rcl_publish!(publisher, message) == :ok
    end

    test "take!/2 raise", %{subscription: subscription, message: message} do
      assert_raise ErlangError, fn -> Nif.rcl_take!(subscription, message) end
    end

    test "take!/2", %{
      publisher: publisher,
      subscription: subscription,
      wait_set: wait_set,
      message: message
    } do
      :ok = Nif.rcl_publish!(publisher, message)
      :ok = Nif.rcl_wait_subscription!(wait_set, 1000, subscription)
      assert Nif.rcl_take!(subscription, message) == :ok
      assert Nif.std_msgs_msg_string_get!(message) == {~c"Hello from Rclex"}
    end
  end

  describe "subscription" do
    setup do
      context = Nif.rcl_init!()
      node = Nif.rcl_node_init!(context, ~c"name", ~c"/namespace")
      type_support = Nif.std_msgs_msg_string_type_support!()

      on_exit(fn ->
        Nif.rcl_node_fini!(node)
        Nif.rcl_fini!(context)
      end)

      %{node: node, type_support: type_support}
    end

    test "rcl_subscription_init!/3, rcl_subscription_fini!/2", %{
      node: node,
      type_support: type_support
    } do
      subscription = Nif.rcl_subscription_init!(node, type_support, ~c"/topic")
      assert is_reference(subscription)
      assert Nif.rcl_subscription_fini!(subscription, node) == :ok
    end

    test "rcl_subscription_init!/3 raise due to wrong topic name", %{
      node: node,
      type_support: type_support
    } do
      assert_raise ErlangError, fn ->
        Nif.rcl_subscription_init!(node, type_support, ~c"topic")
      end
    end
  end

  describe "wait_set" do
    setup do
      context = Nif.rcl_init!()
      node = Nif.rcl_node_init!(context, ~c"name", ~c"/namespace")
      type_support = Nif.std_msgs_msg_string_type_support!()
      subscription = Nif.rcl_subscription_init!(node, type_support, ~c"/topic")

      on_exit(fn ->
        Nif.rcl_subscription_fini!(subscription, node)
        Nif.rcl_node_fini!(node)
        Nif.rcl_fini!(context)
      end)

      %{context: context, subscription: subscription}
    end

    test "rcl_wait_set_init_subscription!/1, rcl_wait_set_fini!/1", %{context: context} do
      wait_set = Nif.rcl_wait_set_init_subscription!(context)
      assert is_reference(wait_set)
      assert Nif.rcl_wait_set_fini!(wait_set) == :ok
    end

    test "rcl_wait_subscription!/3 timeout", %{
      context: context,
      subscription: subscription
    } do
      wait_set = Nif.rcl_wait_set_init_subscription!(context)
      timeout_us = 1000
      assert Nif.rcl_wait_subscription!(wait_set, timeout_us, subscription) == :timeout
      :ok = Nif.rcl_wait_set_fini!(wait_set)
    end
  end
end
