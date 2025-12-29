#!/usr/bin/env python3
import json
def helper(): return {"commands": ["commit", "branch", "merge", "rebase"], "workflows": ["gitflow", "trunk"]}
if __name__ == "__main__": print(json.dumps(helper(), indent=2))
