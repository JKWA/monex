defmodule Monex.MixProject do
  use Mix.Project

  def project do
    [
      app: :monex,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      # Add this line to define elixirc_paths
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  # Define elixirc_paths to include "examples/" directory
  defp elixirc_paths(:test), do: ["lib", "test/support", "examples"]
  defp elixirc_paths(_), do: ["lib", "examples"]

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:dialyxir, "~> 1.4", only: :dev, runtime: false},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false}
    ]
  end
end
