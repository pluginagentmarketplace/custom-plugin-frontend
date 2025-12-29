#!/usr/bin/env python3
import json
def helper(): return {"toolkit": ["createSlice", "configureStore"], "middleware": ["thunk", "saga"]}
if __name__ == "__main__": print(json.dumps(helper(), indent=2))
