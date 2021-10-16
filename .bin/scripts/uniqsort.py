#!/bin/python3

"""
    Sorts and removes duplicates of a list of words that I am bad at typing

"""

# Better to use argparse apparently

import sys
words = sorted(set(sys.argv[1:]))

print("Input set length : ", len(sys.argv[1:]))
print("Sorted set length : ", len(words))

sorted = ' '.join(words)
print(sorted)
