defmodule MISPTest do
  use ExUnit.Case

  alias MISP.{
    Event,
    EventInfo,
    Attribute
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

    Enum.map(1..10, fn x -> Event.create(%EventInfo{info: event_info}) end)

    deleted_count =
      MISP.Event.search(%{eventinfo: event_info})
      |> MISP.Event.delete()
      |> Enum.count(fn x -> x["message"] == "Event deleted." end)

    assert 10 == deleted_count
  end
end
