alias Rclex.Nif
alias Rclex.Qos

Benchee.run(
  %{
    "rcl_init!/0" =>
      {fn ->
         Nif.rcl_init!()
       end,
       after_each: fn context ->
         :ok = Nif.rcl_fini!(context)
       end},
    "rcl_fini!/1" =>
      {fn context ->
         :ok = Nif.rcl_fini!(context)
       end,
       before_each: fn _ ->
         Nif.rcl_init!()
       end},
    "rcl_node_init!/3" =>
      {fn context ->
         Nif.rcl_node_init!(context, ~c"name", ~c"/namespace")
       end,
       before_scenario: fn _ ->
         Nif.rcl_init!()
       end,
       after_each: fn node ->
         :ok = Nif.rcl_node_fini!(node)
       end,
       after_scenario: fn context ->
         :ok = Nif.rcl_fini!(context)
       end},
    "rcl_node_fini!/1" =>
      {fn node ->
         :ok = Nif.rcl_node_fini!(node)
       end,
       before_scenario: fn _ ->
         Nif.rcl_init!()
       end,
       before_each: fn context ->
         Nif.rcl_node_init!(context, ~c"name", ~c"/namespace")
       end,
       after_scenario: fn context ->
         :ok = Nif.rcl_fini!(context)
       end},
    "rcl_publisher_init!/4" =>
      {fn {type_support, node, _context} ->
         publisher =
           Nif.rcl_publisher_init!(node, type_support, ~c"/chatter", Qos.profile_default())

         {publisher, node}
       end,
       before_scenario: fn _ ->
         context = Nif.rcl_init!()
         node = Nif.rcl_node_init!(context, ~c"name", ~c"/namespace")
         type_support = Nif.std_msgs_msg_string_type_support!()
         {type_support, node, context}
       end,
       after_each: fn {publisher, node} ->
         :ok = Nif.rcl_publisher_fini!(publisher, node)
       end,
       after_scenario: fn {_type_support, node, context} ->
         :ok = Nif.rcl_node_fini!(node)
         :ok = Nif.rcl_fini!(context)
       end},
    "rcl_publisher_fini!/2" =>
      {fn {publisher, node} ->
         :ok = Nif.rcl_publisher_fini!(publisher, node)
       end,
       before_scenario: fn _ ->
         context = Nif.rcl_init!()
         node = Nif.rcl_node_init!(context, ~c"name", ~c"/namespace")
         type_support = Nif.std_msgs_msg_string_type_support!()
         {type_support, node, context}
       end,
       before_each: fn {type_support, node, _context} ->
         publisher =
           Nif.rcl_publisher_init!(node, type_support, ~c"/chatter", Qos.profile_default())

         {publisher, node}
       end,
       after_scenario: fn {_, node, context} ->
         :ok = Nif.rcl_node_fini!(node)
         :ok = Nif.rcl_fini!(context)
       end},
    "rcl_publish!/2" =>
      {fn {message, publisher, _node, _context} ->
         :ok = Nif.rcl_publish!(publisher, message)
       end,
       before_scenario: fn _ ->
         context = Nif.rcl_init!()
         node = Nif.rcl_node_init!(context, ~c"name", ~c"/namespace")
         type_support = Nif.std_msgs_msg_string_type_support!()

         publisher =
           Nif.rcl_publisher_init!(node, type_support, ~c"/chatter", Qos.profile_default())

         message = Nif.std_msgs_msg_string_create!()
         :ok = Nif.std_msgs_msg_string_set!(message, {~c"hello"})
         {message, publisher, node, context}
       end,
       after_scenario: fn {message, publisher, node, context} ->
         :ok = Nif.std_msgs_msg_string_destroy!(message)
         :ok = Nif.rcl_publisher_fini!(publisher, node)
         :ok = Nif.rcl_node_fini!(node)
         :ok = Nif.rcl_fini!(context)
       end},
    "rcl_subscription_init!/4" =>
      {fn {type_support, node, _context} ->
         subscription =
           Nif.rcl_subscription_init!(node, type_support, ~c"/chatter", Qos.profile_default())

         {subscription, node}
       end,
       before_scenario: fn _ ->
         context = Nif.rcl_init!()
         node = Nif.rcl_node_init!(context, ~c"name", ~c"/namespace")
         type_support = Nif.std_msgs_msg_string_type_support!()
         {type_support, node, context}
       end,
       after_each: fn {subscription, node} ->
         :ok = Nif.rcl_subscription_fini!(subscription, node)
       end,
       after_scenario: fn {_type_support, node, context} ->
         :ok = Nif.rcl_node_fini!(node)
         :ok = Nif.rcl_fini!(context)
       end},
    "rcl_subscription_fini!/2" =>
      {fn {subscription, node} ->
         :ok = Nif.rcl_subscription_fini!(subscription, node)
       end,
       before_scenario: fn _ ->
         context = Nif.rcl_init!()
         node = Nif.rcl_node_init!(context, ~c"name", ~c"/namespace")
         type_support = Nif.std_msgs_msg_string_type_support!()
         {type_support, node, context}
       end,
       before_each: fn {type_support, node, _context} ->
         subscription =
           Nif.rcl_subscription_init!(node, type_support, ~c"/chatter", Qos.profile_default())

         {subscription, node}
       end,
       after_scenario: fn {_, node, context} ->
         :ok = Nif.rcl_node_fini!(node)
         :ok = Nif.rcl_fini!(context)
       end},
    "rcl_take!/2" =>
      {fn {message, subscription} ->
         :ok = Nif.rcl_take!(subscription, message)
       end,
       before_scenario: fn _ ->
         context = Nif.rcl_init!()
         node = Nif.rcl_node_init!(context, ~c"name", ~c"/namespace")
         type_support = Nif.std_msgs_msg_string_type_support!()

         publisher =
           Nif.rcl_publisher_init!(node, type_support, ~c"/chatter", Qos.profile_default())

         subscription =
           Nif.rcl_subscription_init!(node, type_support, ~c"/chatter", Qos.profile_default())

         wait_set = Nif.rcl_wait_set_init_subscription!(context)
         message = Nif.std_msgs_msg_string_create!()
         :ok = Nif.std_msgs_msg_string_set!(message, {~c"hello"})
         {message, wait_set, subscription, publisher, node, context}
       end,
       before_each: fn {message, wait_set, subscription, publisher, _node, _context} ->
         :ok = Nif.rcl_publish!(publisher, message)
         :ok = Nif.rcl_wait_subscription!(wait_set, 1000, subscription)
         {message, subscription}
       end,
       after_scenario: fn {message, wait_set, subscription, publisher, node, context} ->
         :ok = Nif.std_msgs_msg_string_destroy!(message)
         :ok = Nif.rcl_wait_set_fini!(wait_set)
         :ok = Nif.rcl_subscription_fini!(subscription, node)
         :ok = Nif.rcl_publisher_fini!(publisher, node)
         :ok = Nif.rcl_node_fini!(node)
         :ok = Nif.rcl_fini!(context)
       end},
    "rcl_wait_set_init_subscription!/1" =>
      {fn context ->
         Nif.rcl_wait_set_init_subscription!(context)
       end,
       before_scenario: fn _ ->
         Nif.rcl_init!()
       end,
       after_each: fn wait_set ->
         :ok = Nif.rcl_wait_set_fini!(wait_set)
       end,
       after_scenario: fn context ->
         :ok = Nif.rcl_fini!(context)
       end},
    "rcl_wait_set_fini!/1" =>
      {fn wait_set ->
         :ok = Nif.rcl_wait_set_fini!(wait_set)
       end,
       before_scenario: fn _ ->
         Nif.rcl_init!()
       end,
       before_each: fn context ->
         Nif.rcl_wait_set_init_subscription!(context)
       end,
       after_scenario: fn context ->
         :ok = Nif.rcl_fini!(context)
       end}
  },
  time: 1
)
