defmodule MISP.Errors.ServerException do
  @moduledoc """
  Indicates that misp has given us an error field

  Needs to exist since sometimes erroneous API calls do not give us
  non-200 HTTP codes (and hence be caught by HTTPoison),
  see https://github.com/MISP/MISP/issues/4116
  """

  defexception message: "MISP raised an errorr"
end
