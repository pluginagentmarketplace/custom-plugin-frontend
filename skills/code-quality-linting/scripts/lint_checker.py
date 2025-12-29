#!/usr/bin/env python3
import json
def check(): return {"tools": ["eslint", "prettier", "stylelint"], "rules": ["recommended", "custom"]}
if __name__ == "__main__": print(json.dumps(check(), indent=2))
