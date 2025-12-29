#!/usr/bin/env python3
import json
def analyze(): return {"techniques": ["dynamic_import", "route_based", "component_based"]}
if __name__ == "__main__": print(json.dumps(analyze(), indent=2))
