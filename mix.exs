defmodule SNSVerifier.MixProject do
  use Mix.Project

  def project do
    [
      app: :sns_verifier,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      description: "Verifies message from AWS SNS",
      package: package(),
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

  defp package do
    [
      maintainers: [
        "7Mind GmbH",
        "Chirag Rajkarnikar"
      ],
      licenses: ["MIT"],
      links: %{
        "GitHub" => github_link(),
        "Verifying the signatures of Amazon SNS messages" => "https://docs.aws.amazon.com/sns/latest/dg/sns-verify-signature-of-message.html"
      }
    ]
  end

  defp github_link, do: "https://github.com/sevenmind/sns_verifier"
end
