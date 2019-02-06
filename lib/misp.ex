defmodule MISP do
  require Logger

  @moduledoc """
  An elixir binding for MISP's API, using mainly typed structs

  Requires environment config set up as per the README.md

  A basic event creation and attribute adding flow would look like so

      iex> my_event = %MISP.EventInfo{info: "yui is best yuru"}
      iex> created_event = MISP.Event.create(my_event)
      iex> my_attribute = %MISP.Attribute{value: "8.8.8.8", type: "ip-dst"}
      iex> MISP.Event.add_attribute(created_event, my_attribute)

  Or if you want to be really fancy and pipe things around the place you
  can go more like this

      %MISP.EventInfo{info: "yui is best yuru"}
      |> MISP.Event.create()
      |> MISP.Event.add_attribute(%MISP.Attribute{value: "8.8.8.8", type: "ip-dst"})
  """

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
