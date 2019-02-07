defmodule MISP.SharingGroup do
  use TypedStruct

  alias MISP.{
    Org,
    SharingGroupOrg,
    SharingGroupServer
  }

  typedstruct do
    field :id, String.t()
    field :name, String.t()
    field :releasability, String.t()
    field :description, String.t()
    field :uuid, String.t()
    field :organisation_uuid, String.t()
    field :org_id, String.t()
    field :sync_user_id, String.t()
    field :active, boolean()
    field :created, String.t()
    field :modified, String.t()
    field :local, boolean()
    field :roaming, boolean()
    field :Organisation, Org.t()
    field :SharingGroupOrg, list(SharingGroupOrg.t())
    field :SharingGroupServer, list(SharingGroupServer.t())
  end

  def decoder do
    %MISP.SharingGroup{
      Organisation: Org.decoder(),
      SharingGroupOrg: [SharingGroupOrg.decoder()],
      SharingGroupServer: [SharingGroupServer.decoder()]
    }
  end
end
