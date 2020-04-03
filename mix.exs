defmodule SNSVerifier.MixProject do
  use Mix.Project

  def project do
    [
      app: :sns_verifier,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:httpoison, "~> 1.6", only: :test},
      {:mox, "~> 0.5", only: :test}
    ]
  end
end
