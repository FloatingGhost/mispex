defmodule MISP.SharingGroupOrg do
  use TypedStruct

  alias MISP.{
    Org
  }

  @derive Jason.Encoder
  typedstruct do
    field :id, String.t()
    field :sharing_group_id, String.t()
    field :org_id, String.t()
    field :extend, boolean()
    field :Organisation, Org.t()
  end

  def decoder do
    %MISP.SharingGroupOrg{
      Organisation: Org.decoder()
    }
  end
end
