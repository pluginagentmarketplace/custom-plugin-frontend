#!/usr/bin/env python3
import json
def helper(): return {"frameworks": ["jest", "vitest"], "patterns": ["arrange_act_assert", "mocking"]}
if __name__ == "__main__": print(json.dumps(helper(), indent=2))
