defmodule MISP.Tag do
    use TypedStruct

    typedstruct do
        field :id, String.t()
        field :name, String.t()
        field :colour, String.t()
        field :exportable, boolean()
        field :hide_tag, boolean()
    end
end
