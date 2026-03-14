# lex-cognitive-lucidity

**Level 3 Leaf Documentation**
- **Parent**: `/Users/miverso2/rubymine/legion/extensions-agentic/CLAUDE.md`

## Purpose

Lucid dreaming metaphor for meta-cognitive awareness. Models dream states with continuously tracked lucidity levels. Reality tests (text_stability, hand_check, time_check, memory_check, logic_check) either boost or reduce lucidity depending on their result. When lucidity is sufficient (>= 0.5), the dream can be steered (directed). False awakenings are detected probabilistically, and completed dreams are recorded in an immutable journal with full metadata.

## Gem Info

- **Gem name**: `lex-cognitive-lucidity`
- **Module**: `Legion::Extensions::CognitiveLucidity`
- **Version**: `0.1.0`
- **Ruby**: `>= 3.4`
- **License**: MIT

## File Structure

```
lib/legion/extensions/cognitive_lucidity/
  version.rb
  client.rb
  helpers/
    constants.rb
    dream_state.rb
    journal_entry.rb
    lucidity_engine.rb
  runners/
    cognitive_lucidity.rb
```

## Key Constants

| Constant | Value | Purpose |
|---|---|---|
| `MAX_JOURNAL_ENTRIES` | `500` | Journal ring buffer capacity |
| `MAX_DREAMS` | `100` | Maximum simultaneous active dreams |
| `LUCIDITY_LEVELS` | range hash | From `:somnambulant` to `:hyper_lucid` |
| `REALITY_TEST_TYPES` | `%i[text_stability hand_check time_check memory_check logic_check]` | Valid test types |
| `LUCIDITY_DECAY` | `0.05` | Lucidity lost per tick without stimulation |
| `FALSE_AWAKENING_CHANCE` | `0.1` | Base probability of false awakening per reality test |
| `DREAM_QUALITY_LABELS` | range hash | From `:incoherent` to `:vivid` |

## Helpers

### `Helpers::DreamState`
Active dream session. Has `id`, `lucidity`, `themes` (array), `insights` (array), `false_awakening_count`, and `steered` flag.

- `reality_test!(test_type)` — performs a reality check; returns test result hash including lucidity delta. May trigger false awakening (raises `false_awakening_count`).
- `steer!(direction)` — sets a narrative direction; requires lucidity >= 0.5, returns error hash otherwise
- `destabilize!` — applies `LUCIDITY_DECAY` to lucidity
- `stabilize!(amount)` — increases lucidity
- `end!` — marks dream inactive
- `lucidity_label`

### `Helpers::JournalEntry`
Immutable (frozen) record of a completed dream. Captures: `lucidity_achieved`, `reality_tests_performed`, `themes`, `insights`, `false_awakening_count`, `duration_seconds`, `steered`.

- Frozen at creation: no mutation after recording
- `to_h` for serialization

### `Helpers::LucidityEngine`
Manages active dreams and the journal.

- `begin_dream(themes:)` → new `DreamState`
- `reality_test(dream_id:, test_type:)` → test result hash
- `steer_dream(dream_id:, direction:)` → steer result hash
- `end_dream(dream_id:)` → creates `JournalEntry`, returns entry hash
- `all_dreams` → all active dream states
- `active_dream` → most recently begun active dream
- `lucidity_report` → aggregate stats
- `most_lucid_dreams(limit:)` → journal entries sorted by lucidity
- `theme_analysis` → hash of theme frequencies across all journal entries

## Runners

Module: `Runners::CognitiveLucidity`

| Runner Method | Description |
|---|---|
| `begin_dream(themes:)` | Start a new dream state |
| `reality_test(dream_id:, test_type:)` | Perform a reality check |
| `steer_dream(dream_id:, direction:)` | Steer the dream narrative |
| `end_dream(dream_id:)` | Complete and journal the dream |
| `lucidity_status` | Aggregate lucidity report |
| `journal_entries(limit:)` | Recent journal entries |

All runners return `{success: true/false, ...}` hashes.

## Integration Points

- Directly parallels `lex-dream`'s dream cycle: lucidity can be attached to lex-dream association walks
- `reality_test` fits `lex-tick` `identity_entropy_check` phase (grounding checks)
- High lucidity states can boost `lex-emotion` arousal positively
- False awakening count over a threshold can trigger `lex-conflict` internal conflict
- Journal themes feed into `lex-memory` semantic trace creation

## Development Notes

- `Client` instantiates `@lucidity_engine = Helpers::LucidityEngine.new`
- `JournalEntry` is frozen: records are write-once for integrity
- `reality_test!` applies a lucidity delta depending on test type and result; passing tests increase lucidity, failing tests decrease it
- False awakening uses `rand < FALSE_AWAKENING_CHANCE` check per test; it resets some state but does not end the dream
- `steer!` fails silently with `{success: false, error: :insufficient_lucidity}` when lucidity < 0.5
