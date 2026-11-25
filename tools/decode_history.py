#!/usr/bin/env python3
"""Decode RingConn history traces (0x4c epochs, 0x47 thermal/activity blocks) to CSV.

0x4c (23 B, 2.5-min epoch, end-timestamped):
  [0..3] cursor (s since 1577793600) | [4] HR bpm (4=off-finger) | [5] HRV RMSSD ms
  [6] PPG quality 0..10 | [7] respiratory rate x10 brpm (0=invalid)
  [8] SpO2 % (18=not scheduled, 17=failed) | [9] activity MET x10 (10=rest)
  [10..14] 5x 30 s ambient light | [15..22] 5x u12be motion energy + 4-bit flags
  (bit2 of flags = SpO2 slot scheduled, bit1 = high motion)

0x47 (47 B, 15-min block): [0..3] cursor | [4]=0x02 subtype | [5]>>1 battery % |
  [5]&1 activity flag | [6..7] be16 steps | [8] active-time/5 s |
  [9..46] 4 pad bits + 15x (u10 ChA outer, u10 ChB inner) at 0.05 degC
"""
import sys, json, csv, datetime

EPOCH = 1577793600

def valid(b):
    x = 0
    for c in b[:-1]:
        x ^= c
    return b[-1] == x

def unpack_motion(r):
    bits = int.from_bytes(r[15:23], "big")
    return [(bits >> (12 * (4 - i))) & 0xFFF for i in range(5)], bits & 0xF

def unpack_temps(b):
    bits = int.from_bytes(b[9:47], "big")
    vals = [(bits >> (304 - 20 * (i + 1))) & 0xFFFFF for i in range(15)]
    return [v >> 10 for v in vals], [v & 0x3FF for v in vals]

def main(path, outdir):
    seen = set()
    with open(f"{outdir}/epochs.csv", "w", newline="") as fe, open(f"{outdir}/thermal.csv", "w", newline="") as ft:
        we, wt = csv.writer(fe), csv.writer(ft)
        we.writerow(["utc", "cursor", "hr_bpm", "hrv_ms", "ppg_quality", "resp_rate_brpm",
                     "spo2_pct", "spo2_state", "met_x10", "ambient_30s", "motion_30s", "flags"])
        wt.writerow(["utc", "cursor", "battery_pct", "activity_flag", "steps", "active_5s"] + [f"tA{i}_c" for i in range(15)] + [f"tB{i}_c" for i in range(15)])
        for line in open(path):
            r = json.loads(line)
            if r.get("dir") != "rx" or not r.get("hex"):
                continue
            b = bytes.fromhex(r["hex"])
            if len(b) < 8 or not valid(b) or b[0] not in (0x4C, 0x47) or r["hex"] in seen:
                continue
            seen.add(r["hex"])
            recsz = 23 if b[0] == 0x4C else 47
            n = (len(b) - 4) // recsz
            for i in range(n):
                rec = b[3 + recsz * i: 3 + recsz * (i + 1)]
                if len(rec) != recsz:
                    continue
                cur = int.from_bytes(rec[:4], "big")
                utc = datetime.datetime.utcfromtimestamp(EPOCH + cur).isoformat()
                if b[0] == 0x4C:
                    mot, flags = unpack_motion(rec)
                    sph = {4: "scheduled", 0: "not_scheduled"}.get(flags & 0x6, "other")
                    spo2 = rec[8]
                    if spo2 == 18: spo2, sph = "", "not_scheduled"
                    elif spo2 == 17: spo2, sph = "", "failed"
                    we.writerow([utc, cur, rec[4] if rec[4] >= 30 else "", rec[5], rec[6], rec[7] / 10.0,
                                 spo2, sph, rec[9] / 10.0, "|".join(map(str, rec[10:15])),
                                 "|".join(map(str, mot)), flags])
                else:
                    A, B = unpack_temps(rec)
                    wt.writerow([utc, cur, rec[5] >> 1, rec[5] & 1,
                                 int.from_bytes(rec[6:8], "big"), rec[8]] +
                                [round(x / 20.0, 2) for x in A] + [round(x / 20.0, 2) for x in B])
    print("done")

if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2] if len(sys.argv) > 2 else ".")
