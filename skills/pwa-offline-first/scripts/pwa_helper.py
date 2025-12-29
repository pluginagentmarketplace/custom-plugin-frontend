#!/usr/bin/env python3
import json
def helper(): return {"features": ["service_worker", "manifest", "cache_api"], "strategies": ["cache_first", "network_first"]}
if __name__ == "__main__": print(json.dumps(helper(), indent=2))
