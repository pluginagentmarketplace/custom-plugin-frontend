#!/usr/bin/env python3
import json
def patterns(): return {"local": ["useState", "useReducer"], "global": ["context", "redux", "zustand"]}
if __name__ == "__main__": print(json.dumps(patterns(), indent=2))
