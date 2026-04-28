defmodule Despamilator.Filter.ScriptTagTest do
  use ExUnit.Case, async: true
  import Despamilator.Test.FilterHelpers

  alias Despamilator.Filter.ScriptTag

  test "single match" do
    assert_filter_score(ScriptTag, "<script>", 1)
  end

  test "registers once even with multiple tags" do
    assert_filter_score(ScriptTag, "<script></script> <script></script>", 1)
  end

  for tag <- [~s(<script type="whatever">), "<script></script>", "</script>", "<script>", "<script\n>"] do
    for cased <- [String.upcase(tag), String.downcase(tag)] do
      @cased cased
      test "detects #{inspect(cased)}" do
        assert_filter_score(ScriptTag, @cased, 1)
      end
    end
  end
end
