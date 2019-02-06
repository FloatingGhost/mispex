defmodule MISPTest do
  use ExUnit.Case

  test "create event" do
    %{"Event" => %{"info" => "my event"}} = 
        %{"info" => "my event"}
        |> MISP.create_event()
  end
end
