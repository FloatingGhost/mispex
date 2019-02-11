defmodule MISPTest.Attribute do
  use ExUnit.Case

  alias MISP.{
    Event,
    EventInfo,
    Attribute,
    Tag
  }

  test "create an attribute and tag it" do
    event =
      %Event{
        Event: %EventInfo{
          info: "my event",
          Attribute: [%Attribute{value: "8.8.8.8", type: "ip-dst"}]
        }
      }
      |> MISP.Event.create()

    event_id = get_in(event, [:Event, :id])

    event
    |> get_in([:Event, :Attribute])
    |> List.first()
    |> MISP.Attribute.add_tag(%Tag{name: "test:attribute-level-on-existing"})
    |> MISP.Attribute.update()

    tags =
      MISP.Event.get(event_id)
      |> get_in([:Event, :Attribute])
      |> List.first()
      |> Map.get(:Tag)

    assert 1 == Enum.count(tags)
    %Tag{name: "test:attribute-level-on-existing"} = List.first(tags)
  end

  test "search for an attribute" do
    unique_value = "this is a totally unique value!"

    event =
      %EventInfo{
        info: "my event",
        Attribute: [%Attribute{value: unique_value, type: "text"}]
      }
      |> MISP.Event.create()

    matching = MISP.Attribute.search(%{value: unique_value})
    assert Enum.count(matching) == 1

    %Attribute{value: ^unique_value} = List.first(matching)
  end
end
