defmodule Wdbomber.Processor do
  @moduledoc false

  alias HTTPoison.Response

  @recv_timeout 1_500_000

  def run_single(label, url, actions, region) do
    start_time = DateTime.utc_now()

    with {:ok, %Response{body: session_create_body}} <- session_create(url, region),
         {:ok, %{"sessionId" => session_id, "status" => 0}} <- Jason.decode(session_create_body),
         session_url <- "#{url}/session/#{session_id}",
         :ok <- session_navigate_actions(session_url, "about:blank", actions),
         {:ok, %Response{body: session_destroy_body}} <- session_destroy(session_url),
         {:ok, %{"status" => 0}} <- Jason.decode(session_destroy_body) do
      seconds_spent = DateTime.diff(DateTime.utc_now(), start_time, :microsecond) / 1000_000

      IO.puts("#{label}: took #{seconds_spent}s")

      :ok
    else
      error ->
        IO.inspect(error, label: "#{label}: errored")

        {:error, error}
    end
  end

  defp session_create(url, region) do
    HTTPoison.post(url <> "/session", desired_capabilities_body(region), [],
      recv_timeout: @recv_timeout,
      hackney: [pool: :httpoison_pool]
    )
  end

  defp session_navigate(session_url, url_to_navigate) do
    HTTPoison.post(session_url <> "/url", ~s({"url":"#{url_to_navigate}"}), [],
      recv_timeout: @recv_timeout,
      hackney: [pool: :httpoison_pool]
    )
  end

  defp session_destroy(session_url) do
    HTTPoison.delete(session_url, [],
      recv_timeout: @recv_timeout,
      hackney: [pool: :httpoison_pool]
    )
  end

  defp session_navigate_actions(session_url, url_to_navigate, actions) when actions > 0 do
    with {:ok, %Response{body: session_navigate_body}} <- session_navigate(session_url, url_to_navigate),
         {:ok, %{"status" => 0}} <- Jason.decode(session_navigate_body) do
      session_navigate_actions(session_url, url_to_navigate, actions - 1)
    else
      error -> error
    end
  end

  defp session_navigate_actions(_, _, _), do: :ok

  defp desired_capabilities_body(nil),
    do: ~s({"desiredCapabilities":{"browserName": "chrome"}})

  defp desired_capabilities_body(region),
    do: ~s({"desiredCapabilities":{"browserName": "chrome","superOptions":{"region":"#{region}"}}})
end
