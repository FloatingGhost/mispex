defmodule MISP.GalaxyCluster do
    use TypedStruct

    typedstruct do
        field :id, String.t()
        field :uuid, String.t()
        field :type, String.t()
        field :value, String.t()
        field :tag_name, String.t()
        field :description, String.t()
        field :galaxy_id, String.t()
        field :source, String.t()
        field :authors, list(String.t())
        field :tag_id, String.t()
        field :meta, %{}
    end

    def decoder do
        %MISP.GalaxyCluster{}
    end 
end
