#!/usr/bin/env python3
import json
def optimize(): return {"formats": ["webp", "avif", "svg"], "techniques": ["lazy_load", "responsive", "cdn"]}
if __name__ == "__main__": print(json.dumps(optimize(), indent=2))
