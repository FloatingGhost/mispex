defmodule MISP.Feed do
  @moduledoc """
  A way to add data to MISP from an external source

    iex> MISP.Feed.list()
    [
      %MISP.Feed{
        name: "CIRCL OSINT Feed"
      }
    ]
  """

  use TypedStruct

  alias MISP.{
    Feed,
    HTTP
  }

  typedstruct do
    field :id, String.t()
    field :name, String.t(), default: "feed name"
    field :provider, String.t(), default: "my provider"
    field :url, String.t(), default: "http://example.com"
    field :rules, String.t(), default: ""
    field :enabled, boolean(), default: true
    field :distribution, String.t()
    field :sharing_group_id, String.t()
    field :tag_id, String.t()
    field :default, boolean(), default: true
    field :source_format, String.t(), default: "misp"
    field :fixed_event, boolean(), default: true
    field :delta_merge, boolean(), default: false
    field :event_id, String.t(), default: "0"
    field :publish, boolean(), default: true
    field :override_ids, boolean(), default: false
    field :settings, String.t(), default: ""
    field :input_source, String.t(), default: "network"
    field :delete_local_file, boolean(), default: false
    field :lookup_visible, boolean(), default: true
    field :headers, String.t(), default: ""
    field :caching_enabled, boolean(), default: true
  end

  def decoder do
    %Feed{}
  end

  @doc """
  Get all feeds
  """
  def list do
    "/feeds/index"
    |> HTTP.get([%{"Feed" => %Feed{}}])
    |> Enum.map(fn x -> Map.get(x, "Feed") end)
  end

  @doc """
  Get a single feed with corresponding ID
  """
  def get(id) do
    "/feeds/view/#{id}"
    |> HTTP.get(%{"Feed" => %Feed{}})
    |> Map.get("Feed")
  end

  # FIXME Gives a "request blackholed" error with no info
  def create(%Feed{} = feed) do
    "/feeds/add"
    |> HTTP.post(feed, nil)
  end
end
