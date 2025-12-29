#!/usr/bin/env python3
import json
def analyze(): return {"concepts": ["closures", "promises", "modules"], "es6": ["arrow", "destructuring", "spread"]}
if __name__ == "__main__": print(json.dumps(analyze(), indent=2))
