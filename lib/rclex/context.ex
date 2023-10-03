defmodule Rclex.Context do
  @moduledoc false

  use GenServer

  require Logger

  alias Rclex.Nif

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def get() do
    GenServer.call(__MODULE__, :get)
  end

  # callbacks

  def init(_args) do
    Process.flag(:trap_exit, true)

    context = Nif.rcl_init!()

    {:ok, %{context: context}}
  end

  def terminate(reason, state) do
    Nif.rcl_fini!(state.context)

    Logger.debug("#{__MODULE__}: #{inspect(reason)}")
  end

  def handle_call(:get, _from, state) do
    {:reply, state.context, state}
  end
end
