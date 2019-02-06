defmodule MISP.Org do
    use TypedStruct

    typedstruct do
        field :id, String.t()
        field :name, String.t()
        field :uuid, String.t(), enforce: true
    end

    def decoder do
        %MISP.Org{uuid: ""}
    end
end
