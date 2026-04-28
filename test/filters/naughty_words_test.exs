defmodule Despamilator.Filter.NaughtyWordsTest do
  use ExUnit.Case, async: true
  import Despamilator.Test.FilterHelpers

  alias Despamilator.Filter.NaughtyWords

  describe "english" do
    test "single naughty word" do
      assert_filter_score(NaughtyWords, "bondage", 0.8)
    end

    test "multiple naughty words" do
      assert_filter_score(NaughtyWords, "viagra penis", 1.6)
    end
  end

  describe "roman urdu" do
    test "gandu" do
      assert_filter_score(NaughtyWords, "tum bare gandu ho", 0.8)
    end

    test "chutiya — plural-tolerant" do
      assert_filter_score(NaughtyWords, "chutiya log", 0.8)
    end

    test "bhenchod" do
      assert_filter_score(NaughtyWords, "fuck off bhenchod", 1.6)
    end

    test "bhadwa" do
      assert_filter_score(NaughtyWords, "tu ek bara bhadwa hai", 0.8)
    end

    test "tharki" do
      assert_filter_score(NaughtyWords, "yeh ladka tharki hai", 0.8)
    end

    test "gadha" do
      assert_filter_score(NaughtyWords, "kitna gadha hai", 0.8)
    end

    test "stacks multiple gaaliyan" do
      assert_filter_score(NaughtyWords, "saala kameena randwa", 2.4)
    end
  end

  describe "urdu script" do
    test "گاندو" do
      assert_filter_score(NaughtyWords, "یہ بندہ گاندو ہے", 0.8)
    end

    test "بھڑوا" do
      assert_filter_score(NaughtyWords, "وہ ایک بھڑوا ہے", 0.8)
    end

    test "گدھا" do
      assert_filter_score(NaughtyWords, "گدھا کہیں کا", 0.8)
    end

    test "چنال" do
      assert_filter_score(NaughtyWords, "چنال", 0.8)
    end
  end

  test "clean text scores zero" do
    assert_filter_score(NaughtyWords, "Hello, hope you are well today.", 0)
  end
end
