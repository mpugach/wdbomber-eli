defmodule Wdbomber.Processor do
  @moduledoc false

  alias HTTPoison.Response

  @recv_timeout 1500000

  def run(url, iterations, concurrency, actions, region) do
    iterations_length = iterations |> Integer.to_string |> String.length
    concurrency_length = concurrency |> Integer.to_string |> String.length
    padding = iterations_length + concurrency_length + 1

    Enum.each(
      1..iterations,
      fn iteration ->
        pids = spawn_async_tasks({[], concurrency, url, actions, region, iteration, padding})

        Enum.each(pids, &(Task.await(&1, :infinity)))
      end
    )
  end

  def run_single(worker_id, url, _actions, region, iteration, padding) do
    start_time = DateTime.utc_now
    iteration_and_worker = String.pad_trailing("#{iteration}/#{worker_id}", padding)

    with  {:ok, %Response{body: session_create_body}} <- session_create(url, region),
          {:ok, %{"sessionId" => session_id, "status" => 0}} <- Jason.decode(session_create_body),
          session_url <- "#{url}/session/#{session_id}",
          {:ok, %Response{body: session_navigate_body}} <- session_navigate(session_url, "about:blank"),
          {:ok, %{"status" => 0}} <- Jason.decode(session_navigate_body),
          {:ok, %Response{body: session_destroy_body}} <- session_destroy(session_url),
          {:ok, %{"status" => 0}} <- Jason.decode(session_navigate_body) do
        seconds_spent = DateTime.diff(DateTime.utc_now, start_time, :microsecond) / 1000_000

        IO.puts("#{iteration_and_worker}: took #{seconds_spent}s")

        :ok
      else
        error ->
          IO.inspect(error, label: "#{iteration_and_worker}: errored")

          {:error, error}
    end
  end

  defp spawn_async_tasks({pids, 0, _, _, _, _, _}), do: pids
  defp spawn_async_tasks({pids, worker_id, url, actions, region, iteration, padding}) do
    pid = Task.async(__MODULE__, :run_single, [worker_id, url, actions, region, iteration, padding])

    spawn_async_tasks({[pid | pids], worker_id - 1, url, actions, region, iteration, padding})
  end

  defp session_create(url, region) do
    HTTPoison.post(url <> "/session", desired_capabilities_body(region), [], [recv_timeout: @recv_timeout])
  end

  defp session_navigate(session_url, url_to_navigate) do
    HTTPoison.post(session_url <> "/url", ~s({"url":"#{url_to_navigate}"}), [], [recv_timeout: @recv_timeout])
  end

  defp session_destroy(session_url) do
    HTTPoison.delete(session_url, [], [recv_timeout: @recv_timeout])
  end

  defp desired_capabilities_body(nil),
    do: ~s({"desiredCapabilities":{"browserName": "chrome"}})
  defp desired_capabilities_body(region),
    do: ~s({"desiredCapabilities":{"browserName": "chrome","superOptions":{"region":"#{region}"}}})
end
