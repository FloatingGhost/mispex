defmodule MISPTest do
  use ExUnit.Case

  alias MISP.{
    Event,
    EventInfo,
    Attribute,
    Tag
  }

  setup do
    on_exit(fn ->
      MISP.Event.search(%{eventinfo: "my event"}) |> MISP.Event.delete()
    end)
  end

  test "create event" do
    %Event{Event: %EventInfo{info: "my event"}} =
      %Event{Event: %EventInfo{info: "my event"}}
      |> MISP.Event.create()
  end

  test "create event without wrapper" do
    %Event{Event: %EventInfo{info: "my event"}} =
      %EventInfo{info: "my event"}
      |> MISP.Event.create()
  end

  test "delete and event" do
    %{"message" => "Event deleted."} =
      %EventInfo{info: "my event"}
      |> MISP.Event.create()
      |> MISP.Event.delete()
  end

  test "create an event and add an attribute" do
    attribute = %Attribute{value: "8.8.8.8", type: "ip-dst"}

    %Event{Event: %EventInfo{Attribute: attributes}} =
      %EventInfo{info: "my event"}
      |> MISP.Event.create()
      |> MISP.Event.add_attribute(attribute)

    assert Enum.count(attributes) == 1
    assert List.first(attributes).value == "8.8.8.8"
  end

  test "create an event and add an array of attributes" do
    attrs = [
      %Attribute{value: "8.8.8.8", type: "ip-dst"},
      %Attribute{value: "1.1.1.1", type: "ip-src"}
    ]

    %Event{Event: %EventInfo{Attribute: attributes}} =
      %EventInfo{info: "my event"}
      |> MISP.Event.create()
      |> MISP.Event.add_attribute(attrs)

    assert Enum.count(attributes) == 2
  end

  test "delete multiple events" do
    event_info =
      :crypto.strong_rand_bytes(20)
      |> Base.url_encode64()

    Enum.map(1..10, fn _ -> Event.create(%EventInfo{info: event_info}) end)

    deleted_count =
      MISP.Event.search(%{eventinfo: event_info})
      |> MISP.Event.delete()
      |> Enum.count(fn x -> x["message"] == "Event deleted." end)

    assert 10 == deleted_count
  end

  test "create an event and tag it" do
    # First with just a create - tag flow
    event = 
        %EventInfo{info: "my event"}
        |> MISP.Event.create()
        |> MISP.Event.add_tag(%MISP.Tag{name: "my tag"})
        |> MISP.Event.update()

    assert Enum.count(get_in(event, [:Event, :Tag])) == 1

    # Then with a tag we create beforehand
    precreated_tag =
        %Tag{name: "my tag"}
        |> MISP.Tag.create()

    event =                                            
        %EventInfo{info: "my event"}                   
        |> MISP.Event.create()                         
        |> MISP.Event.add_tag(precreated_tag)
        |> MISP.Event.update()

    assert Enum.count(get_in(event, [:Event, :Tag])) == 1

    # Then in the original object
    event =                                            
        %EventInfo{info: "my event", Tag: [%Tag{name: "my tag"}]}                   
        |> MISP.Event.create()                         

    assert Enum.count(get_in(event, [:Event, :Tag])) == 1
  end

  test "crate an attribute and tag it" do
    event = 
      %Event{
        Event: %EventInfo{
          info: "my event",
          Attribute: [%Attribute{value: "8.8.8.8", type: "ip-dst"}]
      }}
      |> MISP.Event.create()

    event_id = get_in(event, [:Event, :id])

    event
    |> get_in([:Event, :Attribute])
    |> List.first()
    |> MISP.Attribute.add_tag(%MISP.Tag{name: "my tag"})
    |> MISP.Attribute.update()

    tag_count = 
      MISP.Event.get(event_id)
      |> get_in([:Event, :Attribute])
      |> List.first()
      |> Map.get(:Tag)
      |> Enum.count() 

    assert 1 == tag_count

    event =
      %Event{
        Event: %EventInfo{        
          info: "my event",
          Attribute: [
            %Attribute{
              value: "8.8.8.8",
              type: "ip-dst",
              Tag: [%MISP.Tag{name: "my tag"}]
            }
          ]
        }
      }             
      |> MISP.Event.create()
                     
    event_id = get_in(event, [:Event, :id])
    tag_count =
      MISP.Event.get(event_id)
      |> get_in([:Event, :Attribute])
      |> List.first()
      |> Map.get(:Tag)
      |> Enum.count() 
 
    assert 1 == tag_count
  end
end
