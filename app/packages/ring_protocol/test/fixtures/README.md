# FR02.023 captures

These JSONL excerpts are from the Mac probe. The first four rows of each file
were omitted because they were Device Information reads, separate from the
notification stream. They included the physical ring's serial and System ID.
The remaining rows retain the captured timestamps, bytes, and probe duplicates.

- `rc_hr2.jsonl` covers auth, telemetry, starting HR mode, and live readings.
- `rc_hist_drain.jsonl` includes a coalesced reply, thermal page, and telemetry.
- `rc_hist_drain4.jsonl` includes both history streams, their terminal pages, and
  matching values from the Mac decoder's epoch and thermal CSVs.
- `rc_modes_ppg.jsonl` contains one captured response per PPG format.
