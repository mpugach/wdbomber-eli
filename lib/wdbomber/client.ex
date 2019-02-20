defmodule Wdbomber.Client do
  @moduledoc false

  @recv_timeout 1_500_000

  def pool_worker(max_connections),
    do: :hackney_pool.child_spec(:httpoison_pool, timeout: @recv_timeout, max_connections: max_connections)

  def session_create(url, region) do
    HTTPoison.post(url <> "/session", desired_capabilities_body(region), [],
      recv_timeout: @recv_timeout,
      hackney: [pool: :httpoison_pool]
    )
  end

  def session_navigate(session_url, url_to_navigate) do
    HTTPoison.post(session_url <> "/url", ~s({"url":"#{url_to_navigate}"}), [],
      recv_timeout: @recv_timeout,
      hackney: [pool: :httpoison_pool]
    )
  end

  def session_destroy(session_url) do
    HTTPoison.delete(session_url, [],
      recv_timeout: @recv_timeout,
      hackney: [pool: :httpoison_pool]
    )
  end

  defp desired_capabilities_body(nil),
    do: ~s({"desiredCapabilities":{"browserName": "chrome"}})

  defp desired_capabilities_body(region),
    do: ~s({"desiredCapabilities":{"browserName": "chrome","superOptions":{"region":"#{region}"}}})
end
