defmodule Wdbomber.Processor do
  @moduledoc false

  alias HTTPoison.Response
  alias Wdbomber.Client

  def run_single(label, url, actions, region) do
    start_time = DateTime.utc_now()

    with {:ok, %Response{body: session_create_body}} <- Client.session_create(url, region),
         {:ok, %{"sessionId" => session_id, "status" => 0}} <- Jason.decode(session_create_body),
         session_url <- "#{url}/session/#{session_id}",
         :ok <- session_navigate_actions(session_url, "about:blank", actions),
         {:ok, %Response{body: session_destroy_body}} <- Client.session_destroy(session_url),
         {:ok, %{"status" => 0}} <- Jason.decode(session_destroy_body) do
      seconds_spent = DateTime.diff(DateTime.utc_now(), start_time, :microsecond) / 1_000_000

      IO.puts("#{label}: took #{seconds_spent}s")

      :ok
    else
      error ->
        # credo:disable-for-next-line
        IO.inspect(error, label: "#{label}: errored")

        {:error, error}
    end
  end

  defp session_navigate_actions(session_url, url_to_navigate, actions) when actions > 0 do
    with {:ok, %Response{body: session_navigate_body}} <- Client.session_navigate(session_url, url_to_navigate),
         {:ok, %{"status" => 0}} <- Jason.decode(session_navigate_body) do
      session_navigate_actions(session_url, url_to_navigate, actions - 1)
    else
      error -> error
    end
  end

  defp session_navigate_actions(_, _, _), do: :ok
end
