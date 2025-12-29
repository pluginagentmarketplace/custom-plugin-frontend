#!/usr/bin/env python3
import json
def helper(): return {"tools": ["cypress", "playwright"], "patterns": ["page_object", "fixtures"]}
if __name__ == "__main__": print(json.dumps(helper(), indent=2))
