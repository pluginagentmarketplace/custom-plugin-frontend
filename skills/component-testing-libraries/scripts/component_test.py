#!/usr/bin/env python3
import json
def test(): return {"libraries": ["testing_library", "enzyme"], "queries": ["getBy", "findBy", "queryBy"]}
if __name__ == "__main__": print(json.dumps(test(), indent=2))
