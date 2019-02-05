defmodule MISP do
  require Logger

  @moduledoc """
  An elixir binding for MISP's API
  """

  def defaults do
    [
      url: "https://misp.example",
      apikey: "ExampleAPI"
    ]
  end

  defp merge_config(env) do
    defaults()
    |> Keyword.merge(env)
  end

  defp config do
    Application.get_all_env(:mispex)
    |> merge_config()
  end 

  defp headers(options) do
    [{"Content-Type", "application/json"},
     {"Accept", "application/json"},
     {"Authorization", Keyword.get(options, :apikey)}
    ]
  end 

  defp get(options, path) do
    options
    |> Keyword.get(:url)
    |> URI.merge(path)
    |> URI.to_string()    
    |> HTTPoison.get(
        headers(options),
        timeout: 100 * 60
    )
    |> handle_response()
  end

  defp post(options, path, body \\ %{}) do
    options
    |> Keyword.get(:url)
    |> URI.merge(path)
    |> URI.to_string()
    |> HTTPoison.post(
        Poison.encode!(body),
        headers(options),
        timeout: 60
    )
    |> handle_response()
  end

  defp handle_response(resp) do
    case resp do
       {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          Poison.decode!(body)
       {:ok, %HTTPoison.Response{status_code: code, body: body}} ->
          IO.warn "Non-success code #{code}, #{body}"
       {:error, %HTTPoison.Error{reason: reason}} ->
          IO.inspect reason
    end
  end

  def test_connection do
    version_info = 
      config()
      |> get("/servers/getVersion.json")
      |> Map.get("version")

    Logger.debug("Connection successful, server is running #{version_info}")
    version_info
  end
end
