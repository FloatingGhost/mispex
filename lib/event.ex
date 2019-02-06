defmodule MISP.Event do
  @moduledoc """
  Create, delete and update MISP Events

      iex> %MISP.EventInfo{info: "hello world!"} |> MISP.Event.create() |> MISP.Event.delete()
  """
  use TypedStruct

  alias MISP.{
    EventInfo,
    HTTP,
    Event,
    Attribute
  }

  typedstruct do
    field :Event, %EventInfo{}
  end

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
  Delete an event

      iex> MISP.Event.get(16) |> MISP.Event.delete()
      %{
          "message" => "Event deleted.",
          "name" => "Event deleted.",
          "url" => "/events/delete/16"
      }
  """
  def delete(event) do
    with %Event{Event: %EventInfo{id: event_id}} <- wrap(event) do
      HTTP.delete("/events/#{event_id}")
    else
      err -> raise ArgumentError, err
    end
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

  def add_attribute(%Event{} = event, [%Attribute{} = attribute]) do
    add_attribute(event, attribute)
  end

  def add_attribute(%Event{} = event, [head | attributes]) do
    event =
      event
      |> add_attribute(head)

    add_attribute(event, attributes)
  end

  def search(%{} = params) do
    search_base = %{
      "returnFormat" => "json"
    }

    search_params =
      search_base
      |> Map.merge(params)

    HTTP.post("/events/restSearch", search_params)
    |> Map.get("response")
  end
end
