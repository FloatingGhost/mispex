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

    response = 
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

    response = 
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

    response = 
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
        {:ok, body}

      {:ok, %HTTPoison.Response{status_code: code, body: body}} ->
        {:error, body, code: code}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "HTTP Error #{reason}"}
    end
  end

  @doc """
  Decode a MISP response, with an optional argument to decode to struct
  """
  defp decode_response({:ok, body}, decode_as) do
    case Poison.decode(body) do
      {:ok, %{"errors" => errors}} -> {:error, reason: errors}

      {:ok, _} -> {:ok, Poison.decode!(body, as: decode_as)}

      {:error, {reason, _, _}} -> {:error, reason}
    end
  end

  defp decode_response({:error, body}, _) do
    {:error, body}
  end
end
