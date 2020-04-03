# SNSVerifier

Verifies message from AWS SNS with certificate from `SigningCertUrl`.

Description for verification can be found on [AWS docs](https://docs.aws.amazon.com/sns/latest/dg/sns-verify-signature-of-message.html).

## Usage

```elixir
alias SNSVerifier, as: SNS

iex(1)> SNS.verify_message(message)
:ok

iex(1)> SNS.verify_message(invalid_message)
{:error, "message"}
```

## Installation

The package can be installed by adding `sns_verifier` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:sns_verifier, git: "https://github.com/sevenmind/sns_verifier.git"}
  ]
end
```
