defmodule MISP.EventInfo do
  @moduledoc """
  The inner block in the MISP Event schema

  Exists because MISP's schema looks like

      %{"Event" => %{
        "info" => "my event"
      }}
  """

  alias MISP.{
    Org,
    Orgc,
    SharingGroup,
    Attribute,
    Galaxy,
    Event,
    Tag
  }

  use TypedStruct

  @derive Jason.Encoder
  typedstruct do
    field :id, String.t()
    field :orgc_id, String.t()
    field :org_id, String.t()
    field :date, String.t()
    field :threat_level_id, String.t()
    field :info, String.t()
    field :published, boolean(), default: false
    field :uuid, String.t()
    field :attribute_count, String.t()
    field :analysis, String.t()
    field :timestamp, String.t()
    field :distribution, String.t()
    field :proposal_email_lock, boolean()
    field :locked, boolean(), default: false
    field :publish_timestamp, String.t()
    field :sharing_group_id, String.t()
    field :disable_correlation, boolean(), default: false
    field :event_creator_email, String.t()
    field :Org, Org.t()
    field :Orgc, Orgc.t()
    field :SharingGroup, SharingGroup.t()
    field :Attribute, list(Attribute.t()), default: []
    field :ShadowAttribute, list(Attribute.t()), default: []
    field :RelatedEvent, list(Event.t()), default: []
    field :Galaxy, list(Galaxy.t()), default: []
    field :Tag, list(Tag.t()), default: []
  end

  use Accessible

  def decoder(stop_recursion) when stop_recursion == true do
    %MISP.EventInfo{
      Org: Org.decoder(),
      Orgc: Orgc.decoder(),
      Attribute: [Attribute.decoder()],
      ShadowAttribute: [Attribute.decoder()],
      Galaxy: [Galaxy.decoder()],
      Tag: [Tag.decoder()]
    }
  end

  def decoder do
    %MISP.EventInfo{
      Org: Org.decoder(),
      Orgc: Orgc.decoder(),
      RelatedEvent: [MISP.Event.decoder(true)],
      Attribute: [Attribute.decoder()],
      ShadowAttribute: [Attribute.decoder()],
      Galaxy: [Galaxy.decoder()],
      Tag: [Tag.decoder()]
    }
  end
end
