# lex-cognitive-lucidity

Lucid dreaming metaphor for meta-cognitive awareness in LegionIO cognitive agents. Dream states have continuously tracked lucidity levels; reality tests stabilize or destabilize lucidity; sufficiently lucid states can be steered. Completed dreams are journaled as immutable records.

## What It Does

- Begin dream states with thematic content
- Five reality test types: `text_stability`, `hand_check`, `time_check`, `memory_check`, `logic_check`
- Passing tests boost lucidity; failing tests reduce it
- False awakening: 10% chance per reality test to trigger a false-awakening event
- Steer the dream narrative when lucidity >= 0.5
- End dreams and record them in a journal with full metadata (lucidity achieved, test count, themes, insights, false awakenings, duration)
- Journal analysis: most-lucid entries and theme frequency analysis

## Usage

```ruby
# Begin a dream
result = runner.begin_dream(themes: [:problem_solving, :creativity])
dream_id = result[:dream][:id]

# Run reality tests to stabilize lucidity
runner.reality_test(dream_id: dream_id, test_type: :logic_check)
# => { success: true, test_type: :logic_check, passed: true, lucidity_delta: 0.1, lucidity: 0.6, false_awakening: false }

# Steer once lucid enough
runner.steer_dream(dream_id: dream_id, direction: 'explore the architectural pattern more deeply')

# End and journal
runner.end_dream(dream_id: dream_id)
# => { success: true, journal_entry: { lucidity_achieved: 0.6, steered: true, ... } }

# Analyze journal
runner.journal_entries(limit: 10)
runner.lucidity_status
# => { success: true, active_dreams: 0, journal_size: 1, ... }
```

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
