defmodule MISP.Event do
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

  def get(id) when is_integer(id) or is_binary(id) do
    HTTP.get("/events/#{id}", Event.decoder())
  end

  def get(%Event{} = event), do: event

  @doc """
  Create a new event. Mandatory fields: info.

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
    Event.create(%Event{Event: event_info})
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
  def add_attribute(%Event{Event: event_info} = event, %Attribute{} = attribute) do
    with %Attribute{} <- Attribute.create(event, attribute) do
      Event.get(event_info.id)
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
