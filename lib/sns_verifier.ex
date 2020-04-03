defmodule SNSVerifier do
  @moduledoc """
  Verifies SNS message with public key from `SigningCertUrl`.

  """

  alias SNSVerifier.PublicKey

  @confirmation_params [
    "Message",
    "MessageId",
    "SubscribeURL",
    "Timestamp",
    "Token",
    "TopicArn",
    "Type"
  ]
  @notification_params ["Message", "MessageId", "Subject", "Timestamp", "TopicArn", "Type"]

  @spec verify_message(map()) :: :ok | {:error, any}
  def verify_message(message_params) do
    with message <- convert_lambda_message(message_params),
         {:ok, public_key} <- PublicKey.get(message["SigningCertURL"]) do
      message_params
      |> get_string_to_sign()
      |> verify(message_params["Signature"], public_key)
    else
      error ->
        error
    end
  end

  defp convert_lambda_message(%{"SigningCertUrl" => cert_url} = message) do
    message
    |> Map.delete("SigningCertUrl")
    |> Map.put("SigningCertURL", cert_url)
  end

  defp convert_lambda_message(message), do: message

  defp get_string_to_sign(message_params) do
    message_params
    |> Map.take(get_params_to_sign(message_params["Type"]))
    |> Enum.map(fn {key, value} -> [to_string(key), "\n", to_string(value), "\n"] end)
    |> IO.iodata_to_binary()
  end

  defp get_params_to_sign(message_type) do
    case message_type do
      "Notification" -> @notification_params
      "SubscriptionConfirmation" -> @confirmation_params
      "UnsubscribeConfirmation" -> @confirmation_params
    end
  end

  defp verify(message, signature, public_key) do
    case :public_key.verify(message, :sha, Base.decode64!(signature), public_key) do
      true -> :ok
      false -> {:error, "Signature is invalid"}
    end
  end
end
