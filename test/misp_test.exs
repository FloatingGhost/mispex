defmodule MISPTest do
  use ExUnit.Case
  doctest MISP

  test "greets the world" do
    assert MISP.hello() == :world
  end
end
