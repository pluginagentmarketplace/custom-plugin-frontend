#!/usr/bin/env python3
import json
def analyze(): return {"concepts": ["loaders", "plugins", "chunks"], "optimization": ["tree_shaking", "code_split"]}
if __name__ == "__main__": print(json.dumps(analyze(), indent=2))
