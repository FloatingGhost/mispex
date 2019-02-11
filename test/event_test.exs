defmodule MISPTest.Event do
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
      MISP.Tag.search("test:%") |> MISP.Tag.delete()
    end)
  end


  test "create event" do
    my_event =
      %Event{Event: %EventInfo{info: "my event"}}
      |> MISP.Event.create()

    assert get_in(my_event, [:Event, :info]) == "my event"
  end

  test "create event without wrapper" do
    %Event{Event: %EventInfo{info: "my event"}} =
      %EventInfo{info: "my event"}
      |> MISP.Event.create()
  end

  test "search for an event" do
    %EventInfo{info: "my totally unique event"} |> MISP.Event.create()
    matching = Event.search(%{eventinfo: "my totally unique event"})
    assert Enum.count(matching) == 1
    matching |> MISP.Event.delete()
  end

  test "edit an event" do
    %Event{Event: %EventInfo{info: "my event"}} =
      %EventInfo{info: "not my event"}
      |> MISP.Event.create()
      |> put_in([:Event, :info], "my event")
      |> MISP.Event.update()
  end

  test "delete an event" do
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
      |> MISP.Event.add_tag(%Tag{name: "test:event-level-tag-after-create"})
      |> MISP.Event.update()

    assert Enum.count(get_in(event, [:Event, :Tag])) == 1

    # Then with a tag we create beforehand
    precreated_tag =
      %Tag{name: "test:event-level-before-creation"}
      |> MISP.Tag.create()

    event =
      %EventInfo{info: "my event"}
      |> MISP.Event.create()
      |> MISP.Event.add_tag(precreated_tag)
      |> MISP.Event.update()

    assert Enum.count(get_in(event, [:Event, :Tag])) == 1

    # Then in the original object
    event =
      %EventInfo{info: "my event", Tag: [%Tag{name: "test:included-in-event-json"}]}
      |> MISP.Event.create()

    assert Enum.count(get_in(event, [:Event, :Tag])) == 1
  end

  test "create an event with a tagged attribute included" do
    event =
      %Event{
        Event: %EventInfo{
          info: "my event",
          Attribute: [
            %Attribute{
              value: "8.8.8.8",
              type: "ip-dst",
              Tag: [%Tag{name: "test:attribute-level-on-new-event"}]
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