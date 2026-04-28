defmodule Despamilator.Subject.TextTest do
  use ExUnit.Case, async: true

  alias Despamilator.Subject.Text

  test "strips uris" do
    assert Text.without_uris(
             "blah https://www.google.com de.http://yahoo.com blah http://www.dcyder.com?x={abc} blah"
           ) == "blah de.blah blah"
  end

  test "splits into words" do
    assert Text.words("hello   there you-rule") == ~w(hello there you rule)
  end

  test "counts regex matches" do
    assert Text.count("yXyXy", ~r/X/) == 2
  end

  test "remove_and_count returns count and stripped text" do
    assert Text.remove_and_count("yXyXy", ~r/X/) == {2, "yyy"}
  end
end
