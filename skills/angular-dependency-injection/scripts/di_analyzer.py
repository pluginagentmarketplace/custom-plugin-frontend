#!/usr/bin/env python3
import json
def analyze(): return {"decorators": ["Injectable", "Inject"], "providers": ["root", "component", "module"]}
if __name__ == "__main__": print(json.dumps(analyze(), indent=2))
