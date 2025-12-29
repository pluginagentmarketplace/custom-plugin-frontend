#!/usr/bin/env python3
import json
def analyze(): return {"react": ["lazy", "Suspense"], "vue": ["defineAsyncComponent"], "webpack": ["dynamic_import"]}
if __name__ == "__main__": print(json.dumps(analyze(), indent=2))
