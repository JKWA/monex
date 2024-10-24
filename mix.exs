defmodule Monex.MixProject do
  use Mix.Project

  def project do
    [
      app: :monex,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      dialyzer: [
        plt_add_apps: [:elixir, :mix],
        plt_core_path: "_build/#{Mix.env()}",
        plt_file: {:no_warn, "_build/#{Mix.env()}/dialyzer.plt"}
      ],
      docs: [
        main: "readme",
        extras: ["README.md", "CHANGELOG.md", "LEARNING_RESOURCES.md", "LICENSE"],
        filter_prefix: "Examples",
        source_url: "https://github.com/JKWA/monex",
        source_url_pattern: "https://github.com/JKWA/monex/blob/main/%{path}#L%{line}"
      ]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support", "examples"]
  defp elixirc_paths(_), do: ["lib", "examples"]

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
      {:earmark, "~> 1.4", only: :dev, runtime: false},
      {:makeup_elixir, "~> 0.16", only: :dev, runtime: false},
      {:dialyxir, "~> 1.4", only: :dev, runtime: false},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false}
    ]
  end
end
