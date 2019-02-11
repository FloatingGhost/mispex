defmodule MISP.Tag do
  @moduledoc """
  A tag attached to an object, usually an event or attribute
  """

  alias MISP.{
    Tag,
    HTTP
  }

  use TypedStruct

  typedstruct do
    field :id, String.t()
    field :name, String.t()
    field :colour, String.t()
    field :exportable, boolean(), default: true
    field :hide_tag, boolean(), default: false
  end

  use Accessible

  def decoder do
    %MISP.Tag{}
  end

  def get(id) do
    HTTP.get("/tags/view/#{id}", decoder())
  end

  @doc """
  Either create a new tag or retrieve the representation of an already-existing tag

      iex> MISP.Tag.create(%MISP.Tag{name: "my tag"})
  """
  def create(%Tag{} = tag) do
    HTTP.post("/tags/add", tag, %{"Tag" => decoder})
    |> Map.get("Tag")
  end

  @doc """
  Update the server-side values for a tag

      iex> MISP.Tag.get(1) |> Map.put(:name, "my new name") |> MISP.Tag.update()
  """
  def update(%Tag{id: tag_id} = tag) do
    HTTP.post("/tags/edit/#{tag_id}", %{Tag: tag}, %{"Tag" => decoder()})
    |> Map.get("Tag")
  end

  @doc """
  Search for tags. Use % for wildcard

      iex> MISP.Tag.search("%tag")
      [
        %MISP.Tag{
          colour: "#373f7b",
          exportable: true,
          hide_tag: false,
          id: "3",
          name: "my tag"
        }
      ]
  """
  def search(search_term) do
    if MISP.get_version() <= "2.4.102" do
      raise MISP.Errors.VersionMismatchError, "Tag search implemented in v2.4.103"
    else
      HTTP.post("/tags/search", %{tag: search_term}, [%{"Tag" => decoder()}])
      |> Enum.map(fn x -> Map.get(x, "Tag") end)
    end
  end

  @doc """
  Delete a tag

      iex> MISP.Tag.delete(%MISP.Tag{id: 3})
      %{
        "message" => "Tag deleted.",
        "name" => "Tag deleted.", 
        "url" => "/tags/delete/3"
      }
  """
  def delete(%Tag{id: tag_id} = tag) do
    with %{"message" => "Tag deleted."} = resp <- HTTP.post("/tags/delete/#{tag_id}", %{}, nil) do
      resp
    else
      err -> raise MISP.Errors.ServerException, Map.get(err, "message")
    end
  end

  @doc """
  Delete multiple tags
  """
  def delete(tags) when is_list(tags) do
    Enum.map(tags, fn x -> delete(x) end)
  end
end
