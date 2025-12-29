#!/usr/bin/env python3
import json
def analyze(): return {"patterns": ["provider", "consumer", "useContext"], "use_cases": ["theme", "auth", "locale"]}
if __name__ == "__main__": print(json.dumps(analyze(), indent=2))
