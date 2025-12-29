#!/usr/bin/env python3
import json
def helper(): return {"panels": ["elements", "console", "network", "performance"], "features": ["breakpoints", "profiling"]}
if __name__ == "__main__": print(json.dumps(helper(), indent=2))
