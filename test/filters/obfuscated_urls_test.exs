defmodule Despamilator.Filter.ObfuscatedURLsTest do
  use ExUnit.Case, async: true
  import Despamilator.Test.FilterHelpers

  alias Despamilator.Filter.ObfuscatedURLs

  test "space-separated characters" do
    assert_filter_score(ObfuscatedURLs, "b a l l s . c o m", 0.4)
  end

  test "multiple obfuscations" do
    assert_filter_score(
      ObfuscatedURLs,
      "www blah com b a l l s . c o m also n u t t s . c o m",
      1.2
    )
  end
end
