defmodule MISP.HTTP do
  defp headers(options) do
    [
      {"Content-Type", "application/json"},
      {"Accept", "application/json"},
      {"Authorization", Keyword.get(options, :apikey)}
    ]
  end

  def get(path) do
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
  end

  def post(path, %{} = body \\ %{}) do
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

end
