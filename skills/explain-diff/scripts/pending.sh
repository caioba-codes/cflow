#!/usr/bin/env bash
# pending.sh — explainers the user has not reviewed yet, one per line: <title><TAB><url>
# Prints "none" when nothing is pending and "unknown: <why>" when the list can't be read.
# Always exits 0. Review tracking is optional: it comes from an executable
# `cflow-explain-pending` on PATH (pair it with your `cflow-explain-publish` hook).
# Without one, nothing is tracked and this prints "none".
if command -v cflow-explain-pending >/dev/null; then cflow-explain-pending; exit 0; fi
echo none
