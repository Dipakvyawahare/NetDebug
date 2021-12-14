#!/bin/bash
set -euxo pipefail

swift-format --recursive Sources/NetDebug Tests --in-place
swift-format lint --recursive Sources/NetDebug Tests
