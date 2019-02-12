defmodule MISP.Event do
  @moduledoc """
  An event within MISP

  Common usage:

      iex> %MISP.EventInfo{info: "hello world!"} |> MISP.Event.create() |> MISP.Event.delete()
  """
  alias MISP.{
    EventInfo,
    HTTP,
    Event,
    Attribute,
    Tag
  }

  use TypedStruct

  typedstruct do
    field :Event, EventInfo.t(), default: %EventInfo{info: "mispex event"}
  end

  use Accessible

  def decoder do
    %Event{
      Event: EventInfo.decoder()
    }
  end

  def decoder(stop_recursion) do
    %Event{
      Event: EventInfo.decoder(stop_recursion)
    }
  end

  @doc """
  To allow for easier interaction with the API, wrapping EventInfo objects
  in Event objects can be avoided in some cases

      iex> MISP.Event.wrap(%EventInfo{info: "my event"})
      %MISP.Event{
        Event: %EventInfo{
            info: "my event"
        }
      }
  """
  def wrap(%Event{} = event), do: event

  def wrap(%EventInfo{} = event_info) do
    %Event{
      Event: event_info
    }
  end

  @doc """
  List the metadata for all events currently in MISP.
  Potentially expensive in memory and time.

  I advise using MISP.Event.list/1 where you can, to not return literally everything

      iex> MISP.Event.list()
      [
        %MISP.Event{
          Event: %MISP.EventInfo{}
        }
      ]
  """
  def list do
    case HTTP.get("/events/index", [EventInfo.decoder()]) do
      {:ok, event_list} -> {:ok, Enum.map(event_list, fn x -> %Event{Event: x} end)}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  List the metadata for all events matching some criteria

  At the time of writing, valid parameters are as follows

  all, attribute, published, eventid, datefrom, dateuntil, org,
  eventinfo, tag, tags, distribution, sharinggroup, analysis, threatlevel,
  email, hasproposal, timestamp, publishtimestamp, publish_timestamp,
  minimal

      iex> MISP.Event.list(%{eventid: 67})
      [
        %MISP.Event{
          Event: %MISP.EventInfo{
            id: "67"
          }
        }
      ]
  """
  def list(%{} = params) do
    case HTTP.post("/events/index", params, [EventInfo.decoder()]) do
      {:ok, event_list} -> {:ok, Enum.map(event_list, fn x -> %Event{Event: x} end)}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Get a single event with the specified ID

      iex>  MISP.Event.get(76)
      {:ok, 
       %MISP.Event{
         Event: %MISP.EventInfo{
           id: "76"
         }
       }
      }
  """
  def get(id) when is_integer(id) or is_binary(id) do
    HTTP.get("/events/#{id}", Event.decoder())
  end

  @doc """
  Create a new event.

  Wrapping a MISP.EventInfo struct in a MISP.Event struct isn't required

      iex> MISP.Event.create(%MISP.EventInfo{info: "hello world!"})
      %MISP.Event{
          Event: %MISP.EventInfo{
              date: "2019-02-06",
              event_creator_email: "admin@admin.test",
              id: "16",
              info: "hello world!",
          }
      }
  """
  def create(%Event{} = event) do
    HTTP.post("/events/add", event, MISP.Event.decoder())
  end

  def create(%EventInfo{} = event_info) do
    event_info
    |> wrap()
    |> create()
  end

  @doc """
  Update an event

      iex> MISP.Event.get(16) |> put_in([:Event, :info], "new info!") |> MISP.Event.update()
      %MISP.Event{
        Event: %MISP.EventInfo{
          info: "new info!"
        }
      }
  """
  def update(%Event{Event: %EventInfo{id: event_id}} = event) do
      # Trust me, setting timestamp to nil is FAR easier than trying to handle
      # updating it
      updated_event = put_in(event, [:Event, :timestamp], nil)

      HTTP.post("/events/edit/#{event_id}", updated_event, MISP.Event.decoder())
  end

  @doc """
  Delete an event

      iex> MISP.Event.get(16) |> MISP.Event.delete()
      %{
          "message" => "Event deleted.",
          "name" => "Event deleted.",
          "url" => "/events/delete/16"
      }
  """
  def delete(%Event{Event: %EventInfo{id: event_id}}) do
    HTTP.delete("/events/#{event_id}")
  end

  def delete(event) when is_list(event) do
    Enum.map(event, fn x -> delete(x) end)
  end

  @doc """
  Append attributes to our list. Requires an update or create call afterwards.

  Will append the specified attribute to your event struct and return the result.

  To add it to a new event struct:

      iex> my_event = %MISP.EventInfo{info: "hello world!"}
      iex> my_event_with_attr = MISP.Event.add_attribute(my_event, %MISP.Attribute{value: "8.8.8.8", type: "ip-dst"})
      %MISP.EventInfo{
        Attribute: [
          %MISP.Attribute{
            value: "8.8.8.8", type: "ip-dst"
          }
        ]
      }
      iex> {:ok, my_event_with_attr} = MISP.Event.create(my_event)

  To add a new attribute to an existing event:

      iex> {:ok, my_event} = MISP.Event.get(24)
      iex> my_event_with_attr = MISP.Event.add_attribute(my_event, %MISP.Attribute{value: "8.8.8.8", type: "ip-dst"})
      iex> {:ok, my_event_with_attr} = MISP.Event.update(my_event)      
  """
  def add_attribute(%EventInfo{} = event_info, %Attribute{} = attribute) do
    Map.put(event_info, :Attribute, Map.get(event_info, :Attribute) ++ [attribute])
  end

  def add_attribute(%Event{Event: %EventInfo{} = event_info} = event, %Attribute{} = attribute) do
    Map.put(event, :Event, add_attribute(event_info, attribute))    
  end

  def add_attribute(%Event{} = event, attributes) when is_list(attributes) do
    Enum.reduce(attributes, event, fn attr, acc -> Event.add_attribute(acc, attr) end)
  end

  @doc """
  Search for events

  Sets a default limit of 100

      iex> MISP.Event.search(%{eventinfo: "my event"})
      {:ok, [
        %MISP.Event{
          Event: %MISP.EventInfo{
            info: "my event"
          }
        }
      ]}

  Valid search keys are listed on MISP's documentation, this section may be out of date

  page, limit, value, type, category, org, tag, tags, searchall, from, to, last,
  eventid, withAttachments, metadata, uuid, published, publish_timestamp, timestamp,
  enforceWarninglist, sgReferenceOnly, eventinfo
  """
  def search(%{} = params) do
    search_base = %{
      returnFormat: "json",
      limit: "100",
      page: "0"
    }

    search_params =
      search_base
      |> Map.merge(params)

    case HTTP.post("/events/restSearch", search_params, %{"response" => [Event.decoder()]}) do
      {:ok, list} -> {:ok, Map.get(list, "response")}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Add a tag to an event

      iex> MISP.Event.get(24) |> MISP.Event.add_tag(%MISP.Tag{name: "test", colour: "#ff0000"})
      %MISP.Event{
        Event: %MISP.EventInfo{
          Tag: [
            %MISP.Tag{
              colour: "#ff0000",
              exportable: true,
              hide_tag: false,
              id: "1",
              name: "test"
            }
          ]
        }
      }

  This will not save your event immediately (otherwise we end up in timestamp hell if you
  want to do a load at once), so make sure you call update() once you've added your tags

      iex> {:ok, my_event} = MISP.Event.get(24)
      iex> tagged = MISP.Event.add_tag(my_event, %MISP.Tag{name: "test"})
      iex> {:ok, updated_event} = MISP.Event.update(tagged)
  """
  def add_tag(%Event{Event: %EventInfo{} = event_info} = event, %Tag{} = tag) do
    event_info
    |> add_tag(tag)
    |> wrap()
  end

  def add_tag(%EventInfo{} = event_info, tag) do
    Map.put(event_info, :Tag, Map.get(event_info, :Tag) ++ [tag])
  end
end
