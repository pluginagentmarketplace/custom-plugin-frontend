#!/usr/bin/env python3
import json
def analyze(): return {"concepts": ["store", "actions", "reducers"], "patterns": ["flux", "single_source"]}
if __name__ == "__main__": print(json.dumps(analyze(), indent=2))
