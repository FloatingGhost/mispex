defmodule MISP.Errors.VersionMismatchError do
  @moduledoc """
  Indicates that misp does not yet support the endpoint being requested
  """

  defexception message: "MISP version too old for this feature"
end
