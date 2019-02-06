defmodule MISP.Attribute do
    use TypedStruct

    alias MISP.{
        SharingGroup,
        Attribute,
        Tag
    }

    typedstruct do
        field :id, String.t()
        field :type, String.t()
        field :category, String.t()
        field :to_ids, boolean()
        field :uuid, String.t()
        field :event_id, String.t()
        field :distribution, String.t()
        field :timestamp, String.t()
        field :comment, String.t()
        field :sharing_group_id, String.t()
        field :deleted, boolean()
        field :disable_correlation, boolean()
        field :value, String.t()
        field :data, String.t()
        field :SharingGroup, %SharingGroup{}
        field :ShadowAttribute, list(%MISP.Attribute{}), default: []
        field :Tag, list(%Tag{}), default: []
    end
end 
