defmodule Despamilator.Test.FilterHelpers do
  @moduledoc false

  import ExUnit.Assertions

  def filter_score(filter_module, text) do
    subject = filter_module.parse(Despamilator.Subject.new(text))
    Map.get(subject.match_scores, filter_module, 0.0)
  end

  def assert_filter_score(filter_module, text, expected) do
    actual = filter_score(filter_module, text)
    assert_in_delta(actual, expected, 1.0e-9, "filter #{inspect(filter_module)} on #{inspect(text)} → #{actual}, expected #{expected}")
  end
end
