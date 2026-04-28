defmodule Despamilator.SubjectTest do
  use ExUnit.Case, async: true

  alias Despamilator.Subject

  test "default score is 0.0" do
    assert Subject.new("blah").score == 0.0
  end

  test "text accessor" do
    assert Subject.text(Subject.new("blah blah")) == "blah blah"
  end

  test "aggregates per-filter scores and sorts matches" do
    s =
      Subject.new("x")
      |> Subject.register_match(:filter_a, 1)
      |> Subject.register_match(:filter_b, 2)
      |> Subject.register_match(:filter_a, 3)

    assert s.score == 6.0

    assert Subject.matches(s) == [
             %{filter: :filter_a, score: 4.0},
             %{filter: :filter_b, score: 2.0}
           ]
  end
end
