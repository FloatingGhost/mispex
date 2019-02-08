defmodule MISP.Event do
  @moduledoc """
  Represents an event within MISP

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

  def get(id) when is_integer(id) or is_binary(id) do
    HTTP.get("/events/#{id}", Event.decoder())
  end

  def get(%Event{} = event), do: event

  @doc """
  Create a new event.
  Mandatory fields: info
  Can be given either an Event or an EventInfo object

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
  def create(event) do
    with %Event{} = event <- wrap(event) do
      HTTP.post("/events/add", event, MISP.Event.decoder())
    else
      err -> raise ArgumentError, err
    end
  end

  @doc """
  Update an event
  Will update the event's timestamp and push the result

      iex> MISP.Event.get(16) |> put_in([:Event, :info], "new info!") |> MISP.Event.update()
      %MISP.Event{
        Event: %MISP.EventInfo{
          info: "new info!"
        }
      }
  """
  def update(event) do
    with %Event{Event: %EventInfo{id: event_id}} = event <- wrap(event) do
      updated_event =
        event
        |> put_in([:Event, :timestamp], :os.system_time(:seconds))

      HTTP.post("/events/edit/#{event_id}", updated_event, MISP.Event.decoder())
    else
      err -> raise ArgumentError, err
    end
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
  def delete(%Event{Event: %EventInfo{id: event_id}} = event) do
    HTTP.delete("/events/#{event_id}")
  end

  def delete(event) when is_list(event) do
    event
    |> Enum.map(fn x -> delete(x) end)
  end

  @doc """
  Create a new attribute and add it to our event object

      iex> event = %MISP.Event{}
      iex> attribute = %MISP.Attribute{value: "8.8.8.8", type: "ip-dst"}
      iex> event |> MISP.Event.add_attribute(attribute)
      %MISP.Event{
          %MISP.EventInfo{
              Attribute: [
                  %MISP.Attribute{
                      value: "8.8.8.8",
                      type: "ip-dst"
                  }
              ]
          }
      }

  Can also accept lists of attributes for bulk additions

      iex> attrs = [%MISP.Attribute{value: "8.8.8.8", type: "ip-dst"}, %MISP.Attribute{value: "8.8.8.8", type: "ip-src"}]
      iex> MISP.Event.get(100) |> MISP.Event.add_attribute(attrs)
  """
  def add_attribute(event, %Attribute{} = attribute) do
    with %Event{Event: %EventInfo{id: event_id}} <- wrap(event),
         %Attribute{} <- Attribute.create(event, attribute) do
      Event.get(event_id)
    else
      err -> IO.warn(err)
    end
  end

  def add_attribute(%Event{} = event, attributes) when is_list(attributes) do
    attributes
    |> Enum.reduce(event, fn attr, acc -> Event.add_attribute(acc, attr) end)
  end

  @doc """
  Search for events

      iex> MISP.Event.search(%{eventinfo: "my event"})
      [
        %MISP.Event{
          Event: %MISP.EventInfo{
            info: "my event"
          }
        }
      ]

  Valid search keys are listed on MISP's documentation, this section may be out of date

  page, limit, value, type, category, org, tag, tags, searchall, from, to, last,
  eventid, withAttachments, metadata, uuid, published, publish_timestamp, timestamp,
  enforceWarninglist, sgReferenceOnly, eventinfo
  """
  def search(%{} = params) do
    search_base = %{
      returnFormat: "json"
    }

    search_params =
      search_base
      |> Map.merge(params)

    HTTP.post("/events/restSearch", search_params, %{"response" => [Event.decoder()]})
    |> Map.get("response")
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

  Can also be used on not-yet-created events to add them to your event representation to do everything
  in a single HTTP call

      iex> %MISP.Event{} |> MISP.Event.add_tag(%MISP.Tag{name: "my tag"}) |> MISP.Event.create()
  """
  def add_tag(%Event{Event: %EventInfo{id: event_id}} = event, %Tag{} = tag)
      when is_binary(event_id) do
    new_tags =
      event
      |> get_in([:Event, :Tag])
      |> List.insert_at(0, tag)

    event
    |> put_in([:Event, :Tag], new_tags)
    |> update()
  end

  def add_tag(%Event{Event: %EventInfo{id: nil}} = event, %Tag{} = tag) do
    new_tags =
      event
      |> get_in([:Event, :Tag])
      |> List.insert_at(0, tag)

    event
    |> put_in([:Event, :Tag], new_tags)
  end
end
