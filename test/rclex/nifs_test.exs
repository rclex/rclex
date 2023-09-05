defmodule Rclex.NifsTest do
  use ExUnit.Case

  require Rclex.ReturnCode

  import Rclex.TestUtils,
    only: [
      get_initialized_context: 0,
      get_initialized_no_namespace_node: 1,
      get_initialized_no_namespace_node: 2,
      get_initialized_publisher: 1,
      get_initialized_publisher: 2,
      get_initialized_subscription: 1,
      get_initialized_subscription: 2
    ]

  alias Rclex.Nifs

  describe "init_nif" do
    test "rcl_init_options_init/1 return :ok" do
      options = Nifs.rcl_get_zero_initialized_init_options()

      try do
        assert is_reference(options)
        assert :ok = Nifs.rcl_init_options_init(options)
      after
        # clean up resource
        Nifs.rcl_init_options_fini(options)
      end
    end

    test "rcl_init_options_init/1 raise ArgumentError" do
      assert_raise ArgumentError, fn -> Nifs.rcl_init_options_init(make_ref()) end
    end

    test "rcl_init_options_fini/1 return reference" do
      options = Nifs.rcl_get_zero_initialized_init_options()
      :ok = Nifs.rcl_init_options_init(options)

      assert is_reference(Nifs.rcl_init_options_fini(options))
    end

    # WHY: DO NOT SEPARATE THIS TESTS
    # because rcl_shutdown expects context is initialized with options
    test """
    rcl_get_zero_initialized_context/0 return reference
    rcl_init_with_null/2 return reference
    """ do
      options = Nifs.rcl_get_zero_initialized_init_options()
      :ok = Nifs.rcl_init_options_init(options)
      context = Nifs.rcl_get_zero_initialized_context()

      try do
        assert is_reference(context)
        assert is_reference(Nifs.rcl_init_with_null(options, context))
      after
        # clean up resource
        Nifs.rcl_init_options_fini(options)
        Nifs.rcl_shutdown(context)
      end
    end

    test "rcl_shutdown/1 return {:ok, reference}" do
      context = get_initialized_context()

      assert {:ok, rcl_ret} = Nifs.rcl_shutdown(context)
      assert is_reference(rcl_ret)
    end
  end

  describe "node_nif" do
    setup do
      context = get_initialized_context()
      on_exit(fn -> Nifs.rcl_shutdown(context) end)
      %{context: context}
    end

    test "rcl_get_zero_initialized_node/0 return reference" do
      node = Nifs.rcl_get_zero_initialized_node()

      try do
        assert is_reference(node)
      after
        # clean up resource
        Nifs.rcl_node_fini(node)
      end
    end

    test "rcl_node_get_default_options/0 return reference" do
      assert is_reference(Nifs.rcl_node_get_default_options())

      # TODO: clean up options, currently we don't have the function
    end

    test "rcl_node_init/5 return reference", %{context: context} do
      node = Nifs.rcl_get_zero_initialized_node()
      node_name = 'node'
      node_namespace = 'namespace'
      options = Nifs.rcl_node_get_default_options()

      try do
        assert is_reference(Nifs.rcl_node_init(node, node_name, node_namespace, context, options))
      after
        # TODO: clean up options, currently we don't have the function
        Nifs.rcl_node_fini(node)
      end
    end

    test "rcl_node_init_without_namespace/4 return reference", %{context: context} do
      node_name = 'node'
      node = Nifs.rcl_get_zero_initialized_node()
      options = Nifs.rcl_node_get_default_options()

      try do
        assert is_reference(
                 Nifs.rcl_node_init_without_namespace(node, node_name, context, options)
               )
      after
        # TODO: clean up options, currently we don't have the function
        Nifs.rcl_node_fini(node)
      end
    end

    test "rcl_node_fini/1 return reference", %{context: context} do
      node = get_initialized_no_namespace_node(context)

      assert is_reference(Nifs.rcl_node_fini(node))
    end

    test "rcl_node_get_name/1 return charlist", %{context: context} do
      node_name = 'test'
      node = get_initialized_no_namespace_node(context, node_name)

      try do
        assert ^node_name = Nifs.rcl_node_get_name(node)
      after
        # clean up resource
        Nifs.rcl_node_fini(node)
      end
    end
  end

  describe "publisher_nif" do
    setup do
      context = get_initialized_context()
      node = get_initialized_no_namespace_node(context)

      on_exit(fn ->
        Nifs.rcl_shutdown(context)
        Nifs.rcl_node_fini(node)
      end)

      %{node: node}
    end

    test "rcl_get_zero_initialized_publisher/0 return reference" do
      assert is_reference(Nifs.rcl_get_zero_initialized_publisher())
      # TODO: clean up publisher ?
    end

    test "rcl_publisher_get_default_options/0 return reference" do
      assert is_reference(Nifs.rcl_publisher_get_default_options())
      # TODO: clean up options ?
    end

    test "rcl_publisher_fini/2 return reference", %{node: node} do
      publisher = get_initialized_publisher(node)

      assert is_reference(Nifs.rcl_publisher_fini(publisher, node))
    end

    test "rcl_publisher_init/5 return reference", %{node: node} do
      publisher = Nifs.rcl_get_zero_initialized_publisher()

      topic = 'topic'
      typesupport = Rclex.Msg.typesupport('StdMsgs.Msg.String')
      publisher_options = Nifs.rcl_publisher_get_default_options()

      try do
        assert is_reference(
                 Nifs.rcl_publisher_init(publisher, node, topic, typesupport, publisher_options)
               )
      after
        # clean up resource
        Nifs.rcl_publisher_fini(publisher, node)
      end
    end

    test "rcl_publisher_is_valid/1 return true", %{node: node} do
      publisher = get_initialized_publisher(node)

      try do
        assert true = Nifs.rcl_publisher_is_valid(publisher)
      after
        # clean up resource
        Nifs.rcl_publisher_fini(publisher, node)
      end
    end

    test "rcl_publish/3 return rcl_ret_ok tuple", %{node: node} do
      publisher = get_initialized_publisher(node)

      publisher_allocation = Nifs.create_pub_alloc()

      message = Rclex.Msg.initialize('StdMsgs.Msg.String')

      :ok =
        Rclex.Msg.set(
          message,
          %Rclex.StdMsgs.Msg.String{data: 'data'},
          'StdMsgs.Msg.String'
        )

      rcl_ret_ok = Rclex.ReturnCode.rcl_ret_ok()

      try do
        assert {^rcl_ret_ok, publisher, publisher_allocation} =
                 Nifs.rcl_publish(publisher, message, publisher_allocation)

        assert is_reference(publisher)
        assert is_reference(publisher_allocation)
      after
        # clean up resource
        Nifs.rcl_publisher_fini(publisher, node)
      end
    end
  end

  describe "subscription_nif" do
    setup do
      context = get_initialized_context()
      node = get_initialized_no_namespace_node(context)

      on_exit(fn ->
        Nifs.rcl_shutdown(context)
        Nifs.rcl_node_fini(node)
      end)

      %{node: node}
    end

    test "create_pub_alloc/0 return reference" do
      assert is_reference(Nifs.create_pub_alloc())
    end

    test "rcl_subscription_get_default_options/0 return reference" do
      assert is_reference(Nifs.rcl_subscription_get_default_options())
    end

    test "rcl_get_zero_initialized_subscription/0 return reference" do
      assert is_reference(Nifs.rcl_get_zero_initialized_subscription())
    end

    test "create_sub_alloc/0 return reference" do
      assert is_reference(Nifs.create_sub_alloc())
    end

    test "rcl_subscription_init/5 return reference", %{node: node} do
      subscription = Nifs.rcl_get_zero_initialized_subscription()

      topic = 'topic'
      typesupport = Rclex.Msg.typesupport('StdMsgs.Msg.String')
      subscription_options = Nifs.rcl_subscription_get_default_options()

      try do
        assert is_reference(
                 Nifs.rcl_subscription_init(
                   subscription,
                   node,
                   topic,
                   typesupport,
                   subscription_options
                 )
               )
      after
        # clean up resource
        Nifs.rcl_subscription_fini(subscription, node)
      end
    end

    test "rcl_subscription_fini/2 return reference", %{node: node} do
      subscription = get_initialized_subscription(node)

      assert is_reference(Nifs.rcl_subscription_fini(subscription, node))
    end

    test "rcl_subscription_get_topic_name/1 return charlist", %{node: node} do
      topic_name = 'test'
      subscription = get_initialized_subscription(node, topic_name)

      try do
        # TODO: get_topic_name が '/' 含んで返すことが正か仕様の確認
        [_slash | topic] = Nifs.rcl_subscription_get_topic_name(subscription)
        assert ^topic_name = topic
      after
        # clean up resource
        Nifs.rcl_subscription_fini(subscription, node)
      end
    end

    test "rcl_take/4 return tuple", %{node: node} do
      subscription = get_initialized_subscription(node)

      msg = Rclex.Msg.initialize('StdMsgs.Msg.String')
      msginfo = Nifs.create_msginfo()
      subscription_allocation = Nifs.create_sub_alloc()

      rcl_ret_subscription_take_failed = Rclex.ReturnCode.rcl_ret_subscription_take_failed()

      try do
        assert {^rcl_ret_subscription_take_failed, subscription, msginfo, subscription_allocation} =
                 Nifs.rcl_take(subscription, msg, msginfo, subscription_allocation)

        assert is_reference(subscription)
        assert is_reference(msginfo)
        assert is_reference(subscription_allocation)
      after
        # clean up resource
        Nifs.rcl_subscription_fini(subscription, node)
      end
    end
  end

  describe "rcl_get_topic_names_and_types/3" do
    setup do
      context = get_initialized_context()
      node = get_initialized_no_namespace_node(context)

      on_exit(fn ->
        Nifs.rcl_node_fini(node)
        Nifs.rcl_shutdown(context)
      end)

      %{node: node}
    end

    test "node isn't assigned, return empty list", %{node: node} do
      allocator = Nifs.rcl_get_default_allocator()
      assert [] = Nifs.rcl_get_topic_names_and_types(node, allocator, true)
      assert [] = Nifs.rcl_get_topic_names_and_types(node, allocator, false)
    end

    test "node is assigned publisher, return list", %{node: node} do
      topic_name = 'test'
      publisher = get_initialized_publisher(node, topic_name)
      allocator = Nifs.rcl_get_default_allocator()

      try do
        assert [{'/' ++ topic_name, ['std_msgs/msg/String']}] ==
                 Nifs.rcl_get_topic_names_and_types(node, allocator, true)

        assert [{'/' ++ topic_name, ['std_msgs/msg/String']}] ==
                 Nifs.rcl_get_topic_names_and_types(node, allocator, false)
      after
        Nifs.rcl_publisher_fini(publisher, node)
      end
    end

    test "node is assigned subscription, return list", %{node: node} do
      topic_name = 'test'
      subscription = get_initialized_subscription(node, topic_name)
      allocator = Nifs.rcl_get_default_allocator()

      try do
        assert [{'/' ++ topic_name, ['std_msgs/msg/String']}] ==
                 Nifs.rcl_get_topic_names_and_types(node, allocator, true)

        assert [{'/' ++ topic_name, ['std_msgs/msg/String']}] ==
                 Nifs.rcl_get_topic_names_and_types(node, allocator, false)
      after
        Nifs.rcl_subscription_fini(subscription, node)
      end
    end
  end
end
