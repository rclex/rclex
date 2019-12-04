module Rclex.Native

callback :load

spec state_init() :: {:ok ::label, state}

# 一部だけ残してほかは残す関数に含めることでユーザーから隠す
spec rcl_get_zero_initialized_context() :: {init_options}  
spec rcl_get_zero_initialized_context() :: {context}
spec rcl_init(0,[],init_options,context) :: {:ok ::label, ret}

spec rcl_node_get_default_options() :: {node_options}
spec rcl_get_zero_initialized_node() :: {node}

spec rcl_node_init(node,'test_node','test_namespace_',context,node_options)

spec rcl_get_zero_initialized_publisher() :: {publisher}
spec rcl_publisher_get_default_options() :: {publisher_options}


spec check_state(target :: pid, state) :: {:ok :: label,answer :: int} | {:error :: label, reason :: atom}