defmodule MISP.HTTP do
  @moduledoc """
  Standard functions to deal with posting and recieving JSON
  """

  defp headers(options) do
    [
      {"Content-Type", "application/json"},
      {"Accept", "application/json"},
      {"Authorization", Keyword.get(options, :apikey)}
    ]
  end

  defp defaults(), do: [timeout: 100 * 60]
  defp client_options(options), do: Keyword.get(options, :client_options)

  defp client_config(options), do: Keyword.merge(defaults(), client_options(options))

  @doc """
  An HTTP GET Request

      iex> MISP.HTTP.get("/events/16", MISP.Event.decoder())
      %MISP.Event{}
  """
  def get(path, decode_as \\ nil) do
    options = MISP.config()

    options
    |> Keyword.get(:url)
    |> URI.merge(path)
    |> URI.to_string()
    |> HTTPoison.get(
      headers(options),
      client_config(options)
    )
    |> handle_response()
    |> decode_response(decode_as)
  end

  @doc """
  An HTTP POST Request

      iex> MISP.HTTP.post("/events/add", %MISP.Event{}, MISP.Event.decoder())
      %MISP.Event{}
  """
  def post(path, %{} = body, decode_as \\ nil) do
    options = MISP.config()

    options
    |> Keyword.get(:url)
    |> URI.merge(path)
    |> URI.to_string()
    |> HTTPoison.post(
      Poison.encode!(body),
      headers(options),
      client_config(options)
    )
    |> handle_response()
    |> decode_response(decode_as)
  end

  @doc """
  An HTTP DELETE Request
         
      iex> MISP.HTTP.delete("/events/16")
      %{"message" => "Event deleted."}
  """
  def delete(path) do
    options = MISP.config()

    options
    |> Keyword.get(:url)
    |> URI.merge(path)
    |> URI.to_string()
    |> HTTPoison.delete(
      headers(options),
      client_config(options)
    )
    |> handle_response()
    |> decode_response(nil)
  end

  defp handle_response(resp) do
    case resp do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body}

      {:ok, %HTTPoison.Response{status_code: _, body: body}} ->
        {:error, body}

      {:error, %HTTPoison.Error{} = e} ->
        {:error, "HTTP Error #{HTTPoison.Error.message(e)}"}
    end
  end

  defp decode_response({:ok, body}, decode_as) do
    case Poison.decode(body) do
      {:ok, %{"errors" => errors}} -> {:error, reason: errors}
      {:ok, _} -> {:ok, Poison.decode!(body, as: decode_as)}
      {:error, {reason, _, _}} -> {:error, reason}
    end
  end

  defp decode_response({:error, body}, _) do
    {:error, format_error(body)}
  end

  # Check if we can format an ugly JSON error into something a little more
  # human-readable
  # It'll usually look like %{"errors" => %{"Event" => %{"info" => ["Info cannot be empty"]}}}
  defp format_error(error) when is_binary(error) do
    # Try to parse JSON, if we can't, just return the bare string
    case Poison.decode(error) do
      {:ok, error} -> format_error(error)
      {:error, _} -> error
    end
  end

  defp format_error(%{"errors" => errors}) do
    errors
    |> format_error_map([])
    |> Enum.join(", ")
  end

  defp format_error(%{"message" => message}) do
    message
  end

  defp format_error_map(%{} = errors, keys) do
    errors
    |> Map.keys()
    |> Enum.map(fn key -> format_error_map(Map.get(errors, key), keys ++ [key]) end)
  end

  defp format_error_map(errors, keys) when is_list(errors) do
    key_string = Enum.join(keys, ".")
    error_string = Enum.join(errors, ", ")
    "#{key_string}: #{error_string}"
  end

  defp format_error_map(errors, _) when is_binary(errors) do
    errors
  end
end
