# NaughtyWords — Urdu-script word-boundary fix (v2.1.5)

## Summary

`Despamilator.Filter.NaughtyWords` was auto-reporting ordinary Urdu chat
messages. The Urdu-script gaali list was matched with a raw `String.contains?`
(substring) check, so a gaali that happens to be a **substring** of an innocent
word produced a false positive. Matching is now **word-boundary aware**, and
genuinely normal words were removed from the list.

A single message scoring `>= 0.7` (the `:pakwheels_chat` spam threshold) is
marked `reported_by_system`, so every false positive became an admin moderation
report.

## Root cause

The filter has three lists: English (`@english`), Roman-Urdu (`@roman_urdu`) and
Urdu-script (`@urdu_script`). English and Roman-Urdu already matched with word
boundaries (`\b…\b`). Only the **Urdu-script** branch used:

```elixir
if String.contains?(raw, word), do: register 0.8
```

Arabic-script text has no `\b` semantics, so the author used a bare substring
test, assuming "gaalis rarely false-positive". They do — constantly — because
short gaalis are substrings of extremely common words:

| Innocent word | Meaning | Contains gaali | Score (before) |
|---------------|---------|----------------|----------------|
| `سکتا` / `سکتے` / `سکتی` | can / able to | `کتا` / `کتے` (dog) | 0.8 each |
| `کتاب` | book | `کتا` (dog) | 0.8 |
| `سورج` | sun | `سور` (pig) | 0.8 |
| `سوری` | sorry | `سور` (pig) | 0.8 |
| `موتی` | pearl | `موت` | 0.8 |
| `موت` | death | (listed as a gaali) | 0.8 |

`سکتا` / `سکتے` ("can") is one of the most frequent words in Urdu, so any message
about what a car *can* do tripped two matches (`کتا` + `کتے`) → score `1.6` →
auto-reported. Messages that phrased things differently (e.g. `ہوتا/ہوتی`) were
untouched, which is why **only some** Urdu messages were reported, not all.

## The change

`lib/despamilator/filter/naughty_words.ex`:

1. **Word-boundary matching for Urdu script.** Replaced the per-word
   `String.contains?` with a Unicode lookaround so a gaali only matches as a
   whole word, never inside a larger Urdu word:

   ```elixir
   (?<!\p{L}) (?:gaali1|gaali2|…) (?!\p{L})
   ```

   `کتا` inside `سکتا`/`کتاب` is now rejected (flanked by Urdu letters), while a
   standalone `کتا` still matches.

2. **Single precompiled alternation per branch.** Both the Latin
   (English + Roman-Urdu) and the Urdu-script lists are compiled **once at
   compile time** into one alternation regex each, instead of building and
   running ~140 individual regexes/`contains?` per message. Scan is one pass.

3. **Removed normal words from the list.** `موت` ("death") was dropped — it is a
   normal word, not a gaali, and no boundary rule can save a word that is
   genuinely innocent on its own. (`موتنا`, the vulgar verb, is kept.)

Scoring is unchanged: still `0.8 × (number of distinct gaaliyan present)`.

## Performance

Measured on the real reported message (Urdu-script branch), µs per message:

| Approach | µs/msg | vs old |
|----------|-------:|-------:|
| `String.contains?` (old, buggy) | 31.8 | baseline |
| Per-word regex, compiled at runtime | 208 | 6.5× |
| Per-word regex, precompiled | 133 | 4.2× |
| **Combined alternation regex, precompiled (shipped)** | **35.0** | **+10% (noise)** |
| Tokenize + MapSet (whole-word) | 57.2 | 1.8× |

Net effect: **no meaningful performance cost.** The shipped approach (one
precompiled alternation regex) costs about the same as the old buggy substring
scan (~+3 µs/message, sub-millisecond in absolute terms). The naive "one regex
per word" alternative would have been 4–6× slower and was deliberately avoided.
Folding the Roman-Urdu branch (previously ~50 regexes compiled **at runtime per
message**) into a precompiled regex actually removes a pre-existing hidden cost.

## What is affected

- **`Despamilator.Filter.NaughtyWords` only.** No other filter changed.
- **Behaviour change (intended):** Urdu-script gaalis now require word
  boundaries. False positives on `سکتا/سکتے/سکتی`, `کتاب`, `سورج`, `سوری`,
  `موتی` and similar are gone. `موت` (death) no longer matches at all.
- **True positives preserved:** standalone Urdu-script gaalis still score `0.8`
  (e.g. `تم کتا ہو`, `یہ سور ہے`, `گاندو`, `بھڑوا`, `گدھا`, `چنال`). All 221
  existing tests pass; 14 new regression tests added in
  `test/filters/naughty_words_test.exs`.
- **Edge case:** distinct-match counting is by case-folded surface form. A
  message containing both the singular and plural of the *same* English/Roman
  word (e.g. `viagra viagras`) now counts as 2 rather than 1. Harmless — it only
  raises the score for clearly spammy text. No real-world or test impact.

## Consumers / rollout

`pakwheels_chat` depends on the hex package:

```elixir
# pakwheels_chat/mix.exs
{:despamilator_elixir, "~> 2.1"}   # currently locked to 2.1.4
```

To roll out:

1. Version bumped to **2.1.5** (`mix.exs`).
2. Publish the fork to hex (`mix hex.publish`), **or** point the consumer at the
   git/path source if not publishing.
3. In `pakwheels_chat`: `mix deps.update despamilator_elixir` (picks up 2.1.5
   under `~> 2.1`), rebuild the release/Docker image, redeploy.

No config or schema changes. `:pakwheels_chat, :spam_threshold` (0.7) and the
configured filter list are untouched.
