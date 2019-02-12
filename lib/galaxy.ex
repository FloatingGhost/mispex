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
      {:ok, [
        %MISP.Galaxy{
          name: "Mobile Attack - Malware",
          id: "34",
          namespace: "mitre-attack"
        }
      ]}
  """
  def list do
    case HTTP.get("/galaxies/", [%{"Galaxy" => Galaxy.decoder()}]) do
      {:ok, list} -> {:ok, Enum.map(list, fn x -> Map.get(x, "Galaxy") end)}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Get a single galaxy with the provided ID

      iex> MISP.Galaxy.get(34)
      {:ok, %MISP.Galaxy{
        name: "Mobile Attack - Malware",
        id: "34",
        namespace: "mitre-attack"
      }}
  """
  def get(id) do
    resp =
      HTTP.get("/galaxies/view/#{id}", %{
        "Galaxy" => Galaxy.decoder(),
        "GalaxyCluster" => [GalaxyCluster.decoder()]
      })

    case resp do
      {:ok, resp} ->
        {:ok,
         resp |> Map.get("Galaxy") |> Map.put(:GalaxyCluster, Map.get(resp, "GalaxyCluster"))}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
