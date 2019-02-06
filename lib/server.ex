defmodule MISP.Server do
    use TypedStruct

    typedstruct do
        field :id, String.t()
        field :url, String.t()
        field :name, String.t()
    end
end
