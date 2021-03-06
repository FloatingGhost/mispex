defmodule MISP.SharingGroupServer do
  use TypedStruct

  alias MISP.{
    Server
  }

  @derive Jason.Encoder
  typedstruct do
    field :id, String.t()
    field :sharing_group_id, String.t()
    field :server_id, String.t()
    field :all_orgs, boolean()
    field :Server, Server.t()
  end

  def decoder do
    %MISP.SharingGroupServer{
      Server: Server.decoder()
    }
  end
end
