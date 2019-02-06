defmodule MISPTest do
  use ExUnit.Case

  alias MISP.{
    Event,
    EventInfo,
    Attribute
  }

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
end
