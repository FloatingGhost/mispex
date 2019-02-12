defmodule MISPTest.Tags do
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

  test "create a new tag" do
    {:ok, my_tag} = MISP.Tag.create(%MISP.Tag{name: "test:created"})
    %Tag{id: _} = my_tag
  end

  test "update a tag" do
    {:ok, my_tag} = MISP.Tag.create(%MISP.Tag{name: "test:pre-edit"})

    {:ok, edited_tag} =
      my_tag
      |> Map.put(:name, "test:post-edit")
      |> MISP.Tag.update()

    assert edited_tag.id == my_tag.id
    assert edited_tag.name == "test:post-edit"
  end

  test "retrieve a tag" do
    {:ok, %Tag{id: tag_id}} = MISP.Tag.create(%MISP.Tag{name: "test:to-retrieve"})
    {:ok, resp} = MISP.Tag.get(tag_id)

    assert resp.name == "test:to-retrieve"
  end

  test "delete a tag" do
    {:ok, my_tag} = MISP.Tag.create(%MISP.Tag{name: "test:to-delete"})
    {:ok, %{"message" => "Tag deleted."}} = MISP.Tag.delete(my_tag)
  end
end
