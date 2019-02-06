defmodule MISP.Galaxy do
    use TypedStruct

    alias MISP.{
        GalaxyCluster
    }

    typedstruct do
        field :id, String.t()
        field :uuid, String.t()
        field :name, String.t()
        field :type, String.t()
        field :description, String.t()
        field :version, String.t()
        field :GalaxyCluster, list(%GalaxyCluster{})
    end

    def decoder do
        %MISP.Galaxy{
            GalaxyCluster: [GalaxyCluster.decoder]
        }
    end
end
