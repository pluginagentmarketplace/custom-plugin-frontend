#!/usr/bin/env python3
import json
def validate(): return {"elements": ["semantic", "forms", "tables"], "css": ["flexbox", "grid", "responsive"]}
if __name__ == "__main__": print(json.dumps(validate(), indent=2))
