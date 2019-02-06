defmodule MISP.Tag do
    use TypedStruct

    typedstruct do
        field :id, String.t()
        field :name, String.t()
        field :colour, String.t()
        field :exportable, boolean()
        field :hide_tag, boolean()
    end

    def decoder do
        %MISP.Tag{}
    end
end
