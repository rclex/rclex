module Rclex.Native

callback :load

spec state_init() :: {:ok ::label, state}
spec state_init2() :: {:ok ::label, statetwo}
#spec rcl_get_zero_initialized_dontext() :: {rcl_context_t}

spec check_state(target :: pid, state) :: {:ok :: label,answer :: int} | {:error :: label, reason :: atom}