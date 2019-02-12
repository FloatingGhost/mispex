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

  alias MISP.{
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

      iex> MISP.get_version()
      {:ok, "2.4.102"}
  """
  def get_version do
    case HTTP.get("/servers/getVersion.json") do
      {:ok, resp} -> {:ok, Map.get(resp, "version")}
      {:error, reason} -> {:error, reason}
    end
  end
end
