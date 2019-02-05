# MISP

A wrapper around MISP's HTTP API to provide native interaction.


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `mispex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:mispex, "~> 0.1.0"}
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
be found at [https://hexdocs.pm/mispex](https://hexdocs.pm/mispex).

