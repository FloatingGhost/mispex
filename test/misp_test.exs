defmodule MISPTest.Base do
  use ExUnit.Case

  alias MISP.{
    Event,
    EventInfo,
    Attribute,
    Tag
  }

  test "connection test" do
    {:ok, "2.4." <> _} = MISP.get_version()
  end
end
