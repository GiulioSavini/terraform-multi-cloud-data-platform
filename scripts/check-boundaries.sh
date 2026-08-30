#!/usr/bin/env bash
#
# Enforces the one structural rule of the DDD layout: a bounded context is
# consumed through its contract, never by reaching into its provider adapters.
#
# A violation is easy to introduce (sourcing ../networking/aws is one character
# away from ../networking) and invisible in review, but it couples a consumer to
# a provider interface and defeats the whole arrangement.

set -euo pipefail

fail=0

# Any module source that points at a provider adapter inside another context.
while IFS= read -r hit; do
    file="${hit%%:*}"
    # A context sourcing its own adapters is exactly how contract.tf works.
    ctx="$(printf '%s' "$file" | cut -d/ -f2)"
    if printf '%s' "$hit" | grep -q "domains/${ctx}/"; then
        continue
    fi
    echo "BOUNDARY: $hit"
    fail=1
done < <(grep -rn --include='*.tf' -E 'source[[:space:]]*=[[:space:]]*"[^"]*domains/[a-z-]+/(aws|azure|gcp|cross-cloud)"' . || true)

# Adapters must not reach back up into the contract or into another context.
while IFS= read -r hit; do
    echo "BOUNDARY: $hit"
    fail=1
done < <(grep -rn --include='*.tf' -E 'source[[:space:]]*=[[:space:]]*"\.\./\.\./\.\./domains' domains 2>/dev/null || true)

if [ "$fail" -ne 0 ]; then
    cat >&2 <<'MSG'

A bounded context was consumed through one of its provider adapters instead of
its contract. Adapters track the provider API; contracts track the domain. Add
what you need to the context's outputs.tf and consume that instead.
MSG
    exit 1
fi

echo "Context boundaries intact."
