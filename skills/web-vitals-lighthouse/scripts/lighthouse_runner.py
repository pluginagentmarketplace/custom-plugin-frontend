#!/usr/bin/env python3
import json
def run(): return {"categories": ["performance", "accessibility", "seo", "best_practices"], "scores": [0, 100]}
if __name__ == "__main__": print(json.dumps(run(), indent=2))
