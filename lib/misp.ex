defmodule MISP do
  require Logger

  @moduledoc """
  An elixir binding for MISP's API
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

  def config do
    Application.get_all_env(:mispex)
    |> merge_config()
  end

  def test_connection do
    version_info =
      HTTP.get("/servers/getVersion.json")
      |> Map.get("version")

    Logger.debug("Connection successful, server is running #{version_info}")
    version_info
  end
end
