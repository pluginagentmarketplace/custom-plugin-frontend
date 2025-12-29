#!/usr/bin/env python3
import json
def helper(): return {"api": ["create", "useStore"], "middleware": ["devtools", "persist", "immer"]}
if __name__ == "__main__": print(json.dumps(helper(), indent=2))
