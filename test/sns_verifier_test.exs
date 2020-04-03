defmodule SNSVerifierTest do
  use ExUnit.Case
  doctest SNSVerifier

  test "greets the world" do
    assert SNSVerifier.hello() == :world
  end

  describe "verify_message/1" do
    setup [:add_verify_message, :add_cert]

    test "validate a pristine message from SNS", %{verify_message: message, cert_binary: cert} do
      Mox.defmock(HttpMock, for: HTTPoison.Base)

      Application.put_env(:sns_verifier, :http_client, HttpMock)

      Mox.expect(HttpMock, :request, fn :get, _url ->
        {:ok, %{status_code: 200, body: cert}}
      end)

      assert :ok == SNSVerifier.verify_message(message)
    end
  end

  defp add_verify_message(context) do
    message = %{
      "Type" => "Notification",
      "MessageId" => "5b324425-3d5e-4fdf-a3f6-f46b8f93df79",
      "TopicArn" => "arn:aws:sns:eu-west-1:382739154790:for_justeat_aws_specs",
      "Subject" => "sdfghdsfg",
      "Message" => "dfgdsfg",
      "Timestamp" => "2012-04-30T11:07:54.008Z",
      "SignatureVersion" => "1",
      "Signature" =>
        "CTbst0fA37gbKnC0fiWK6HB0nQOr767MSLCJaWb0GyXc7283m1gozU3lRvOBaKP5Cwcj+clhR+rAN1m0Cp6W63oxBEu9n1Z50oyWx/tWtQd2j+MPaes+tNJSGohjHSe5qAqMwvYFYTZkbgFDFoWuVQLQuRj9I53hR1Eo3waHkJQ=",
      "SigningCertUrl" =>
        "https://sns.eu-west-1.amazonaws.com/SimpleNotificationService-f3ecfb7224c7233fe7bb5f59f96de52f.pem",
      "UnsubscribeUrl" =>
        "https://sns.eu-west-1.amazonaws.com/?Action=Unsubscribe&SubscriptionArn=arn:aws:sns:eu-west-1:382739154790:for_justeat_aws_specs:674f4ab3-2d1d-4df9-b411-b8a336f0ef7d"
    }

    context |> Map.put(:verify_message, message)
  end

  defp add_cert(context) do
    cert_binary =
      """
      -----BEGIN CERTIFICATE-----
      MIIE+TCCA+GgAwIBAgIQax6zU8p9DAWTsa4uy9uF1jANBgkqhkiG9w0BAQUFADCB
      tTELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDlZlcmlTaWduLCBJbmMuMR8wHQYDVQQL
      ExZWZXJpU2lnbiBUcnVzdCBOZXR3b3JrMTswOQYDVQQLEzJUZXJtcyBvZiB1c2Ug
      YXQgaHR0cHM6Ly93d3cudmVyaXNpZ24uY29tL3JwYSAoYykwOTEvMC0GA1UEAxMm
      VmVyaVNpZ24gQ2xhc3MgMyBTZWN1cmUgU2VydmVyIENBIC0gRzIwHhcNMTAxMDA4
      MDAwMDAwWhcNMTMxMDA3MjM1OTU5WjBqMQswCQYDVQQGEwJVUzETMBEGA1UECBMK
      V2FzaGluZ3RvbjEQMA4GA1UEBxQHU2VhdHRsZTEYMBYGA1UEChQPQW1hem9uLmNv
      bSBJbmMuMRowGAYDVQQDFBFzbnMuYW1hem9uYXdzLmNvbTCBnzANBgkqhkiG9w0B
      AQEFAAOBjQAwgYkCgYEAv8OHcwOX+SpVUpdS6OtB0FbmX6w7FQIXLJyChbcYQ3Ck
      gJnrVJ5OFIMYAc+YMbkikXnvu9+MvZx38ZV8hIYBK4y4YSR/fLMzTIqsQXKW7myq
      mIeEGGqGrCVVhs0xusCgfNBi64/zczJ3z/KLLzSXZ2Ln18MCCjQ3A8EcuwFeMTsC
      AwEAAaOCAdEwggHNMAkGA1UdEwQCMAAwCwYDVR0PBAQDAgWgMEUGA1UdHwQ+MDww
      OqA4oDaGNGh0dHA6Ly9TVlJTZWN1cmUtRzItY3JsLnZlcmlzaWduLmNvbS9TVlJT
      ZWN1cmVHMi5jcmwwRAYDVR0gBD0wOzA5BgtghkgBhvhFAQcXAzAqMCgGCCsGAQUF
      BwIBFhxodHRwczovL3d3dy52ZXJpc2lnbi5jb20vcnBhMB0GA1UdJQQWMBQGCCsG
      AQUFBwMBBggrBgEFBQcDAjAfBgNVHSMEGDAWgBSl7wsRzsBBA6NKZZBIshzgVy19
      RzB2BggrBgEFBQcBAQRqMGgwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLnZlcmlz
      aWduLmNvbTBABggrBgEFBQcwAoY0aHR0cDovL1NWUlNlY3VyZS1HMi1haWEudmVy
      aXNpZ24uY29tL1NWUlNlY3VyZUcyLmNlcjBuBggrBgEFBQcBDARiMGChXqBcMFow
      WDBWFglpbWFnZS9naWYwITAfMAcGBSsOAwIaBBRLa7kolgYMu9BSOJsprEsHiyEF
      GDAmFiRodHRwOi8vbG9nby52ZXJpc2lnbi5jb20vdnNsb2dvMS5naWYwDQYJKoZI
      hvcNAQEFBQADggEBAKcmdO9iRCChdO21L0NaB24f2BFuUZO/y9tsTgC6NJ8p0sJU
      +/dKc4p33pnmDE8EGDbImMd/HdVnqQ4nngurjzu7z/mv7247FGaUL/BnqLgOQJiM
      YBJtskNd2vKN4kk4I6Z7e2mp2+4tzBL9Sk/x3b297oy4ZXILrBKxr9s9MhyPO1rQ
      Mda9v2L3qcjPj38zbNoohEIpu/ilArbbFOUMOqdh7jomDoE3cyBDWMOOBh+t6QQD
      kMFvPxlw0XwWsvjTGPFCBIR7NZXnwQfVYbdFu88TjT10wTCZ/E3yCp77aDWD1JLV
      2V2EF3v1wPCPCbvEKZKVR5rLVYl2djU9j9d+H30=
      -----END CERTIFICATE-----
      """
      |> String.strip()

    context |> Map.put(:cert_binary, cert_binary)
  end
end
