# MISP

A wrapper around MISP's HTTP API to provide native interaction.


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `mispex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:mispex, "~> 0.1.6"}
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

### Create an event

```elixir
%MISP.EventInfo{info: "my event"}
|> MISP.Event.create()
```

### Retrive an event

```elixir
MISP.Event.get(15)
```

### Update an event

```elixir
MISP.Event.get(17)
|> put_in([:Event, :info], "my new info field")
|> MISP.Event.update()
```

### Add an attribute

```elixir
MISP.Event.get(17)
|> MISP.Event.add_attribute(%MISP.Attribute{value: "8.8.8.8", type: "ip-dst"})
```

### Tag an event

```elixir
MISP.Event.get(17)
|> MISP.Event.add_tag(%MISP.Tag{name: "my tag"})
|> MISP.Event.update()
```

### Tag an attribute

```elixir
MISP.Attribute.search(%{value: "8.8.8.8"})
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

### Errors

Error cases are returned wrapped in a tuple like so

```elixir
iex(1)> %MISP.EventInfo{} |> MISP.Event.create 
{:error,
 [
   code: 403,
   reason: "{\n    \"name\": \"Could not add Event\",\n    \"message\": \"Could not add Event\",\n    \"url\": \"\\/events\\/add\",\n    \"errors\": {\n        \"Event\": {\n            \"info\": [\n                \"Info cannot be empty.\"\n            ]\n        }\n    }\n}"
 ]}

```
