defmodule MISP.Attribute do
  @moduledoc """
  An Attribute, usually attached to an event

  Common usage would be:

      16
      |> MISP.Event.get()
      |> Map.get(:Attribute)
      |> List.first()
      |> MISP.Attribute.delete()
  """

  alias MISP.{
    SharingGroup,
    Attribute,
    Tag,
    Event,
    EventInfo,
    HTTP
  }

  use TypedStruct

  typedstruct do
    field :id, String.t()
    field :type, String.t()
    field :category, String.t()
    field :to_ids, boolean(), default: false
    field :uuid, String.t()
    field :event_id, String.t()
    field :distribution, String.t()
    field :timestamp, String.t()
    field :comment, String.t()
    field :sharing_group_id, String.t()
    field :deleted, boolean(), default: false
    field :disable_correlation, boolean(), default: false
    field :value, String.t()
    field :data, String.t()
    field :SharingGroup, SharingGroup.t()
    field :ShadowAttribute, list(Attribute.t()), default: []
    field :Tag, list(Tag.t()), default: []
  end

  use Accessible

  @doc """
  Get the object structure for decoding from JSON
  """
  def decoder(stop_recursion) when stop_recursion == true do
    %Attribute{
      SharingGroup: SharingGroup.decoder(),
      Tag: [Tag.decoder()]
    }
  end

  def decoder do
    %Attribute{
      SharingGroup: SharingGroup.decoder(),
      ShadowAttribute: [Attribute.decoder(true)],
      Tag: [Tag.decoder()]
    }
  end

  @doc """
  Create an attribute on an event

      iex> event = %MISP.Event{%MISP.EventInfo{id: 1}}
      iex> MISP.Attribute.Create(event, %MISP.Attribute{value: "8.8.8.8", type: "ip-dst"})
      {:ok,
       %MISP.Attribute{
          value: "8.8.8.8",
          type: "ip-dst",
          uuid: "...."
       }
      }
  """
  def create(%Event{Event: %EventInfo{id: event_id}}, %Attribute{} = attribute) do
    HTTP.post("/attributes/add/#{event_id}", attribute, Attribute.decoder())
  end

  @doc """
  Update an attribute with new values

      MISP.Attribute.search(%{value: "1.1.1.1"})
      |> List.first()
      |> Map.put(:value, "2.2.2.2")
      |> MISP.Attribute.update()
  """
  def update(%Attribute{id: id} = attribute) do
    # Remove timestamp, as it causes MASSIVE headaches if it's wrong
    updated_attr = Map.put(attribute, :timestamp, nil)

    
    case HTTP.post("/attributes/edit/#{id}", updated_attr, %{"response" => %{"Attribute" => Attribute.decoder()}}) do
      {:ok, updated} -> {:ok, updated |> Map.get("response") |> Map.get("Attribute")}
      {:error, reason} -> {:error, reason}
    end

  end

  @doc """
  Delete an attribute

      iex> MISP.Attribute.search(%{value: "1.1.1.1"}) |> List.first |> MISP.Attribute.delete
      %{
        "message" => "1 attribute deleted.",
        "name" => "1 attribute deleted.",
        "url" => "/attributes/deleteSelected/17"
      }
  """
  def delete(%Attribute{id: id, event_id: event_id}) do
    HTTP.post("/attributes/deleteSelected/#{event_id}", %{id: id})
  end

  @doc """
  Search for attributes

  Will set a default limit of 100 unless overridden via the limit parameter

      iex> MISP.Attribute.search(%{value: "1.1.1.1"})
      {:ok, [
        %MISP.Attribute{
          type: "ip-dst",
          value: "1.1.1.1"
        }
      ]}
  """
  def search(%{} = params) do
    search_base = %{
      returnFormat: "json",
      limit: "100",
      page: "0"
    }

    search_params =
      search_base
      |> Map.merge(params)

    case HTTP.post("/attributes/restSearch", search_params, 
      %{"response" => %{"Attribute" => [Attribute.decoder()]}}) do
        {:ok, list} -> {:ok, list |> Map.get("response") |> Map.get("Attribute")}
        {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Add a tag to an attribute

      iex> MISP.Attribute.add_tag(%MISP.Attribute{}, %MISP.Tag{name: "my tag"})
      {:ok, %MISP.Attribute{
        Tag: [
          %MISP.Tag{
            colour: "#15c551",
            exportable: true,
            hide_tag: false,
            id: "5",
            name: "my tag"
          }
        ]
      }}
  """
  def add_tag(%Attribute{uuid: uuid} = attribute, %Tag{name: name} = tag) do
    with {:ok, %Tag{} = tag} <- Tag.create(tag) do
      case HTTP.post("/tags/attachTagToObject", %{uuid: uuid, tag: name}, nil) do
        {:ok, _} -> {:ok, Map.put(attribute, :Tag, Map.get(attribute, :Tag) ++ [tag])}
        {:error, reason} -> {:error, reason}
      end

    else
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Remove a tag from an attribute

      iex> my_attribute = %MISP.Attribute{Tag: [%MISP.Tag{name: "my tag"}]}
      iex> MISP.Attribute.remove_tag(my_attribute, %MISP.Tag{name: "my tag"})
      %MISP.Attribute{
        Tag: [],
      }
  """
  def remove_tag(%Attribute{uuid: uuid, Tag: tags} = attribute, %Tag{name: name}) do
    case HTTP.post("/tags/removeTagFromObject", %{uuid: uuid, tag: name}, nil) do
      {:ok, _} -> {:ok, Map.put(attribute, :Tag, Enum.filter(tags, fn x -> x.name != name end))}
      {:error, reason} -> {:error, reason}
    end
  end
end
