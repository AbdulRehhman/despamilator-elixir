defmodule Despamilator do
  @moduledoc """
  Plugin-based spam scanner. Scores text against many small heuristic filters
  and accumulates a total score. A score of 1.0+ is typically considered spam.

      iex> result = Despamilator.scan("some text with an <h2> tag qthhg")
      iex> result.score > 0
      true

  Each match is a map: `%{filter: module, score: float}`.
  """

  alias Despamilator.Subject

  @gtubs_test_string "89913b8a065b7092721fe995877e097681683af9d3ab767146d5d6fd050fc0bda7ab99f4232d94a1"

  @doc "Returns the canonical GTUBS test string used to verify the scanner is alive."
  def gtubs_test_string, do: @gtubs_test_string

  @doc """
  Runs every registered filter against `text` and returns the resulting
  `Despamilator.Subject` containing `:score` and `:matches`.
  """
  def scan(text) when is_binary(text) do
    subject = Subject.new(text)

    Enum.reduce(filters(), subject, fn filter, acc ->
      filter.parse(acc)
    end)
  end

  @doc "Convenience accessor — returns just the total score."
  def score(text) when is_binary(text), do: scan(text).score

  @doc "Convenience accessor — returns just the matches list."
  def matches(text) when is_binary(text), do: Subject.matches(scan(text))

  @doc "All registered filter modules. Override via `:despamilator, :filters` config."
  def filters do
    Application.get_env(:despamilator, :filters, default_filters())
  end

  defp default_filters do
    [
      Despamilator.Filter.GtubsTestFilter,
      Despamilator.Filter.HtmlTags,
      Despamilator.Filter.IPAddressURL,
      Despamilator.Filter.LongWords,
      Despamilator.Filter.MixedCase,
      Despamilator.Filter.NaughtyWords,
      Despamilator.Filter.NoVowels,
      Despamilator.Filter.NumbersAndWords,
      Despamilator.Filter.ObfuscatedURLs,
      Despamilator.Filter.Prices,
      Despamilator.Filter.ScriptTag,
      Despamilator.Filter.Shouting,
      Despamilator.Filter.SpammyTLDs,
      Despamilator.Filter.SquareBrackets,
      Despamilator.Filter.TrailingNumber,
      Despamilator.Filter.UnusualCharacters,
      Despamilator.Filter.URLs,
      Despamilator.Filter.VeryLongDomainName,
      Despamilator.Filter.WeirdPunctuation
    ]
  end
end
