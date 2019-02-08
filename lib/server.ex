defmodule MISP.Server do
  @moduledoc """
  An external server to share data with
  """

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

  @doc """
  List all servers known by MISP

      iex> MISP.Server.list()
      [
        %MISP.Server{
          id: "1",
          url: "https://example.com"
        }
      ]
  """
  def list do
    HTTP.get("/servers/", [Server.decoder()])
  end
end
