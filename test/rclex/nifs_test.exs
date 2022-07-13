defmodule Rclex.NifsTest do
  use ExUnit.Case

  require Rclex.ReturnCode

  import Rclex.TestUtils,
    only: [
      get_initialized_context: 0,
      get_initialized_no_namespace_node: 1,
      get_initialized_no_namespace_node: 2,
      get_initialized_publisher: 1,
      get_initialized_subscription: 1,
      get_initialized_subscription: 2
    ]

  alias Rclex.Nifs

  describe "rcl_get_zero_initialized_init_options/0" do
    test "return reference" do
      assert is_reference(Nifs.rcl_get_zero_initialized_init_options())
    end
  end

  describe "rcl_init_options_init/1" do
    test "return :ok" do
      assert :ok =
               Nifs.rcl_get_zero_initialized_init_options()
               |> Nifs.rcl_init_options_init()
    end

    test "raise ArgumentError" do
      assert_raise ArgumentError, fn ->
        make_ref()
        |> Nifs.rcl_init_options_init()
      end
    end
  end

  describe "rcl_init_options_fini/1" do
    test "return reference" do
      options = Nifs.rcl_get_zero_initialized_init_options()
      :ok = Nifs.rcl_init_options_init(options)
      assert is_reference(Nifs.rcl_init_options_fini(options))
    end
  end

  describe "rcl_get_zero_initialized_context/0" do
    test "return reference" do
      assert is_reference(Nifs.rcl_get_zero_initialized_context())
    end
  end

  describe "rcl_init_with_null/2" do
    test "return reference" do
      init_options = Nifs.rcl_get_zero_initialized_init_options()
      context = Nifs.rcl_get_zero_initialized_context()
      assert is_reference(Nifs.rcl_init_with_null(init_options, context))
    end
  end

  describe "rcl_shutdown/1" do
    test "return {:ok, reference}" do
      context = get_initialized_context()

      assert {:ok, context} = Nifs.rcl_shutdown(context)
      assert is_reference(context)
    end
  end

  describe "rcl_get_zero_initialized_node/0" do
    test "return reference" do
      assert is_reference(Nifs.rcl_get_zero_initialized_node())
    end
  end

  describe "rcl_node_get_default_options/0" do
    test "return reference" do
      assert is_reference(Nifs.rcl_node_get_default_options())
    end
  end

  describe "rcl_node_init/5" do
    test "return reference" do
      node = Nifs.rcl_get_zero_initialized_node()
      node_name = 'node'
      node_namespace = 'namespace'
      context = get_initialized_context()
      options = Nifs.rcl_node_get_default_options()

      assert is_reference(Nifs.rcl_node_init(node, node_name, node_namespace, context, options))
    end
  end

  describe "rcl_node_init_without_namespace/4" do
    test "return reference" do
      node = Nifs.rcl_get_zero_initialized_node()
      node_name = 'node'
      context = get_initialized_context()
      options = Nifs.rcl_node_get_default_options()

      assert is_reference(Nifs.rcl_node_init_without_namespace(node, node_name, context, options))
    end
  end

  describe "rcl_node_fini/1" do
    test "return reference" do
      node =
        get_initialized_context()
        |> get_initialized_no_namespace_node()

      assert is_reference(Nifs.rcl_node_fini(node))
    end
  end

  describe "rcl_node_get_name/1" do
    test "return charlist" do
      node_name = 'test'

      node =
        get_initialized_context()
        |> get_initialized_no_namespace_node(node_name)

      assert ^node_name = Nifs.rcl_node_get_name(node)
    end
  end

  describe "rcl_get_zero_initialized_publisher/0" do
    test "return reference" do
      assert is_reference(Nifs.rcl_get_zero_initialized_publisher())
    end
  end

  describe "rcl_publisher_get_default_options/0" do
    test "return reference" do
      assert is_reference(Nifs.rcl_publisher_get_default_options())
    end
  end

  describe "rcl_publisher_fini/2" do
    test "return reference" do
      node =
        get_initialized_context()
        |> get_initialized_no_namespace_node()

      publihser = get_initialized_publisher(node)

      assert is_reference(Nifs.rcl_publisher_fini(publihser, node))
    end
  end

  describe "rcl_publisher_init/5" do
    test "reutrn reference" do
      publisher = Nifs.rcl_get_zero_initialized_publisher()

      node =
        get_initialized_context()
        |> get_initialized_no_namespace_node()

      topic = 'topic'
      typesupport = Rclex.Msg.typesupport('StdMsgs.Msg.String')
      publisher_options = Nifs.rcl_publisher_get_default_options()

      assert is_reference(
               Nifs.rcl_publisher_init(publisher, node, topic, typesupport, publisher_options)
             )
    end
  end

  describe "rcl_publisher_is_valid/1" do
    test "return true" do
      publisher =
        get_initialized_context()
        |> get_initialized_no_namespace_node()
        |> get_initialized_publisher()

      assert true = Nifs.rcl_publisher_is_valid(publisher)
    end
  end

  describe "rcl_publish/3" do
    test "return rcl_ret_ok tuple" do
      publisher =
        get_initialized_context()
        |> get_initialized_no_namespace_node()
        |> get_initialized_publisher()

      publisher_allocation = Nifs.create_pub_alloc()

      message = Rclex.Msg.initialize('StdMsgs.Msg.String')

      :ok =
        Rclex.Msg.set(
          message,
          %Rclex.StdMsgs.Msg.String{data: 'data'},
          'StdMsgs.Msg.String'
        )

      rcl_ret_ok = Rclex.ReturnCode.rcl_ret_ok()

      assert {^rcl_ret_ok, publisher, publisher_allocation} =
               Nifs.rcl_publish(publisher, message, publisher_allocation)

      assert is_reference(publisher)
      assert is_reference(publisher_allocation)
    end
  end

  describe "create_pub_alloc/0" do
    test "return reference" do
      assert is_reference(Nifs.create_pub_alloc())
    end
  end

  describe "rcl_subscription_get_default_options/0" do
    test "return reference" do
      assert is_reference(Nifs.rcl_subscription_get_default_options())
    end
  end

  describe "rcl_get_zero_initialized_subscription/0" do
    test "return reference" do
      assert is_reference(Nifs.rcl_get_zero_initialized_subscription())
    end
  end

  describe "create_sub_alloc/0" do
    test "return reference" do
      assert is_reference(Nifs.create_sub_alloc())
    end
  end

  describe "rcl_subscription_init/5" do
    test "return reference" do
      subscription = Nifs.rcl_get_zero_initialized_subscription()

      node =
        get_initialized_context()
        |> get_initialized_no_namespace_node()

      topic = 'topic'
      typesupport = Rclex.Msg.typesupport('StdMsgs.Msg.String')
      subscription_options = Nifs.rcl_subscription_get_default_options()

      assert is_reference(
               Nifs.rcl_subscription_init(
                 subscription,
                 node,
                 topic,
                 typesupport,
                 subscription_options
               )
             )
    end
  end

  describe "rcl_subscription_fini/2" do
    test "return reference" do
      node =
        get_initialized_context()
        |> get_initialized_no_namespace_node()

      subscription = get_initialized_subscription(node)

      assert is_reference(Nifs.rcl_subscription_fini(subscription, node))
    end
  end

  describe "rcl_subscription_get_topic_name/1" do
    test "return charlist" do
      node =
        get_initialized_context()
        |> get_initialized_no_namespace_node()

      topic_name = 'test'
      subscription = get_initialized_subscription(node, topic_name)

      # TODO: get_topic_name が '/' 含んで返すことが正か仕様の確認
      [_slash | topic] = Nifs.rcl_subscription_get_topic_name(subscription)
      assert ^topic_name = topic
    end
  end

  describe "rcl_take/4" do
    test "return tuple" do
      node =
        get_initialized_context()
        |> get_initialized_no_namespace_node()

      subscription = get_initialized_subscription(node)

      msg = Rclex.Msg.initialize('StdMsgs.Msg.String')
      msginfo = Nifs.create_msginfo()
      subscription_allocation = Nifs.create_sub_alloc()

      rcl_ret_subscription_take_failed = Rclex.ReturnCode.rcl_ret_subscription_take_failed()

      assert {^rcl_ret_subscription_take_failed, subscription, msginfo, subscription_allocation} =
               Nifs.rcl_take(subscription, msg, msginfo, subscription_allocation)

      assert is_reference(subscription)
      assert is_reference(msginfo)
      assert is_reference(subscription_allocation)
    end
  end
end
