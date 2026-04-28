defmodule Despamilator.Subject.Text do
  @moduledoc """
  String helpers used by filters. Elixir is immutable so `remove_and_count/2`
  returns `{count, new_text}` instead of mutating in place like Ruby's bang form.
  """

  @uri_regex ~r/\b(?:https?|mailto|ftp):.+?(\s|$)/i

  @doc "Strips http/https/mailto/ftp URIs (Ruby `without_uris`)."
  def without_uris(text) when is_binary(text) do
    Regex.replace(@uri_regex, text, "")
  end

  @doc "Splits on `\\W+`, dropping empty fragments."
  def words(text) when is_binary(text) do
    text
    |> String.split(~r/\W+/u, trim: true)
  end

  @doc "Counts non-overlapping matches of `pattern` in `text`."
  def count(text, %Regex{} = pattern) when is_binary(text) do
    Regex.scan(pattern, text) |> length()
  end

  @doc """
  Removes every match of `pattern` and returns `{count, new_text}`.
  Mirrors Ruby's `remove_and_count!` semantics but immutably.
  """
  def remove_and_count(text, %Regex{} = pattern) when is_binary(text) do
    count = count(text, pattern)
    {count, Regex.replace(pattern, text, "")}
  end
end
