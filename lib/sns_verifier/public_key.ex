defmodule SNSVerifier.PublicKey do
  @aws_hostname_pattern ~r/^sns\.[a-zA-Z0-9\-]{3,}\.amazonaws\.com(\.cn)?$/

  def get(cert_url) do
    http_client = Application.get_env(:sns_verifier, :http_client, HTTPoison)

    with true <- verify_host(cert_url),
         {:ok, %{status_code: 200, body: cert_binary}} <- http_client.request(:get, cert_url),
         pem_entries <- :public_key.pem_decode(cert_binary),
         {:ok, cert} <- get_pem_entry(pem_entries),
         public_key <- get_public_key(cert) do
      {:ok, public_key}
    else
      false ->
        {:error, "Invalid cert url. Signing cert is not hosted by AWS: #{cert_url}"}

      error ->
        error
    end
  end

  defp verify_host(url) do
    uri = URI.parse(url)
    Regex.match?(@aws_hostname_pattern, uri.host) && uri.scheme == "https"
  end

  defp get_pem_entry(pem_entries) do
    case pem_entries do
      [entry] ->
        try do
          {:ok, :public_key.pem_entry_decode(entry)}
        catch
          _kind, error -> {:error, "Unexpected error while decoding pem entry: #{inspect(error)}"}
        end

      entries ->
        {:error, "Invalid PEM entries: #{inspect(entries)}"}
    end
  end

  defp get_public_key(cert) do
    :public_key.der_decode(:RSAPublicKey, cert |> elem(1) |> elem(7) |> elem(2))
  end
end
