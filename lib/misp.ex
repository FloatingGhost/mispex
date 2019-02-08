defmodule MISP do
  @moduledoc """
  An elixir binding for MISP's API, using mainly typed structs

  Requires environment config set up as per the README.md

  A basic event creation and attribute adding flow would look like so

      iex> my_event = %MISP.EventInfo{
      ...>   info: "yui is best yuru",
      ...>   Attribute: [
      ...>     %MISP.Attribute{value: "8.8.8.8", type: "ip-dst"}
      ...>   ]
      ...> } |> MISP.Event.create()
      %MISP.Event{
        Event: %MISP.EventInfo{
          info: "yui is best yuru",
        }
      }
  """

  require Logger

  alias MISP.{
    Event,
    HTTP
  }

  defp defaults do
    [
      url: "https://misp.example",
      apikey: "ExampleAPI"
    ]
  end

  defp merge_config(env) do
    defaults()
    |> Keyword.merge(env)
  end

  @doc """
  Retrieve our config, including API key and HTTP URL for the MISP.HTTP module
  """
  def config do
    Application.get_all_env(:mispex)
    |> merge_config()
  end

  @doc """
  Get the current version of MISP running on the server we're configured
  to connect to

      iex> MISP.test_connection()
      "2.4.102"
  """
  def test_connection do
    version_info =
      HTTP.get("/servers/getVersion.json")
      |> Map.get("version")

    Logger.debug("Connection successful, server is running #{version_info}")
    version_info
  end
end
