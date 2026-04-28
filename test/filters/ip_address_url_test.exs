defmodule Despamilator.Filter.IPAddressURLTest do
  use ExUnit.Case, async: true
  import Despamilator.Test.FilterHelpers

  alias Despamilator.Filter.IPAddressURL

  test "single ip url" do
    assert_filter_score(IPAddressURL, "http://12.34.56.78/", 0.5)
  end

  test "still scores once for multiple ip urls" do
    assert_filter_score(IPAddressURL, "http://12.34.56.78/ http://98.76.54.32/", 0.5)
  end
end
