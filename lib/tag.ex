defmodule MISP.Tag do
  @moduledoc """
  Create and delete tags for both events and attributes
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

  def create(%Tag{} = tag) do
    HTTP.post("/tags/add", tag, %{"Tag" => decoder})
    |> Map.get("Tag")
  end
end
