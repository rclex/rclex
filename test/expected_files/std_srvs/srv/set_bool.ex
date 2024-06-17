defmodule Rclex.Pkgs.StdSrvs.Srv.SetBool do
  @moduledoc false
  @behaviour Rclex.ServiceBehaviour

  alias Rclex.Nif

  def type_support!() do
    Nif.std_srvs_srv_set_bool_type_support!()
  end

  def request_type() do
    Rclex.Pkgs.StdSrvs.Srv.SetBoolRequest
  end

  def response_type() do
    Rclex.Pkgs.StdSrvs.Srv.SetBoolResponse
  end
end
