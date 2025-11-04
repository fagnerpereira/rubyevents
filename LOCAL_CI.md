# Local CI Setup

This document describes how to run CI checks locally for fast feedback before committing.

## Quick Start

Show available options:

```bash
bin/ci --help
```

Run all CI checks with auto-fix (default):

```bash
bin/ci
```

Run all checks without auto-fix:

```bash
bin/ci --no-fix
```

Run specific job groups:

```bash
bin/ci --lint              # Only linting
bin/ci --test              # Only tests
```

## What Gets Run

The local CI provides fast feedback with optimized checks:

### 1. Lint Job
- **StandardRB** - Ruby style checking
- **StandardJS** - JavaScript linting via `yarn lint`
- **YAML Linting** - YAML data file validation via `yarn lint:yml`
- **ERB Lint** - ERB template linting

### 2. Test Job
- **Install dependencies** - `yarn install --frozen-lockfile`
- **Build assets** - `bin/vite build --clear --mode=test`
- **Prepare database** - Creates test DB and loads schema
- **Rails tests** - `bin/rails test`
- **System tests** - `bin/rails test:system`

### Bonus: Security Checks
Local CI includes additional security checks:
- **Gem audit** - Checks for vulnerable gem versions

## Usage Tips

**Before committing:**
```bash
bin/ci        # Auto-fix and run all checks (default)
git commit    # Commit your changes
```

**Fast feedback during development:**
```bash
bin/ci --lint              # Quick lint check with auto-fix
bin/ci --test              # Run tests only
```

**Pre-push verification (no auto-fix):**
```bash
bin/ci --no-fix            # Run without auto-fix
```

**Manual commands for specific checks:**
```bash
# Linting with auto-fix
bundle exec standardrb --fix
yarn format
yarn format:yml
bundle exec erb_lint --lint-all --autocorrect

# Linting without auto-fix
bundle exec standardrb
yarn lint
yarn lint:yml
bundle exec erb_lint --lint-all

# Tests
bin/rails test
bin/rails test:system
```

## Environment

Make sure you have:
- Ruby dependencies installed (`bundle install`)
- Node dependencies installed (`yarn install`)
- Test database will be automatically reset by CI (`RAILS_ENV=test bin/rails db:reset`)

## Comparison with GitHub Actions

| Feature | Local CI (`bin/ci`) | GitHub Actions |
|---------|-------------------|----------------|
| Lint checks | ✅ Same checks | ✅ |
| Tests | ✅ Same tests | ✅ |
| Seed smoke tests | ❌ Not included | ✅ |
| Security audit | ✅ Bonus feature | ❌ |
| Auto-fix | ✅ Default (use `--no-fix` to disable) | ❌ |
| Selective runs | ✅ `--lint`, `--test` | ❌ |
| Deploy job | ❌ | ✅ (main branch only) |

**Note:** Seed smoke tests are excluded from local CI for faster feedback. They run in GitHub Actions to ensure data integrity.

## Troubleshooting

**"Database errors or foreign key constraints"**
```bash
RAILS_ENV=test bin/rails db:reset
```

**"Assets not found"**
```bash
bin/vite build --clear --mode=test
```

**"Node modules missing"**
```bash
yarn install --frozen-lockfile
```
