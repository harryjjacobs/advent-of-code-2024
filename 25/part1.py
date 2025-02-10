#!/usr/bin/env python3

width = 5
height = 7


def parse_input(filename):
    locks, keys = [], []

    with open(filename) as f:
        current, key = None, False

        for line in map(str.rstrip, f):
            if not line:
                if current is not None:
                    (keys if key else locks).append(current)
                current = None
                continue

            if current is None:
                if line == "#" * width:
                    current, key = [0] * width, False
                elif line == "." * width:
                    current, key = [height - 2] * width, True
                continue

            for i, char in enumerate(line):
                if key and char == ".":
                    current[i] -= 1
                elif not key and char == "#":
                    current[i] += 1

        if current is not None:
            (keys if key else locks).append(current)

    return locks, keys


def fits(key, lock):
    return all([a + b <= height - 2 for a, b in zip(key, lock)])


def count_fits(locks, keys):
    count = 0
    for lock in locks:
        for key in keys:
            if fits(key, lock):
                count += 1
    return count


locks, keys = parse_input("input")

print(count_fits(locks, keys))
