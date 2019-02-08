defmodule MISP.Server do
  use TypedStruct

  alias MISP.{
    HTTP,
    Server
  }

  typedstruct do
    field :id, String.t()
    field :url, String.t()
    field :name, String.t()
  end

  def decoder do
    %MISP.Server{}
  end

  def list do
    HTTP.get("/servers/", [Server.decoder()])
  end
end
