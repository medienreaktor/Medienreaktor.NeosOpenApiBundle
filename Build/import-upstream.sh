#!/usr/bin/env bash
# Imports the upstream packages listed in Build/upstream.txt into this bundle.
#
#   Build/import-upstream.sh            imports the pinned commits
#   Build/import-upstream.sh --latest   pins each package to the HEAD of its default branch first
#
# Libraries go to Libraries/<name>/ (src/, README.md, LICENSE). The FlowAdapter is a Flow package, so its Classes/
# and Configuration/ go to the bundle's root, its README.md and LICENSE to Libraries/openapi-flowadapter/.
# Configuration/Settings.Bundle.yaml belongs to the bundle and is kept.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
list="$root/Build/upstream.txt"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

if [[ "${1:-}" == "--latest" ]]; then
    while read -r name url ref; do
        [[ -z "$name" || "$name" == \#* ]] && continue
        latest="$(git ls-remote "$url" HEAD | cut -f1)"
        sed -i.bak "s|^$name $url $ref\$|$name $url $latest|" "$list" && rm "$list.bak"
        echo "$name: $ref -> $latest"
    done < "$list"
fi

while read -r name url ref; do
    [[ -z "$name" || "$name" == \#* ]] && continue
    echo "Importing $name@$ref"
    git clone --quiet "$url" "$tmp/$name"
    git -C "$tmp/$name" checkout --quiet "$ref"

    target="$root/Libraries/$name"
    rm -rf "$target"
    mkdir -p "$target"
    for file in README.md LICENSE; do
        [[ -f "$tmp/$name/$file" ]] && cp "$tmp/$name/$file" "$target/"
    done

    if [[ "$name" == "openapi-flowadapter" ]]; then
        rm -rf "$root/Classes"
        cp -R "$tmp/$name/Classes" "$root/Classes"
        find "$root/Configuration" -mindepth 1 ! -name 'Settings.Bundle.yaml' -delete
        cp -R "$tmp/$name/Configuration/." "$root/Configuration/"
    else
        cp -R "$tmp/$name/src" "$target/src"
    fi
done < "$list"

echo "Done. Check the upstream composer.json files for changed requirements or namespaces."
