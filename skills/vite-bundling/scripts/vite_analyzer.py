#!/usr/bin/env python3
import json
def analyze(): return {"features": ["esm", "hmr", "rollup"], "config": ["plugins", "aliases", "env"]}
if __name__ == "__main__": print(json.dumps(analyze(), indent=2))
