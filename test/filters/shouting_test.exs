defmodule Despamilator.Filter.ShoutingTest do
  use ExUnit.Case, async: true
  import Despamilator.Test.FilterHelpers

  alias Despamilator.Filter.Shouting

  test "50% shouting" do
    assert_filter_score(Shouting, "this lil string is 50 PERCENT SHOUTING", 0.25)
  end

  test "100% shouting" do
    assert_filter_score(Shouting, "HELLO THERE!! THIS IS SHOUTING!!", 0.5)
  end

  test "strips html before scoring" do
    assert_filter_score(
      Shouting,
      "<H1>this is a flipping html tag whose contents is very long</h1>",
      0
    )
  end

  test "ignores short strings" do
    assert_filter_score(Shouting, "ABCD EFG HIJKLM NOP", 0)
  end

  test "lowercase string scores zero" do
    assert_filter_score(Shouting, "this is a lowercased string", 0)
  end

  test "mixed case capital letters scores zero" do
    assert_filter_score(Shouting, "This is a String with Capital Letters", 0)
  end
end
