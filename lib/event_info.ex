defmodule MISP.EventInfo do
    use TypedStruct

    alias MISP.{
        Org,
        Orgc,
        SharingGroup,
        Attribute,
        Galaxy,
        Tag
    }

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
        field :Org, %Org{}
        field :Orgc, %Orgc{}
        field :SharingGroup, %SharingGroup{}
        field :Attribute, list(%Attribute{}), default: []
        field :ShadowAttribute, list(%Attribute{}), default: []
        field :RelatedEvent, list(%MISP.Event{}), default: []
        field :Galaxy, list(%Galaxy{}), default: []
        field :Tag, list(%Tag{}), default: []
    end
end
