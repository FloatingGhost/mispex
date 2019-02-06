defmodule MISP.Attribute do
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
  def create(%Event{Event: %EventInfo{id: event_id}} = event, %Attribute{} = attribute) do
    HTTP.post("/attributes/add/#{event_id}", attribute, Attribute.decoder())
  end
end
