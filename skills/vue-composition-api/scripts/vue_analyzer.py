#!/usr/bin/env python3
import json
def analyze(): return {"features": ["ref", "reactive", "computed", "watch"], "lifecycle": ["onMounted", "onUnmounted"]}
if __name__ == "__main__": print(json.dumps(analyze(), indent=2))
