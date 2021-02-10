defmodule MISP.MixProject do
  use Mix.Project

  def project do
    [
      app: :mispex,
      description: "A wrapper to interact with MISP's API.",
      version: "0.1.8",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      source_url: "https://github.com/FloatingGhost/mispex"
    ]
  end

  defp package() do
    [
      licenses: ["MIT"],
      links: %{"MISP Project" => "http://misp.software"}
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :httpoison]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.4"},
      {:poison, "~> 3.1"},
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:typed_struct, "~> 0.1.4"},
      {:accessible, "~> 0.2.1"},
      {:jason, "~> 1.2"}
    ]
  end
end
