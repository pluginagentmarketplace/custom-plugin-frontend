#!/usr/bin/env python3
import json
def check(): return {"protocols": ["http", "https", "dns"], "concepts": ["request", "response", "caching"]}
if __name__ == "__main__": print(json.dumps(check(), indent=2))
