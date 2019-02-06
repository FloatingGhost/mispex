defmodule MISP.SharingGroupOrg do
    use TypedStruct

    alias MISP.{
        Org
    }

    typedstruct do
        field :id, String.t()
        field :sharing_group_id, String.t()
        field :org_id, String.t()
        field :extend, boolean()
        field :Organisation, %Org{}
    end
end
