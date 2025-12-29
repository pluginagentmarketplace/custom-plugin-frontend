#!/usr/bin/env python3
import json
def optimize(): return {"types": ["images", "fonts", "scripts", "styles"], "techniques": ["minify", "compress", "cache"]}
if __name__ == "__main__": print(json.dumps(optimize(), indent=2))
