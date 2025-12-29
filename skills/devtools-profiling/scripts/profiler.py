#!/usr/bin/env python3
import json
def profile(): return {"metrics": ["cpu", "memory", "network"], "tools": ["lighthouse", "performance_tab"]}
if __name__ == "__main__": print(json.dumps(profile(), indent=2))
