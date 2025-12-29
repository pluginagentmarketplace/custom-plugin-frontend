#!/usr/bin/env python3
import json
def analyze(): return {"reactivity": ["$:", "reactive_statements"], "stores": ["writable", "readable", "derived"]}
if __name__ == "__main__": print(json.dumps(analyze(), indent=2))
