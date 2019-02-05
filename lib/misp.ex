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

  defp post(options, path, %{} = body \\ %{}) do
    options
    |> Keyword.get(:url)
    |> URI.merge(path)
    |> URI.to_string()
    |> HTTPoison.post(
        Poison.encode!(body),
        headers(options),
        timeout: 100 * 60
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

  def limit_allowed_search_terms(%{} = params, allowed_attributes) do
    allowed_attributes
    |> Enum.reduce(
        %{},
        fn key, acc -> 
          if Map.has_key?(params, key) do
            Map.put(acc, key, params[key])
          else
            acc
          end
        end
    ) 
  end

  def test_connection do
    version_info = 
      config()
      |> get("/servers/getVersion.json")
      |> Map.get("version")

    Logger.debug("Connection successful, server is running #{version_info}")
    version_info
  end

  @doc """
  Search MISP at the index level. Query values can be negated by prepending an
  exclamation mark (!)

    iex> MISP.search(%{published: true, eventid: 5})
  """
  def search("attributes", %{} = params) do
    search_base = %{
      "returnFormat" => "json"
    }

    allowed_attributes = [
      "returnFormat", "page", "limit", "value", "type", "category", "org", "tags",
      "from", "to", "last", "eventid", "withAttachments", "uuid",
      "publish_timestamp", "timestamp", "enforceWarninglist", "to_ids",
      "deleted", "includeEventUuid", "includeEventTags", "event_timestamp",
      "threat_level_id", "eventinfo", "includeProposals"
    ]

    to_post = 
      search_base
      |> Map.merge(params)
      |> limit_allowed_search_terms(allowed_attributes)

    config()
    |> post("/attributes/restSearch", to_post)
  end

  def search("events", %{} = params) do
    search_base = %{
      "returnFormat" => "json"
    }

    allowed_attributes = [
      "returnFormat", "page", "limit", "value", "type", "category", "org",
      "tag", "tags", "searchall", "from", "to", "last",
      "eventid", "withAttachments", "metadata", "uuid",
      "published", "publish_timestamp", "timestamp",
      "enforceWarninglist", "sgReferenceOnly",
      "eventinfo"
    ]

    to_post =
      search_base
      |> Map.merge(params)
      |> limit_allowed_search_terms(allowed_attributes)

    config()
    |> post("/events/restSearch", to_post)
  end
end
