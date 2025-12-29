#!/usr/bin/env python3
import json
def optimize(): return {"strategies": ["vendor_split", "route_split", "component_split"]}
if __name__ == "__main__": print(json.dumps(optimize(), indent=2))
