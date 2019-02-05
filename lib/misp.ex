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
    [
      {"Content-Type", "application/json"},
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
        IO.warn("Non-success code #{code}, #{body}")

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect(reason)
    end
  end

  def enforce_mandatory_keys(%{} = params, mandatory_attributes) do
    not_included =
      mandatory_attributes
      |> Enum.filter(fn x -> not Map.has_key?(params, x) end)

    unless Enum.count(not_included) > 0 do
      params
    else
      error_msg = Enum.join(not_included, ",")
      raise ArgumentError, "Required parameters missing: #{error_msg}"
    end
  end

  defp limit_keys_to_permitted(%{} = params, allowed_attributes) do
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
  Interact with restSearch endpoints

      iex> MISP.search("attributes", %{"value" => "8.8.8.8", "type" => "ip-dst"})
      [
        %{
          "Event" => %{
          },
          "category" => "Network activity",
          "event_id" => "someId",
          "type" => "ip-dst",
          "value" => "8.8.8.8"
        },
      ]

      iex> MISP.search("events", %{"eventid" => "12345"})
      [
        %{
          "Event" => %{
          }
        }
      ]
  """
  def search("attributes", %{} = params) do
    search_base = %{
      "returnFormat" => "json"
    }

    allowed_attributes = [
      "returnFormat",
      "page",
      "limit",
      "value",
      "type",
      "category",
      "org",
      "tags",
      "from",
      "to",
      "last",
      "eventid",
      "withAttachments",
      "uuid",
      "publish_timestamp",
      "timestamp",
      "enforceWarninglist",
      "to_ids",
      "deleted",
      "includeEventUuid",
      "includeEventTags",
      "event_timestamp",
      "threat_level_id",
      "eventinfo",
      "includeProposals"
    ]

    to_post =
      search_base
      |> Map.merge(params)
      |> limit_keys_to_permitted(allowed_attributes)

    config()
    |> post("/attributes/restSearch", to_post)
    |> Map.get("response")
    |> Map.get("Attribute")
  end

  def search("events", %{} = params) do
    search_base = %{
      "returnFormat" => "json"
    }

    allowed_attributes = [
      "returnFormat",
      "page",
      "limit",
      "value",
      "type",
      "category",
      "org",
      "tag",
      "tags",
      "searchall",
      "from",
      "to",
      "last",
      "eventid",
      "withAttachments",
      "metadata",
      "uuid",
      "published",
      "publish_timestamp",
      "timestamp",
      "enforceWarninglist",
      "sgReferenceOnly",
      "eventinfo"
    ]

    to_post =
      search_base
      |> Map.merge(params)
      |> limit_keys_to_permitted(allowed_attributes)

    config()
    |> post("/events/restSearch", to_post)
    |> Map.get("response")
  end

  def search(index, _) do
    {:error, reason: "Invalid index #{index}"}
  end

  def get_event(id) when is_integer(id) or is_binary(id) do
    config()
    |> get("/events/#{id}")
  end

  def get_event(%{"Event" => _} = event) do
    event
  end

  def create_event(%{} = params) do
    mandatory_attributes = ["info"]

    allowed_attributes = [
      "info",
      "threat_level_id",
      "analysis",
      "distribution",
      "sharing_group_id",
      "uuid",
      "published",
      "timestamp",
      "date"
    ]

    to_post =
      params
      |> enforce_mandatory_keys(mandatory_attributes)
      |> limit_keys_to_permitted(allowed_attributes)

    config()
    |> post("/events/add", to_post)
  end

  defp append_new_attribute(%{} = attribute, %{"Event" => %{"Attribute" => attr_list}} = event) do
    new_attr_list =
      attr_list
      |> List.insert_at(0, attribute)

    new_event =
      event
      |> Map.get("Event")
      |> Map.put("Attribute", new_attr_list)

    event
    |> Map.put("Event", new_event)
  end

  @doc """
  Create a new attribute

      iex> event_id = 955
      iex> MISP.create_attribute(event_id, %{"type" =>" ip-dst", "value" => "8.8.8.8"})
      %{
        "Event" => %{
          "Attribute" => [
            %{
              "type" => "ip-dst",
              "value" => "8.8.8.8"
            }
          ]
        }
      }

  Can also be piped with create_event

      iex> MISP.create_event(%{"info" => "my event"})
           |> MISP.create_attribute(%{"type" =>" ip-dst", "value" => "8.8.8.8"})
  """
  def create_attribute(event, %{} = params) do
    mandatory_attributes = ["value", "type"]

    allowed_attributes = [
      "value",
      "type",
      "category",
      "to_ids",
      "uuid",
      "distribution",
      "sharing_group_id",
      "timestamp",
      "comment"
    ]

    to_post =
      params
      |> enforce_mandatory_keys(mandatory_attributes)
      |> limit_keys_to_permitted(allowed_attributes)

    %{"Event" => %{"id" => event_id}} =
      event
      |> get_event()

    config()
    |> post("/attributes/add/#{event_id}", to_post)
    |> Map.get("Attribute")
    |> append_new_attribute(event)
  end
end
