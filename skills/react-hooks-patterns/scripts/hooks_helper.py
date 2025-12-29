#!/usr/bin/env python3
import json
def helper(): return {"built_in": ["useState", "useEffect", "useContext", "useReducer"], "custom": ["useFetch", "useForm"]}
if __name__ == "__main__": print(json.dumps(helper(), indent=2))
