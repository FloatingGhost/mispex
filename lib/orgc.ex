defmodule MISP.Orgc do
  @moduledoc """
  The source organisation for an event

  Apparently not the same as MISP.Org, although they have
  the same fields. Weird.
  """
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
