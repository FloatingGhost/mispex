defmodule MISPTest.Helper do
  def delete_events do
    {:ok, events} = MISP.Event.search(%{eventinfo: "my event"})
    events |> MISP.Event.delete()
  end

  def delete_tags do
    case MISP.Tag.search("test:%") do
      {:ok, tags} -> MISP.Tag.delete(tags)
      {:error, _} -> nil
    end
  end
end
