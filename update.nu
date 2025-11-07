#!/usr/bin/env nix
#! nix develop --impure --command nu

# Update composite action uses in action.yml

def get_latest_action []: string -> string {
    let tags = gh api $"repos/($in)/tags" | from json | get name
    let semver = $tags | where ($it =~ '^v[0-9]+$')
    if ($semver | is-empty) {
        $in
    } else {
        $semver | first
    }
}

def parse_action []: nothing -> record {
    let parts = ($in | split row "@")
    if ($parts | length) > 1 {
        { repo: ($parts | first), version: ($parts | last) }
    } else {
        { repo: ($parts | first), version: "" }
    }
}

def update_workflow_job_step_actions []: record -> record {
    if "uses" in $in {
        let action = $in.uses | parse_action
        let next_version = $action.repo | get_latest_action
        let next_uses = if ($next_version | is-empty) {
            $"($action.repo)@($action.version)"
        } else {
            $"($action.repo)@($next_version)"
        }
        $in | update uses $next_uses
    } else {
        $in
    }
}

def update_action_steps []: record -> record {
    $in | update runs {
        update steps {
            par-each { |step| $step | update_workflow_job_step_actions }
        }
    }
}

print "[action] Updating composite action (action.yml)..."
open $"($env.FILE_PWD)/action.yml"
    | update_action_steps
    | save --force $"($env.FILE_PWD)/action.yml"

# Update workflows
print "[workflows] Updating GitHub Actions workflows..."
nu $"($env.FILE_PWD)/.github/workflows/update.nu"
    | lines
    | each { |line|
        print $"[workflows] ($line)"
    }
    | ignore
