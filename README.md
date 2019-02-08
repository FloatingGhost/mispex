# MISP

A wrapper around MISP's HTTP API to provide native interaction.


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `mispex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:mispex, "~> 0.1.4"}
  ]
end
```

## Configuration

In your application config, add config of the format

```elixir
config :mispex,
  url: "https://misp.local",
  apikey: "myapikey"
```


## Documentation

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/mispex](https://hexdocs.pm/mispex/MISP.html).


## Usage

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
```


