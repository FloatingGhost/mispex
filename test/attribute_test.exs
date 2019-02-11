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

    tag_count =
      MISP.Event.get(event_id)
      |> get_in([:Event, :Attribute])
      |> List.first()
      |> Map.get(:Tag)
      |> Enum.count()

    assert 1 == tag_count
  end
end  
