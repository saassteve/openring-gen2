#!/usr/bin/env python3
"""Decode RingConn PPG golden traces (JSONL from ringconn.swift --trace).

0x13 = raw PPG 25 Hz: [2]=seq, 25x(green BE u16, red BE s16, IR BE s16) at [6..155], [157..158]=BE16 counter
0x12 = dense PPG ~100 Hz: [1..2]=BE16 seq, 10x4 channels of 24-bit BE at [6..125], ch3 = s20, [130..132]=counter
Duplicates (macOS repeats notifications) are dropped; XOR-validated only.
"""
import sys, json, csv

def valid(b):
    x = 0
    for c in b[:-1]:
        x ^= c
    return b[-1] == x

def main(path, outdir):
    seen = set()
    with open(f"{outdir}/ppg13.csv", "w", newline="") as f13, open(f"{outdir}/ppg12.csv", "w", newline="") as f12:
        w13 = csv.writer(f13); w12 = csv.writer(f12)
        w13.writerow(["t_ms", "seq", "counter", "sample", "green", "red", "ir"])
        w12.writerow(["t_ms", "seq", "counter", "sample"] + [f"ch{i}" for i in range(4)])
        n13 = n12 = 0
        for line in open(path):
            r = json.loads(line)
            if r.get("dir") != "rx" or not r.get("hex"):
                continue
            b = bytes.fromhex(r["hex"])
            if not valid(b) or b[0] not in (0x13, 0x12) or r["hex"] in seen:
                continue
            seen.add(r["hex"])
            t = r["t_ms"]
            if b[0] == 0x13 and len(b) == 160:
                seq = b[2]; ctr = int.from_bytes(b[157:159], "big")
                for i in range(25):
                    o = 6 + 6 * i
                    w13.writerow([t, seq, ctr, i,
                                  int.from_bytes(b[o:o+2], "big"),
                                  int.from_bytes(b[o+2:o+4], "big", signed=True),
                                  int.from_bytes(b[o+4:o+6], "big", signed=True)])
                n13 += 1
            elif b[0] == 0x12 and len(b) == 135:
                seq = int.from_bytes(b[1:3], "big"); ctr = int.from_bytes(b[130:133], "big")
                ch = [[int.from_bytes(b[6+3*(4*i+c):9+3*(4*i+c)], "big", signed=(c == 3)) for i in range(10)] for c in range(4)]
                for i in range(10):
                    w12.writerow([t, seq, ctr, i] + [ch[c][i] for c in range(4)])
                n12 += 1
    print(f"0x13 frames={n13} 0x12 frames={n12}")

if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2] if len(sys.argv) > 2 else ".")
