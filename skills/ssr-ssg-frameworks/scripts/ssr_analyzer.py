#!/usr/bin/env python3
import json
def analyze(): return {"ssr": ["nextjs", "nuxt", "sveltekit"], "ssg": ["gatsby", "astro", "11ty"]}
if __name__ == "__main__": print(json.dumps(analyze(), indent=2))
