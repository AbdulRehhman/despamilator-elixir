defmodule Despamilator.Filter.UnusualCharactersTest do
  use ExUnit.Case, async: true
  import Despamilator.Test.FilterHelpers

  alias Despamilator.Filter.UnusualCharacters

  test "single match" do
    assert_filter_score(UnusualCharacters, "sx", 0.05)
  end

  test "double match" do
    assert_filter_score(UnusualCharacters, "sxsx", 0.1)
  end

  test "excludes urls" do
    assert_filter_score(UnusualCharacters, "blah blah http://sxsx.com de blah", 0)
  end
end
