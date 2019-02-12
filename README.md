# MISP

A wrapper around MISP's HTTP API to provide native interaction.


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `mispex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:mispex, "~> 0.1.7"}
  ]
end
```

## Configuration

In your application config, add a block of the format

```elixir
config :mispex,
  url: "https://misp.local",
  apikey: "myapikey"
```

## Usage

See [the full documentation](https://hexdocs.pm/mispex/MISP.html) for full reference,
but here are a few common usage examples

Documentation can also be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)

All functions that call the API in any way return a tuple of the format:

```elixir
{:ok, value}
{:error, reason}
```

To indicate whether the API call was successful or not.

For example

```elixir
iex> MISP.Event.create(%MISP.EventInfo{info: "my event"})
{:ok,
 %MISP.Event{
 }
}

iex> MISP.Event.create(%MISP.EventInfo{})
{:error, "Event.info: Info cannot be empty."}
```

### Create an event

```elixir
{:ok, my_event} = %MISP.EventInfo{info: "my event"} |> MISP.Event.create()
```

### Retrive an event

```elixir
{:ok, my_event} = MISP.Event.get(15)
```

### Update an event

```elixir
{:ok, my_event} = MISP.Event.get(17)

{:ok, my_updated_event} = 
  my_event
  |> put_in([:Event, :info], "my new info field")
  |> MISP.Event.update()
```

### Add an attribute

```elixir
{:ok, my_event} = MISP.Event.get(17)

{:ok, updated_event} =
  my_event
  |> MISP.Event.add_attribute(%MISP.Attribute{value: "8.8.8.8", type: "ip-dst"})
  |> MISP.Event.update()
```

### Tag an event

```elixir
{:ok, my_event} = MISP.Event.get(17)

{:ok, tagged_event} = 
  my_event
  |> MISP.Event.add_tag(%MISP.Tag{name: "my tag"})
  |> MISP.Event.update()
```

### Tag an attribute

```elixir
{:ok, matching} = MISP.Attribute.search(%{value: "8.8.8.8"})

{:ok, updated_attr} =
  matching
  |> List.first() 
  |> MISP.Attribute.add_tag(%MISP.Tag{name: "my tag"})
  |> MISP.Attribute.update()
```

### Create an event with attributes and tags already applied

```elixir
%MISP.EventInfo{
    info: "my event",
    Attribute: [
        %MISP.Attribute{
            value: "8.8.8.8",
            type: "ip-dst",
            Tag: [
                %MISP.Tag{name: "my attribute-level tag"}
            ]
        }
    ],
    Tag: [
        %MISP.Tag{name: "my event-level tag"}
    ]
} |> MISP.Event.create()
```
