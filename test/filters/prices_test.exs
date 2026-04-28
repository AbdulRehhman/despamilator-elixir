defmodule Despamilator.Filter.PricesTest do
  use ExUnit.Case, async: true
  import Despamilator.Test.FilterHelpers

  alias Despamilator.Filter.Prices

  test "single price" do
    assert_filter_score(Prices, "it is $45 DOLLAAA", 0.075)
  end

  test "multiple prices" do
    assert_filter_score(Prices, "it is between $20 and $ 25", 0.15)
  end
end
