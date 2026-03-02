#!/bin/bash

if [ $# -ne 2 ]; then
  echo "Usage: $0 <from-tag> <to-tag>"
  exit 1
fi

FROM=$1
TO=$2

LOG=$(git log "$FROM".."$TO" --oneline --pretty=format:"- %s")

claude -p "You are a technical writer. Given the following git log between tags $FROM and $TO, generate a release changelog in raw markdown. Make sure issuenumber only shows up once. Group by frontend/backend etc. Place tasks with issuenumbers first in each section, and descending. Only output raw markdown, no explanations.

Git log:
$LOG"
