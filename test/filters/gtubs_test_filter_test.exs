defmodule Despamilator.Filter.GtubsTestFilterTest do
  use ExUnit.Case, async: true
  import Despamilator.Test.FilterHelpers

  alias Despamilator.Filter.GtubsTestFilter

  test "scores 100 on the magic string" do
    assert_filter_score(GtubsTestFilter, Despamilator.gtubs_test_string(), 100)
  end
end
