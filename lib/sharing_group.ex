defmodule MISP.SharingGroup do
  use TypedStruct

  alias MISP.{
    Org,
    SharingGroup,
    SharingGroupOrg,
    SharingGroupServer,
    HTTP
  }

  @derive Jason.Encoder
  typedstruct do
    field :id, String.t()
    field :name, String.t(), default: "default name"
    field :releasability, String.t(), default: "default sharability"
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
    field :SharingGroupOrg, list(SharingGroupOrg.t()), default: []
    field :SharingGroupServer, list(SharingGroupServer.t()), default: []
  end

  def decoder do
    %MISP.SharingGroup{
      Organisation: Org.decoder(),
      SharingGroupOrg: [SharingGroupOrg.decoder()],
      SharingGroupServer: [SharingGroupServer.decoder()]
    }
  end

  def list do
    case HTTP.get("/sharing_groups/", %{"response" => [decoder()]}) do
      {:ok, resp} -> {:ok, Map.get(resp, "response")}
      {:error, reason} -> {:error, reason}
    end
  end

  def create(%SharingGroup{} = sharing_group) do
    HTTP.post("/sharing_groups/add", sharing_group)
  end
end
