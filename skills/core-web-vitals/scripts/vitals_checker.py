#!/usr/bin/env python3
import json
def check(): return {"metrics": ["lcp", "fid", "cls"], "thresholds": {"lcp": 2500, "fid": 100, "cls": 0.1}}
if __name__ == "__main__": print(json.dumps(check(), indent=2))
