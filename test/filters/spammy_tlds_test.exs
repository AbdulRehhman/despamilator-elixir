defmodule Despamilator.Filter.SpammyTLDsTest do
  use ExUnit.Case, async: true
  import Despamilator.Test.FilterHelpers

  alias Despamilator.Filter.SpammyTLDs

  test "single biz" do
    assert_filter_score(SpammyTLDs, "http://www.blahdee.biz", 0.05)
  end

  test "two spammy tlds" do
    assert_filter_score(SpammyTLDs, "http://www.blahdee.info http://www.poopy.biz", 0.1)
  end
end
