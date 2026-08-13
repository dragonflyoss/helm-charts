#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
chart_dir="${repo_root}/charts/dragonfly"
test_dir="$(mktemp -d)"
trap 'rm -rf "${test_dir}"' EXIT

assert_count() {
  local expected="$1"
  local pattern="$2"
  local rendered_file="$3"
  local actual

  actual="$(grep -Ec "${pattern}" "${rendered_file}" || true)"
  if [[ "${actual}" -ne "${expected}" ]]; then
    echo "expected ${expected} matches for ${pattern}, found ${actual}" >&2
    exit 1
  fi
}

helm template grpc-auth "${chart_dir}" >"${test_dir}/disabled.yaml"
assert_count 0 '^[[:space:]]+grpcAuth:$' "${test_dir}/disabled.yaml"
assert_count 0 'name: grpc-auth$' "${test_dir}/disabled.yaml"

for mode in permissive required; do
  helm template grpc-auth "${chart_dir}" \
    --set manager.enable=true \
    --set "grpcAuth.mode=${mode}" \
    --set grpcAuth.existingSecret=dragonfly-grpc-auth \
    >"${test_dir}/${mode}.yaml"

  assert_count 4 '^[[:space:]]+grpcAuth:$' "${test_dir}/${mode}.yaml"
  assert_count 4 "^[[:space:]]+mode: \"${mode}\"$" "${test_dir}/${mode}.yaml"
  assert_count 8 'name: grpc-auth$' "${test_dir}/${mode}.yaml"
  assert_count 4 'secretName: "dragonfly-grpc-auth"$' "${test_dir}/${mode}.yaml"
done

if helm template grpc-auth "${chart_dir}" \
  --set grpcAuth.mode=permissive \
  >"${test_dir}/missing-secret.log" 2>&1; then
  echo "expected permissive mode without existingSecret to fail" >&2
  exit 1
fi
grep -q 'grpcAuth.existingSecret is required' "${test_dir}/missing-secret.log"

if helm template grpc-auth "${chart_dir}" \
  --set grpcAuth.mode=invalid \
  >"${test_dir}/invalid-mode.log" 2>&1; then
  echo "expected an invalid authentication mode to fail" >&2
  exit 1
fi
grep -q 'grpcAuth.mode must be one of disabled, permissive, or required' "${test_dir}/invalid-mode.log"
