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

    def get(id) when is_integer(id) or is_binary(id) do
        HTTP.get("/events/#{id}")
    end

    def get(%Event{} = event), do: event

    def create(%Event{} = event) do
        HTTP.post("/events/add", event)
    end 

    def add_attribute(%Event{Event: event_info} = event, %Attribute{} = attribute) do
      new_attr_list =
        event_info[:Attribute]
        |> List.insert_at(0, attribute)

      new_event_info = 
        event_info
        |> Map.put(:Attribute, new_attr_list)

      event
      |> Map.put(:Event, new_event_info)
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
