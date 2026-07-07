#!/bin/env python3
import os
for file in os.listdir():
    if file.endswith(".md"):
        if file == "index.md": continue
        if file.lower() in ["brid","bird"]