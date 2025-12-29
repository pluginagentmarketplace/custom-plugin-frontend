#!/usr/bin/env python3
import json
def check(): return {"vulnerabilities": ["xss", "csrf", "sql_injection"], "headers": ["csp", "hsts", "cors"]}
if __name__ == "__main__": print(json.dumps(check(), indent=2))
