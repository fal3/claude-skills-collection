#!/usr/bin/env bash

set -u
set -o pipefail

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
failure_count=0
checked_count=0
parsed_count=0

typecheck_file() {
  local file="$1"
  local sdk="$2"
  local target="$3"
  shift 3
  local sdk_path
  local platform_path
  local swiftc_path
  local developer_directory
  local testing_plugin
  local -a compiler_arguments

  if ! sdk_path="$(xcrun --sdk "$sdk" --show-sdk-path 2>/dev/null)"; then
    echo "ERROR missing SDK '$sdk' required by ${file#"$repository_root"/}"
    failure_count=$((failure_count + 1))
    return
  fi

  compiler_arguments=(
    -typecheck
    -parse-as-library
    -swift-version 6
    -strict-concurrency=complete
    -warnings-as-errors
    -sdk "$sdk_path"
    -target "$target"
  )

  if [[ "$file" == "$repository_root/skills/swift-concurrency-migration/examples/ConcurrencyMigrationExample.swift" ]]; then
    compiler_arguments+=(
      -default-isolation MainActor
      -enable-upcoming-feature NonisolatedNonsendingByDefault
    )
  fi

  if [[ "$target" == *-macabi ]]; then
    compiler_arguments+=(
      -F "$sdk_path/System/iOSSupport/System/Library/Frameworks"
      -I "$sdk_path/System/iOSSupport/usr/include"
    )
  fi

  if grep -Eq '^import (Testing|XCTest)$' "$file"; then
    platform_path="$(xcrun --sdk "$sdk" --show-sdk-platform-path)"
    swiftc_path="$(xcrun --find swiftc)"
    developer_directory="${swiftc_path%%/Toolchains/*}"
    testing_plugin="$developer_directory/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/host/plugins/testing/libTestingMacros.dylib"
    compiler_arguments+=( -F "$platform_path/Developer/Library/Frameworks" )
    if grep -Eq '^import Testing$' "$file"; then
      if [[ ! -f "$testing_plugin" ]]; then
        echo "ERROR missing Swift Testing macro plugin required by ${file#"$repository_root"/}"
        failure_count=$((failure_count + 1))
        return
      fi
      compiler_arguments+=( -load-plugin-library "$testing_plugin" )
    fi
  fi

  compiler_arguments+=( "$file" )
  if (( $# > 0 )); then
    compiler_arguments+=( "$@" )
  fi

  echo "TYPECHECK ${file#"$repository_root"/} [$target]"
  if xcrun swiftc "${compiler_arguments[@]}"; then
    checked_count=$((checked_count + 1))
  else
    failure_count=$((failure_count + 1))
  fi
}

parse_external_example() {
  local file="$1"

  echo "PARSE ${file#"$repository_root"/} [external dependency]"
  if xcrun swiftc -frontend -parse -swift-version 6 "$file"; then
    parsed_count=$((parsed_count + 1))
  else
    failure_count=$((failure_count + 1))
  fi
}

while IFS= read -r file; do
  relative="${file#"$repository_root"/}"

  if grep -Eq '^import (Lottie|GRDB|ComposableArchitecture)$' "$file"; then
    parse_external_example "$file"
    continue
  fi

  case "$relative" in
    skills/app-intents-widgets/examples/AppIntentsExample.swift)
      typecheck_file "$file" iphonesimulator arm64-apple-ios16.0-simulator
      typecheck_file "$file" macosx arm64-apple-macosx13.0
      ;;
    skills/app-intents-widgets/examples/WidgetTimelineExample.swift)
      typecheck_file "$file" iphonesimulator arm64-apple-ios17.0-simulator
      typecheck_file "$file" macosx arm64-apple-macosx14.0
      ;;
    skills/swift-SpeechAnalyzer-Framework-Expert/examples/*)
      if [[ "$relative" == "skills/swift-SpeechAnalyzer-Framework-Expert/examples/live_transcription.swift" ]]; then
        typecheck_file \
          "$file" \
          iphonesimulator \
          arm64-apple-ios26.0-simulator \
          "$repository_root/skills/swift-SpeechAnalyzer-Framework-Expert/examples/buffer_converter.swift"
      else
        typecheck_file "$file" iphonesimulator arm64-apple-ios26.0-simulator
        typecheck_file "$file" macosx arm64-apple-macosx26.0
        typecheck_file "$file" appletvsimulator arm64-apple-tvos26.0-simulator
        typecheck_file "$file" xrsimulator arm64-apple-xros26.0-simulator
      fi
      ;;
    skills/cross-platform-app-development-skill/examples/*)
      typecheck_file "$file" iphonesimulator arm64-apple-ios17.0-simulator
      typecheck_file "$file" macosx arm64-apple-macosx14.0
      typecheck_file "$file" appletvsimulator arm64-apple-tvos17.0-simulator
      typecheck_file "$file" watchsimulator arm64-apple-watchos10.0-simulator
      typecheck_file "$file" xrsimulator arm64-apple-xros1.0-simulator
      typecheck_file "$file" macosx arm64-apple-ios17.0-macabi
      ;;
    skills/swiftui-programming-skill/examples/*)
      typecheck_file "$file" iphonesimulator arm64-apple-ios17.0-simulator
      typecheck_file "$file" macosx arm64-apple-macosx14.0
      ;;
    skills/swift-modern-architecture-skill/examples/*)
      typecheck_file "$file" iphonesimulator arm64-apple-ios18.0-simulator
      typecheck_file "$file" macosx arm64-apple-macosx15.0
      ;;
    skills/ios-accessibility-skill/examples/*|\
    skills/swift-performance-optimization-skill/examples/*)
      typecheck_file "$file" iphonesimulator arm64-apple-ios17.0-simulator
      ;;
    skills/swiftdata-core-data-migrations/examples/*)
      typecheck_file "$file" iphonesimulator arm64-apple-ios17.0-simulator
      typecheck_file "$file" macosx arm64-apple-macosx14.0
      ;;
    skills/ios-animation-graphics-skill/examples/example_canvas_waveform.swift)
      typecheck_file "$file" iphonesimulator arm64-apple-ios15.0-simulator
      typecheck_file "$file" macosx arm64-apple-macosx12.0
      ;;
    skills/ios-animation-graphics-skill/examples/*)
      typecheck_file "$file" iphonesimulator arm64-apple-ios15.0-simulator
      ;;
    skills/swift-unit-testing-skill/examples/*|\
    skills/memory-leak-diagnosis-skill/examples/*)
      typecheck_file "$file" macosx arm64-apple-macosx13.0
      ;;
    skills/swift-concurrency-migration/examples/*)
      typecheck_file "$file" iphonesimulator arm64-apple-ios18.0-simulator
      typecheck_file "$file" macosx arm64-apple-macosx15.0
      ;;
    *)
      echo "ERROR no typecheck target is configured for $relative"
      failure_count=$((failure_count + 1))
      ;;
  esac
done < <(find "$repository_root/skills" -path '*/examples/*.swift' -type f | LC_ALL=C sort)

echo "Validated $checked_count compiler target(s); parsed $parsed_count external-dependency example(s)."
if (( failure_count > 0 )); then
  echo "$failure_count example validation failure(s)."
  exit 1
fi
