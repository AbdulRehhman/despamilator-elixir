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

    test "standalone گالی still scores when surrounded by spaces" do
      assert_filter_score(NaughtyWords, "تم کتا ہو", 0.8)
      assert_filter_score(NaughtyWords, "یہ سور ہے", 0.8)
    end
  end

  # Regression: the urdu-script list was matched by raw String.contains?, so a
  # گالی that is a *substring* of an innocent word produced false positives and
  # auto-reported normal Urdu chat. Matching must respect word boundaries.
  describe "urdu script — no substring false positives" do
    test "سکتا / سکتے / سکتی (can/able to) — کتا/کتے is only a substring" do
      assert_filter_score(NaughtyWords, "آپ جا سکتے ہیں", 0)
      assert_filter_score(NaughtyWords, "میں کر سکتا ہوں", 0)
      assert_filter_score(NaughtyWords, "گاڑی چل سکتی ہے", 0)
    end

    test "کتاب (book) — contains کتا" do
      assert_filter_score(NaughtyWords, "میرے پاس ایک کتاب ہے", 0)
    end

    test "سورج (sun) / سوری (sorry) — contain سور" do
      assert_filter_score(NaughtyWords, "سورج نکل آیا ہے", 0)
      assert_filter_score(NaughtyWords, "سوری مجھے دیر ہو گئی", 0)
    end

    test "موتی (pearl) — contains موت" do
      assert_filter_score(NaughtyWords, "یہ موتی بہت خوبصورت ہے", 0)
    end

    test "موت (death) is a normal word, not a گالی" do
      assert_filter_score(NaughtyWords, "اللہ موت سے بچائے", 0)
    end

    test "real reported false-positive message scores clean" do
      msg =
        "کیونکہ جب بندہ اتنی بڑی رقم انویسٹ کرتا ہے تو چیز بھی ایسی ہو گاڑی کا " <>
          "انجن ٹھیک ہو گاڑی کا گیئر ٹھیک ہو گاڑی کا سسپینشن ٹھیک ہو اے سی کام " <>
          "کرتا ہو کہ وہ چیزیں ہیں جن کو چیک کرنا چاہیے یا جن کے بارے میں پوچھنا " <>
          "چاہیے یہ سب چیزیں ٹھیک ہیں تو اپ گاڑی کو کہیں بھی لے کر جا سکتے ہیں " <>
          "ان میں سے اگر کسی بھی چیز میں کوئی پرابلم ہے تو بندہ ذہنی طور پر " <>
          "مطمئن نہیں ہوتا نہ ہی لمبے روٹ پر گاڑی کو لے کر جا سکتا ہے"

      assert_filter_score(NaughtyWords, msg, 0)
    end
  end

  test "clean text scores zero" do
    assert_filter_score(NaughtyWords, "Hello, hope you are well today.", 0)
  end
end
