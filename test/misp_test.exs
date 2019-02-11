defmodule MISPTest.Base do
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

  test "connection test" do
    "2.4." <> _ = MISP.test_connection()
  end
end
