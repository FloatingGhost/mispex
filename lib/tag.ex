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

  @doc """
  Either create a new tag or retrieve the representation of an already-existing tag

      iex> MISP.Tag.create(%MISP.Tag{name: "my tag"})
  """
  def create(%Tag{} = tag) do
    HTTP.post("/tags/add", tag, %{"Tag" => decoder})
    |> Map.get("Tag")
  end
end
