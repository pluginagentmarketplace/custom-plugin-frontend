#!/usr/bin/env python3
import json
def help(): return {"methods": ["querySelector", "addEventListener", "classList"], "events": ["click", "input", "submit"]}
if __name__ == "__main__": print(json.dumps(help(), indent=2))
