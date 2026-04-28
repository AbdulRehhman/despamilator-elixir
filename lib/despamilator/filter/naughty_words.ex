defmodule Despamilator.Filter.NaughtyWords do
  use Despamilator.Filter,
    name: "Naughty Words",
    description: "Detects cheeky words"

  alias Despamilator.Subject

  # English profanity (original Ruby list)
  @words ~w(
    underage penis viagra bondage cunt fuck shit dick tits nude dicks
    shemale dildo porn cock pussy clit preteen lolita
  )

  # Roman Urdu / Hinglish gaaliyan. Word-boundary matched, plural-tolerant.
  # Common transliteration variants included.
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

  # Urdu-script gaaliyan. Detected by direct substring (Unicode word boundaries
  # don't apply cleanly to Arabic-script text and gaalis rarely false-positive).
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
    "موت", "موتنا",
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

  @impl true
  def parse(%Subject{} = subject) do
    raw = subject.text
    text = String.downcase(raw)

    subject =
      Enum.reduce(@words ++ @roman_urdu, subject, fn word, acc ->
        if Regex.match?(~r/\b#{word}s?\b/u, text),
          do: Subject.register_match(acc, __MODULE__, 0.8),
          else: acc
      end)

    Enum.reduce(@urdu_script, subject, fn word, acc ->
      if String.contains?(raw, word),
        do: Subject.register_match(acc, __MODULE__, 0.8),
        else: acc
    end)
  end
end
