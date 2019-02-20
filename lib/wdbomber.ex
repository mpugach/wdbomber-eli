defmodule Wdbomber do
  @moduledoc false

  alias Wdbomber.Processor

  def main(args) do
    args |> parse_args() |> do_process()
  end

  defp parse_args(args) do
    options =
      OptionParser.parse(args,
        aliases: [h: :help, r: :region],
        strict: [help: :boolean, region: :string]
      )

    case options do
      {[region: region], [url, iterations, concurrency, actions], _} ->
        [url, Integer.parse(iterations), Integer.parse(concurrency), Integer.parse(actions), region]

      {_, [url, iterations, concurrency, actions], _} ->
        [url, Integer.parse(iterations), Integer.parse(concurrency), Integer.parse(actions), nil]

      {[help: true], _, _} ->
        {:help, 0}

      _ ->
        {:help, 1}
    end
  end

  defp do_process({:help, status}) do
    IO.puts("""
      Usage:
      wdbomber URL ITERATIONS CONCURRENCY ACTIONS OPTIONS

      ITERATIONS, CONCURRENCY and ACTIONS should be numbers

      Options:
      -h, --help                 Show this help message.
      -r REGION, --region=REGION Specify a region.
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

    Processor.run(url, iterations, concurrency, actions, region)
    System.halt(0)
  end

  defp do_process(_), do: do_process({:help, 1})
end
