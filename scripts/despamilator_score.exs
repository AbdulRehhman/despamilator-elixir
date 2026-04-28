#!/usr/bin/env elixir
# Usage: mix run scripts/despamilator_score.exs <file-or-glob>

defmodule DespamilatorScore do
  def run([pattern]) do
    pattern
    |> Path.wildcard()
    |> Enum.map(&check/1)
    |> Enum.sort_by(fn {_f, s} -> s end)
    |> Enum.each(fn {file, score} -> IO.puts("#{file} | #{score}") end)
  end

  def run(_) do
    IO.puts(:stderr, "Usage: mix run scripts/despamilator_score.exs <file-or-glob>")
    System.halt(1)
  end

  defp check(file) do
    text = File.read!(file)

    IO.puts("Testing #{file}:")
    IO.puts("========================")
    IO.puts(text)
    IO.puts("========================\n")

    result = Despamilator.scan(text)
    matches = Despamilator.Subject.matches(result)

    IO.puts("Total Score: #{result.score}\n")

    unless matches == [] do
      IO.puts("Matched by...")

      Enum.each(matches, fn %{filter: f, score: s} ->
        IO.puts("\tFilter: #{f.name()}")
        IO.puts("\tScore:  #{s}\n")
      end)
    end

    {file, result.score}
  end
end

DespamilatorScore.run(System.argv())
