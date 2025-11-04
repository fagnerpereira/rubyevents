# Run using bin/ci [options]
# This provides fast local feedback before committing
#
# Options:
#   --no-fix          Disable auto-fixing (default: auto-fix enabled)
#   --lint            Run only lint checks
#   --test            Run only tests (includes preparation)
#
# Examples:
#   bin/ci                    # Run everything with auto-fix
#   bin/ci --no-fix           # Run everything without auto-fix
#   bin/ci --lint             # Run only linting
#   bin/ci --test             # Run only tests

CI.run do
  ENV["RAILS_ENV"] = "test"

  # Show help if requested
  if ARGV.include?("--help") || ARGV.include?("-h")
    puts <<~HELP
      Usage: bin/ci [options]

      Options:
        --no-fix          Disable auto-fixing (default: auto-fix enabled)
        --lint            Run only lint checks
        --test            Run only tests (includes preparation)
        -h, --help        Show this help message

      Examples:
        bin/ci                    # Run everything with auto-fix
        bin/ci --no-fix           # Run everything without auto-fix
        bin/ci --lint             # Run only linting
        bin/ci --test             # Run only tests

      See LOCAL_CI.md for more details.
    HELP
    exit 0
  end

  # Parse options
  auto_fix = !ARGV.include?("--no-fix")
  run_lint = ARGV.include?("--lint")
  run_test = ARGV.include?("--test")
  run_all = !run_lint && !run_test

  # Lint Job - matches GitHub Actions lint job
  if run_all || run_lint
    puts "\n==> Running Lint Checks (matches CI lint job)..."

    if auto_fix
      step "Lint: StandardRB (with --fix)", "bundle exec standardrb --fix"
      step "Lint: StandardJS (with format)", "yarn format"
      step "Lint: erb-lint (with --autocorrect)", "bundle exec erb_lint --lint-all --autocorrect"
      step "Lint: YAML (with format)", "yarn format:yml"
    else
      step "Lint: StandardRB", "bundle exec standardrb"
      step "Lint: StandardJS", "yarn lint"
      step "Lint: YAML data files", "yarn lint:yml"
      step "Lint: erb-lint", "bundle exec erb_lint --lint-all"
    end

    # Security checks (not in GitHub Actions, but useful locally)
    puts "\n==> Running Security Checks..."
    step "Security: Gem audit", "bin/bundler-audit"
    # step "Security: Importmap vulnerability audit", "bin/importmap audit"
  end

  # Test Job - optimized for fast local feedback
  if run_all || run_test
    puts "\n==> Running Tests..."
    step "Prepare: Install dependencies", "yarn install --frozen-lockfile"
    step "Prepare: Build assets", "bin/vite build --clear --mode=test"
    step "Prepare: Database", "bin/rails db:test:prepare"

    step "Test: Rails", "bin/rails test"
    step "Test: System", "bin/rails test:system"
  end

  # Optional: set a green GitHub commit status to unblock PR merge.
  # Requires the `gh` CLI and `gh extension install basecamp/gh-signoff`.
  # if success?
  #   step "Signoff: All systems go. Ready for merge and deploy.", "gh signoff"
  # else
  #   failure "Signoff: CI failed. Do not merge or deploy.", "Fix the issues and try again."
  # end

  puts "\n==> CI completed successfully!"
  ENV["RAILS_ENV"] = "development"
end
