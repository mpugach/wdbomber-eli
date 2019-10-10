defmodule Wdbomber do
  @moduledoc false

  alias Wdbomber.Processor

  def main(args) do
    args |> parse_args() |> do_process()
  end

  defp parse_args(args) do
    options =
      OptionParser.parse(args,
        aliases: [h: :help, r: :region, v: :version],
        strict: [help: :boolean, region: :string, version: :boolean]
      )

    case options do
      {[region: region], [url, iterations, concurrency, actions], _} ->
        [
          url,
          Integer.parse(iterations),
          Integer.parse(concurrency),
          Integer.parse(actions),
          region
        ]

      {_, [url, iterations, concurrency, actions], _} ->
        [url, Integer.parse(iterations), Integer.parse(concurrency), Integer.parse(actions), nil]

      {[help: true], _, _} ->
        {:help, 0}

      {[version: true], _, _} ->
        :version

      _ ->
        {:help, 1}
    end
  end

  @version Mix.Project.config[:version]
  defp do_process(:version) do
    IO.puts(@version)
    System.halt(0)
  end

  defp do_process({:help, status}) do
    IO.puts("""
      Usage:
      wdbomber URL ITERATIONS CONCURRENCY ACTIONS OPTIONS

      ITERATIONS, CONCURRENCY and ACTIONS should be numbers

      Options:
      -h, --help                 Show this help message.
      -r REGION, --region=REGION Specify a region.
      -v, --version              Show version.
    """)

    System.halt(status)
  end

  defp do_process([url, {iterations, _}, {concurrency, _}, {actions, _}, region]) do
    IO.puts("""
    attacking #{url}
    iterations: #{iterations}
    concurrency: #{concurrency}
    actions: #{actions}
    region: #{region}
    """)

    iterations_length = iterations |> Integer.to_string() |> String.length()
    concurrency_length = concurrency |> Integer.to_string() |> String.length()
    padding = iterations_length + concurrency_length + 1

    labels =
      for iteration <- 1..iterations,
          concurrency_id <- 1..concurrency,
          do: String.pad_trailing("#{iteration}/#{concurrency_id}", padding)

    labels
    |> Flow.from_enumerable(stages: concurrency, max_demand: 1)
    |> Flow.each(&Processor.run_single(&1, url, actions, region))
    |> Flow.run()

    IO.puts("OK")

    System.halt(0)
  end

  defp do_process(_), do: do_process({:help, 1})
end
