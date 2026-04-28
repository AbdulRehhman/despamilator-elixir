defmodule Despamilator.Filter.URLsTest do
  use ExUnit.Case, async: true
  import Despamilator.Test.FilterHelpers

  alias Despamilator.Filter.URLs

  test "single url" do
    assert_filter_score(URLs, "http://www.blah.com", 0.4)
  end

  test "two urls" do
    assert_filter_score(URLs, "http://www.blah.com http://www.poop.com", 0.8)
  end

  test "caps at 2 urls" do
    assert_filter_score(
      URLs,
      "http://www.blah.com http://www.poop.com http://www.dcyder.com",
      0.8
    )
  end
end
