defmodule MISP.Orgc do
    use TypedStruct

    typedstruct do
        field :id, String.t()
        field :name, String.t()
        field :uuid, String.t(), enforce: true
    end

    def decoder do
        %MISP.Orgc{uuid: ""}
    end
end
