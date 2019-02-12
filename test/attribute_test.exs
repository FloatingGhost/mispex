defmodule MISPTest.Attribute do
  use ExUnit.Case

  alias MISP.{
    Event,
    EventInfo,
    Attribute,
    Tag
  }

  setup do
    on_exit(fn ->
      MISPTest.Helper.delete_events()
      MISPTest.Helper.delete_tags()
    end)
  end

  test "create an attribute and tag it" do
    {:ok, event} =
      %Event{
        Event: %EventInfo{
          info: "my event",
          Attribute: [%Attribute{value: "8.8.8.8", type: "ip-dst"}]
        }
      }
      |> MISP.Event.create()

    event_id = get_in(event, [:Event, :id])

    {:ok, _} =
      event
      |> get_in([:Event, :Attribute])
      |> List.first()
      |> MISP.Attribute.add_tag(%Tag{name: "test:attribute-level-on-existing"})

    {:ok, server_side_event} = MISP.Event.get(event_id)

    tags =
      server_side_event
      |> get_in([:Event, :Attribute])
      |> List.first()
      |> Map.get(:Tag)

    assert 1 == Enum.count(tags)
    %Tag{name: "test:attribute-level-on-existing"} = List.first(tags)
  end

  test "search for an attribute" do
    unique_value =
      :crypto.strong_rand_bytes(20)
      |> Base.url_encode64()

    unique_value = "this is a totally unique value!"

    {:ok, event} =
      %EventInfo{
        info: "my event",
        Attribute: [%Attribute{value: unique_value, type: "text"}]
      }
      |> MISP.Event.create()

    {:ok, matching} = MISP.Attribute.search(%{value: unique_value})
    assert Enum.count(matching) == 1

    %Attribute{value: ^unique_value} = List.first(matching)

    event |> MISP.Event.delete()
  end
end
