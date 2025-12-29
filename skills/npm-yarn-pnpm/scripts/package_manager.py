#!/usr/bin/env python3
import json
def compare(): return {"npm": "standard", "yarn": "workspaces", "pnpm": "disk_efficient"}
if __name__ == "__main__": print(json.dumps(compare(), indent=2))
