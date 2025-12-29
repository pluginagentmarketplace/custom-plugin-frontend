#!/usr/bin/env python3
import json
def patterns(): return {"types": ["generics", "utility", "mapped"], "patterns": ["factory", "singleton", "strategy"]}
if __name__ == "__main__": print(json.dumps(patterns(), indent=2))
