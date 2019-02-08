defmodule MISP.Galaxy do
  @moduledoc """
  List and retrieve MISP Galaxy information
  """

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

  @doc """
  List all galaxies from MISP

      iex> MISP.Galaxy.list()
      [
        %MISP.Galaxy{
          name: "Mobile Attack - Malware",
          id: "34",
          namespace: "mitre-attack"
        }
      ]
  """
  def list do
    "/galaxies/"
    |> HTTP.get([%{"Galaxy" => Galaxy.decoder()}])
    |> Enum.map(fn x -> Map.get(x, "Galaxy") end)
  end

  @doc """
  Get a single galaxy with the provided ID

      iex> MISP.Galaxy.get(34)
      %MISP.Galaxy{
        name: "Mobile Attack - Malware",
        id: "34",
        namespace: "mitre-attack"
      }
  """
  def get(id) do
    resp =
      "/galaxies/view/#{id}"
      |> HTTP.get(%{"Galaxy" => Galaxy.decoder(), "GalaxyCluster" => [GalaxyCluster.decoder()]})

    resp
    |> Map.get("Galaxy")
    |> Map.put(:GalaxyCluster, Map.get(resp, "GalaxyCluster"))
  end
end
