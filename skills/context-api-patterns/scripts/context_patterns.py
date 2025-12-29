#!/usr/bin/env python3
import json
def patterns(): return {"simple": "single_context", "compound": "nested_providers", "optimized": "memo_split"}
if __name__ == "__main__": print(json.dumps(patterns(), indent=2))
