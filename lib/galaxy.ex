defmodule MISP.Galaxy do
  use TypedStruct

  alias MISP.{
    Galaxy,
    GalaxyCluster,
    HTTP
  }

  typedstruct do
    field :id, String.t()
    field :uuid, String.t()
    field :name, String.t()
    field :type, String.t()
    field :description, String.t()
    field :version, String.t()
    field :GalaxyCluster, list(GalaxyCluster.t()), default: []
  end

  def decoder do
    %MISP.Galaxy{
      GalaxyCluster: [GalaxyCluster.decoder()]
    }
  end

  def list do
    "/galaxies/"
    |> HTTP.get([%{"Galaxy" => Galaxy.decoder()}])
    |> Enum.map(fn x -> Map.get(x, "Galaxy") end)
  end

  def get(id) do
    resp =
      "/galaxies/view/#{id}"
      |> HTTP.get(%{"Galaxy" => Galaxy.decoder(), "GalaxyCluster" => [GalaxyCluster.decoder()]})

    resp
    |> Map.get("Galaxy")
    |> Map.put(:GalaxyCluster, Map.get(resp, "GalaxyCluster"))
  end
end
