defmodule Wdbomber.Client do
  @moduledoc false

  @timeout 1_500_000
  @headers [{"Content-Type", "application/json"}]
  @default_capabilities ~s("browserName":"chrome")
  @options [
    timeout: @timeout,
    recv_timeout: @timeout,
    hackney: [pool: :httpoison_pool]
  ]

  def pool_worker(max_connections),
    do: :hackney_pool.child_spec(:httpoison_pool, timeout: @timeout, max_connections: max_connections)

  def session_create(url, region) do
    HTTPoison.post(url <> "/session", desired_capabilities_body(region), @headers, @options)
  end

  def session_navigate(session_url, url_to_navigate) do
    HTTPoison.post(session_url <> "/url", ~s({"url":"#{url_to_navigate}"}), @headers, @options)
  end

  def session_destroy(session_url) do
    HTTPoison.delete(session_url, @headers, @options)
  end

  defp desired_capabilities_body(nil),
    do: ~s({"desiredCapabilities":{#{@default_capabilities}}})

  defp desired_capabilities_body(region),
    do: ~s({"desiredCapabilities":{#{@default_capabilities},"superOptions":{"region":"#{region}"}}})
end
