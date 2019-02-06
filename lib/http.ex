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
      timeout: 100 * 60
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
      timeout: 100 * 60
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
      timeout: 100 * 60
    )
    |> handle_response()
    |> decode_response(nil)
  end

  defp handle_response(resp) do
    case resp do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body

      {:ok, %HTTPoison.Response{status_code: code, body: body}} ->
        raise MISP.Errors.ServerException, "Non-success code #{code}, #{body}"

      {:error, %HTTPoison.Error{reason: reason}} ->
        raise MISP.Errors.ServerException, "HTTP Error #{reason}"
    end
  end

  defp decode_response(body, nil) do
    Poison.decode!(body)
    |> check_for_error()
  end

  defp decode_response(body, decode_as) do
    Poison.decode!(body)
    |> check_for_error()

    Poison.decode!(body, as: decode_as)
  end

  defp format_misp_error(%{} = errors, keys \\ []) do
    errors
    |> Map.keys()
    |> Enum.map(fn key -> format_misp_error(Map.get(errors, key), keys ++ [key]) end)
  end

  defp format_misp_error(errors, keys) when is_list(errors) do
    key_string = Enum.join(keys, ".")
    error_string = Enum.join(errors, ", ")
    "#{key_string}: #{error_string}"
  end

  defp check_for_error(%{"errors" => errors}) do
    error_string = format_misp_error(errors)

    raise MISP.Errors.ServerException, "MISP says: #{error_string}"
  end

  defp check_for_error(body), do: body
end
