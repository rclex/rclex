defmodule Rclex.TimerTest do
  use ExUnit.Case

  import ExUnit.CaptureLog

  setup do
    require Logger
    callback = fn message -> Logger.info(message) end
    args = "test"
    time = 1000
    timer_name = 'timer'
    limit = 0
    queue_length = 1
    change_order = fn l when is_list(l) -> l end

    # only to suppress log
    capture_log(fn ->
      start_supervised!(
        {Rclex.Timer, {callback, args, time, timer_name, limit, {queue_length, change_order}}}
      )
    end)

    %{name: {:global, "#{timer_name}/Timer"}, callback_args: args}
  end

  describe "handle_cast({:execute, _}, _)" do
    test "return :ok, confirm callback.(args) invoke Logger.info(\"test\")", %{
      name: name,
      callback_args: callback_args
    } do
      assert capture_log(fn ->
               :ok = GenServer.cast(name, {:execute, nil})
               # wait execution of callback
               Process.sleep(1)
             end) =~ callback_args
    end
  end

  describe "handle_cast({:stop, _},  _)" do
    test "return :ok, confirm terminate is invoked", %{name: name} do
      log =
        capture_log(fn ->
          :ok = GenServer.cast(name, {:stop, nil})

          # wait terminate(:normal, _)
          Process.sleep(1)
        end)

      assert log =~ "the number of timer loop reaches limit"
      assert log =~ "terminate timer"
    end
  end

  describe "handle_call(:stop, _, _)" do
    test "return :ok", %{name: name} do
      assert capture_log(fn -> assert :ok = GenServer.call(name, :stop) end) =~ "stop timer"
    end
  end
end
