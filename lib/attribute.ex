defmodule MISP.Attribute do
  @moduledoc """
  Represents an Attribute, usually attached to an event

  Common usage would be:

      iex> MISP.Event.get(16) |> Map.get(:Attribute) |> List.first() |> MISP.Attribute.delete()
  """

  use TypedStruct

  alias MISP.{
    SharingGroup,
    Attribute,
    Tag,
    Event,
    EventInfo,
    HTTP
  }

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
    field :SharingGroup, %SharingGroup{}
    field :ShadowAttribute, list(%MISP.Attribute{}), default: []
    field :Tag, list(%Tag{}), default: []
  end

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
      %MISP.Attribute{
          value: "8.8.8.8",
          type: "ip-dst",
          uuid: "...."
      }
  """
  def create(%Event{Event: %EventInfo{id: event_id}}, %Attribute{} = attribute) do
    HTTP.post("/attributes/add/#{event_id}", attribute, Attribute.decoder())
  end

  @doc """
  Update an event with new values
  """
  def update(%Attribute{} = attribute) do
    updated_attr =
      attribute
      |> Map.put(:timestamp, :os.system_time(:seconds))

    HTTP.post("/attributes/edit/#{updated_attr.event_id}", updated_attr, Attribute.decoder())
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
  def delete(%Attribute{id: id, event_id: event_id} = attribute) do
    HTTP.post("/attributes/deleteSelected/#{event_id}", %{id: id})
  end

  @doc """
  Search for attributes

      iex> MISP.Attribute.search(%{value: "1.1.1.1"})
      [
        %MISP.Attribute{
          type: "ip-dst",
          value: "1.1.1.1"
        }
      ]
  """
  def search(%{} = params) do
    search_base = %{
      returnFormat: "json"
    }

    search_params =
      search_base
      |> Map.merge(params)

    HTTP.post(
      "/attributes/restSearch",
      search_params,
      %{"response" => %{"Attribute" => [Attribute.decoder()]}}
    )
    |> Map.get("response")
    |> Map.get("Attribute")
  end
end
