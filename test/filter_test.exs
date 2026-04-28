defmodule Despamilator.FilterTest do
  use ExUnit.Case, async: true

  alias Despamilator.Filter.Prices

  test "name and description are exposed" do
    assert Prices.name() == "Prices"
    assert Prices.description() == "Detects prices in text."
  end
end
