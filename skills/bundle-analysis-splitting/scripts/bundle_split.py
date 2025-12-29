#!/usr/bin/env python3
import json
def split(): return {"tools": ["webpack_bundle_analyzer", "source_map_explorer"], "targets": ["50kb_chunks"]}
if __name__ == "__main__": print(json.dumps(split(), indent=2))
