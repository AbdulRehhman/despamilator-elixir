defmodule Despamilator.Filter.NaughtyWords do
  use Despamilator.Filter,
    name: "Naughty Words",
    description: "Detects cheeky words"

  alias Despamilator.Subject

  # English profanity (original Ruby list)
  @english ~w(
    underage penis viagra bondage cunt fuck shit dick tits nude dicks
    shemale dildo porn cock pussy clit preteen lolita
  )

  # Roman Urdu / Hinglish gaaliyan. Plural-tolerant. Common transliteration
  # variants included.
  @roman_urdu ~w(
    gandu gaandu gand gaand gaandfat gandphat gandmasti
    chutiya chutya chootia chutiye chutiyon chutiyapa chutiyapanti
    madarchod madarchood maderchod maderchood motherchod
    behenchod behnchod bhenchod bhanchod bhanchood bhainchod bc
    bhosdike bhosdika bhosri bhosrike bhosdiwala bhosdiwale
    harami haramzada haramzaada haramkhor harami haraamipan
    kameena kamina kameene kaminey kameenapan
    kutta kutti kuttay kuttey kuttiya kuttiyon
    randi randwa randwe randiyan randiyon
    lund lauda laude
    choot chodu chodun chudai chudwa chudwana chudwaya chudai
    saala saale saali saalon kanjar kanjri kanjron
    haijra hijra
    bhadwa bhadwe bhadwi bhadwapan
    gashti gashtiyan
    moot mootna mooth
    tatti tattey tatte
    dalla dalle dalli
    tharki tharak tharkiya
    phudi phuddi fudi fuddi
    ghasti ghaseeti ghasiti
    chootad chutad chutar
    gadha gadhe gadhi
    suar suwar suvar
    ullu ulloo
    bewakoof bewaqoof
  )

  # Urdu-script gaaliyan. Matched on word boundaries (see @urdu_regex) — NOT raw
  # substrings — because short gaalis are substrings of innocent words:
  #   کتا (dog) ⊂ سکتا/سکتے (can), کتاب (book); سور (pig) ⊂ سورج (sun)/سوری (sorry);
  #   موت ⊂ موتی (pearl). Substring matching auto-reported normal Urdu chat.
  # Normal words are kept out of the list entirely (e.g. موت = "death").
  @urdu_script [
    "گاندو", "گانڈ", "چوتیا", "چوتیے", "چوتیاپا",
    "مادرچود", "مادرچوود", "بہنچود", "بھینچود", "بہن چود",
    "بھوسڑی", "بھوسڑیکے", "بھوسڑی والا",
    "حرامی", "حرامزادہ", "حرام خور", "حرامیپن",
    "کمینہ", "کمینے", "کمینی", "کمینگی",
    "کتا", "کتی", "کتیا", "کتے", "کتوں",
    "رنڈی", "رنڈیاں", "رنڈوا", "رنڈوے",
    "لنڈ", "لوڑا", "لنڈے", "لاوڑے", "لنڈوں",
    "چود", "چودو", "چدائی", "چدوا", "چدوانا",
    "سالا", "سالی", "سالے",
    "کنجر", "کنجری", "کنجرا",
    "بھڑوا", "بھڑوے", "بھڑوی",
    "چنال", "چنالی",
    "نکما", "نکمے", "نکمی",
    "گشتی",
    "موتنا",
    "ٹٹی", "ٹٹے",
    "دلا", "دلے",
    "تھرکی", "تھرک",
    "بے شرم", "بےشرم",
    "جھانٹ", "جھنٹ", "جھنٹو",
    "پھدی", "پھڈی",
    "گھسیٹی",
    "نجائز", "ناجائز",
    "چوتڑ", "چھتڑ",
    "گدھا", "گدھے", "گدھی",
    "سؤر", "سور",
    "الو", "اُلو",
    "پاگل", "پگلا", "پگلی",
    "بے وقوف", "بیوقوف"
  ]

  # Both regexes are built once at compile time as a single alternation, so a
  # scan is one pass over the text rather than ~140 separate matches.
  #
  #   * @latin_regex — ASCII word boundaries (`\b`), case-insensitive,
  #     plural-tolerant (`s?`). Covers English + Roman-Urdu.
  #   * @urdu_regex  — Unicode-letter lookarounds `(?<!\p{L}) … (?!\p{L})`,
  #     so a gaali only matches as a whole word, never inside a larger Urdu word.
  @latin_regex (
                 alt = (@english ++ @roman_urdu) |> Enum.map(&Regex.escape/1) |> Enum.join("|")
                 Regex.compile!("\\b(?:#{alt})s?\\b", "iu")
               )

  @urdu_regex (
                alt = @urdu_script |> Enum.map(&Regex.escape/1) |> Enum.join("|")
                Regex.compile!("(?<!\\p{L})(?:#{alt})(?!\\p{L})", "u")
              )

  @impl true
  def parse(%Subject{} = subject) do
    text = subject.text

    count =
      distinct_match_count(@latin_regex, text) +
        distinct_match_count(@urdu_regex, text)

    if count > 0,
      do: Subject.register_match(subject, __MODULE__, 0.8 * count),
      else: subject
  end

  # Number of distinct gaaliyan present (case-folded), so the score scales with
  # how many different naughty words appear — matching the original behaviour of
  # registering 0.8 per matched list entry.
  defp distinct_match_count(regex, text) do
    regex
    |> Regex.scan(text)
    |> Enum.map(fn [match | _] -> String.downcase(match) end)
    |> Enum.uniq()
    |> length()
  end
end
