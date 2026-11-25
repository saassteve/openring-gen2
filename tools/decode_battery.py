#!/usr/bin/env python3
"""Extract battery telemetry from a ringconn trace (descriptor 0x87 / 0x10 frames).

Fields (FR02.023): [1] battery %, [2] wear/mode state, [6..9] two NTC temps x0.1C,
[14..15] battery mV BE, [16] flags. Emits CSV plus a drain summary (%/h, mV/h).
"""
import sys, json, csv, datetime

def main(path, out):
    rows = []
    seen = set()
    for line in open(path):
        r = json.loads(line)
        if r.get("dir") != "rx" or not r.get("hex"):
            continue
        b = bytes.fromhex(r["hex"])
        if len(b) != 20 or b[0] not in (0x10, 0x87):
            continue
        key = (r["t_ms"] // 1500, r["hex"])
        if key in seen:
            continue
        seen.add(key)
        rows.append((r["t_ms"], b))
    with open(out, "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["t_ms", "battery_pct", "state", "temp1_c", "temp2_c", "voltage_mv", "flags"])
        for t, b in rows:
            w.writerow([t, b[1], b[2], int.from_bytes(b[6:8], "big") / 10, int.from_bytes(b[8:10], "big") / 10,
                        int.from_bytes(b[14:16], "big"), b[16]])
    if len(rows) > 1:
        dt = (rows[-1][0] - rows[0][0]) / 3.6e6
        db = rows[-1][1][1] - rows[0][1][1]
        dv = int.from_bytes(rows[-1][1][14:16], "big") - int.from_bytes(rows[0][1][14:16], "big")
        print(f"samples={len(rows)} span={dt:.2f}h battery {db:+d}% ({db/dt if dt else 0:+.3f} %/h) "
              f"voltage {dv:+d}mV ({dv/dt if dt else 0:+.2f} mV/h)")

if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
