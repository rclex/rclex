defmodule Rclex.Pkgs.StdSrvs.Srv.SetBool.Request do
  @moduledoc false
  @behaviour Rclex.MessageBehaviour

  defstruct data: false

  @type t :: %__MODULE__{data: boolean()}

  alias Rclex.Nif

  def type_support!() do
    Nif.std_srvs_srv_set_bool__request_type_support!()
  end

  def create!() do
    Nif.std_srvs_srv_set_bool__request_create!()
  end

  def destroy!(message) do
    Nif.std_srvs_srv_set_bool__request_destroy!(message)
  end

  def set!(message, %__MODULE__{} = struct) do
    Nif.std_srvs_srv_set_bool__request_set!(message, to_tuple(struct))
  end

  def get!(message) do
    Nif.std_srvs_srv_set_bool__request_get!(message) |> to_struct()
  end

  def to_tuple(%__MODULE__{data: data}) do
    {data}
  end

  def to_struct({data}) do
    %__MODULE__{data: data}
  end
end
