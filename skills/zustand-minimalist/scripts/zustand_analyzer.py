#!/usr/bin/env python3
import json
def analyze(): return {"features": ["minimal_api", "no_boilerplate", "devtools"], "patterns": ["slices", "persist"]}
if __name__ == "__main__": print(json.dumps(analyze(), indent=2))
