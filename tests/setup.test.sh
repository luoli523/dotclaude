#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_HOME="$(mktemp -d)"
trap 'rm -rf "$TEST_HOME"' EXIT

assert_contains() {
    local haystack="$1"
    local needle="$2"
    [[ "$haystack" == *"$needle"* ]] || {
        echo "Expected output to contain: $needle" >&2
        exit 1
    }
}

codex_output=$(HOME="$TEST_HOME" bash "$REPO_DIR/setup.sh" --codex --skip-skills --dry-run)
assert_contains "$codex_output" "Codex"
assert_contains "$codex_output" ".codex"

HOME="$TEST_HOME" bash "$REPO_DIR/setup.sh" --codex --skip-skills >/dev/null
[[ -L "$TEST_HOME/.codex/AGENTS.md" ]] || {
    echo "Expected Codex AGENTS.md to be a symlink" >&2
    exit 1
}
[[ -f "$TEST_HOME/.codex/config.toml" ]] || {
    echo "Expected Codex config.toml to be rendered" >&2
    exit 1
}

all_output=$(HOME="$TEST_HOME" bash "$REPO_DIR/setup.sh" --skip-skills --dry-run)
assert_contains "$all_output" "Claude Code"
assert_contains "$all_output" "Codex"

project_dir="$TEST_HOME/project"
mkdir -p "$project_dir"
bash "$REPO_DIR/init-project.sh" "$project_dir" >/dev/null
[[ -f "$project_dir/AGENTS.md" ]] || {
    echo "Expected init-project.sh to create AGENTS.md" >&2
    exit 1
}
