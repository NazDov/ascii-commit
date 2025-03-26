#!/bin/bash

pattern_file="pic.txt"

# Ensure the script is run inside a Git repository
if [ ! -d ".git" ]; then
    echo "Not a git repository"
    exit 1
fi

# Ensure the pattern file exists
if [ ! -f "$pattern_file" ]; then
    echo "Pattern file not found"
    exit 1
fi

# Get start date: last Sunday, 51 weeks ago
start_date=$(date -v -51w -v -Sun +%Y-%m-%d)

# Read lines manually (macOS lacks mapfile)
IFS=$'\n' read -d '' -r -a lines < <(cat "$pattern_file"; printf '\0')

# Show ASCII preview
echo "Rendering commit pattern:"
for line in "${lines[@]}"; do
    echo "$line" | sed 's/#/█/g'
done
echo "Commits will be applied now..."

# Loop through the grid and create commits
for row in {0..6}; do
  for col in {0..51}; do
    char="${lines[$row]:$col:1}"
    if [ "$char" == "#" ]; then
      start_epoch=$(date -j -f "%Y-%m-%d" "$start_date" +%s)
      offset_seconds=$(( (col * 7 + row) * 86400 ))
      commit_epoch=$((start_epoch + offset_seconds))
      commit_date=$(date -j -r "$commit_epoch" +%Y-%m-%d)


      commit_density=10
      for i in $(seq 1 $commit_density); do
        echo "$commit_date - commit $i" > fake.txt
        git add fake.txt
        GIT_AUTHOR_DATE="$commit_date 12:00:00" \
        GIT_COMMITTER_DATE="$commit_date 12:00:00" \
        git commit -m "Fake commit on $commit_date"
      done
    fi
  done
done

rm fake.txt
echo "Done"
