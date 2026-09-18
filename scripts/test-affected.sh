#!/usr/bin/env bash

set -euo pipefail

if [[ "${GITHUB_EVENT_NAME:-}" != "pull_request" ]]; then
  echo "::error::Este script deve ser executado em um evento pull_request."
  exit 1
fi

BASE_SHA="$(
  python3 - <<'PY'
import json
import os

with open(os.environ["GITHUB_EVENT_PATH"], encoding="utf-8") as f:
    event = json.load(f)

print(event["pull_request"]["base"]["sha"])
PY
)"

HEAD_SHA="$(
  python3 - <<'PY'
import json
import os

with open(os.environ["GITHUB_EVENT_PATH"], encoding="utf-8") as f:
    event = json.load(f)

print(event["pull_request"]["head"]["sha"])
PY
)"

echo "Event: ${GITHUB_EVENT_NAME}"
echo "Base ref: ${GITHUB_BASE_REF}"
echo "Head ref: ${GITHUB_HEAD_REF}"
echo "Base SHA: ${BASE_SHA}"
echo "Head SHA: ${HEAD_SHA}"

git fetch origin main --depth=1 >/dev/null 2>&1 || true

echo "Comparando:"
echo "  $BASE_SHA"
echo "  $HEAD_SHA"


changed_files="$(
  git diff --name-only "$BASE_SHA" "$HEAD_SHA"
)"

if [[ -z "$changed_files" ]]; then
  echo "Nenhum arquivo alterado."
  exit 0
fi

declare -A TESTS=()

while IFS= read -r file; do
  [[ -z "$file" ]] && continue

  # Somente classes Java da aplicação.
  [[ "$file" == src/main/java/*.java || "$file" == src/main/java/*/*.java || "$file" == src/main/java/*/*/*.java || "$file" == src/main/java/*/*/*/*.java || "$file" == src/main/java/*/*/*/*/*.java || "$file" == src/main/java/*/*/*/*/*/*.java ]] || continue

  filename="$(basename "$file" .java)"

  # Classes consideradas testáveis.
  case "$filename" in
    *Service|*Controller|*Utils|*Helpers|*Mapper|*Mappers)
      ;;
    *)
      continue
      ;;
  esac

  relative="${file#src/main/java/}"
  package_path="$(dirname "$relative")"

  test_file="src/test/java/${package_path}/${filename}Test.java"
  tests_file="src/test/java/${package_path}/${filename}Tests.java"

  if [[ -f "$test_file" ]]; then
    matching_test="$test_file"
  elif [[ -f "$tests_file" ]]; then
    matching_test="$tests_file"
  else
    echo "::error file=$file::Classe testável '$filename' não possui ${filename}Test.java ou ${filename}Tests.java."
    exit 1
  fi

  # O teste precisa possuir pelo menos uma anotação de teste real.
  if ! grep -Eq '@(Test|ParameterizedTest|RepeatedTest|TestFactory|TestTemplate)\b' "$matching_test"; then
    echo "::error file=$matching_test::O teste '$matching_test' não possui uma anotação de teste válida."
    echo "::error::Use @Test, @ParameterizedTest, @RepeatedTest, @TestFactory ou @TestTemplate."
    exit 1
  fi

  TESTS["$matching_test"]=1

done <<< "$changed_files"

if [[ "${#TESTS[@]}" -eq 0 ]]; then
  echo "Nenhuma classe testável foi alterada."
  exit 0
fi

echo
echo "Testes afetados:"

test_patterns=()

for test_file in "${!TESTS[@]}"; do
  echo "  - $test_file"

  test_class="$(
    echo "$test_file" |
      sed \
        -e 's#^src/test/java/##' \
        -e 's#/#.#g' \
        -e 's#\.java$##'
  )"

  test_patterns+=("$test_class")
done

echo
echo "Executando testes..."

./mvnw -B test \
  -Dtest="$(IFS=,; echo "${test_patterns[*]}")"