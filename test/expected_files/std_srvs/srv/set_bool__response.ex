defmodule Rclex.Pkgs.StdSrvs.Srv.SetBool.Response do
  @moduledoc false
  @behaviour Rclex.MessageBehaviour

  defstruct success: false,
            message: ""

  @type t :: %__MODULE__{success: boolean(), message: String.t()}

  alias Rclex.Nif

  def type_support!() do
    Nif.std_srvs_srv_set_bool__response_type_support!()
  end

  def create!() do
    Nif.std_srvs_srv_set_bool__response_create!()
  end

  def destroy!(message) do
    Nif.std_srvs_srv_set_bool__response_destroy!(message)
  end

  def set!(message, %__MODULE__{} = struct) do
    Nif.std_srvs_srv_set_bool__response_set!(message, to_tuple(struct))
  end

  def get!(message) do
    Nif.std_srvs_srv_set_bool__response_get!(message) |> to_struct()
  end

  def to_tuple(%__MODULE__{success: success, message: message}) do
    {success, ~c"#{message}"}
  end

  def to_struct({success, message}) do
    %__MODULE__{success: success, message: "#{message}"}
  end
end
