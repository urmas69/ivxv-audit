#!/usr/bin/env bash
set -Eeuo pipefail

# Source this file; it intentionally does not modify the host installation.
export IVXV_PHASE3_TOOLS=${IVXV_PHASE3_TOOLS:-/home/audit/tools}
export GOROOT="$IVXV_PHASE3_TOOLS/go"
export JAVA_HOME="$IVXV_PHASE3_TOOLS/jdk"
export GRADLE_HOME="$IVXV_PHASE3_TOOLS/gradle/gradle-8.11"
export GOPATH=${GOPATH:-/tmp/ivxv-phase3/gopath}
export GOMODCACHE=${GOMODCACHE:-/tmp/ivxv-phase3/gomodcache}
export GRADLE_USER_HOME=${GRADLE_USER_HOME:-/tmp/ivxv-phase3/gradle-home}
export PATH="$IVXV_PHASE3_TOOLS/bin:$GOROOT/bin:$JAVA_HOME/bin:$GRADLE_HOME/bin:$IVXV_PHASE3_TOOLS/usr/bin:$PATH"
export LD_LIBRARY_PATH="$IVXV_PHASE3_TOOLS/usr/lib/x86_64-linux-gnu:$IVXV_PHASE3_TOOLS/usr/lib/x86_64-linux-gnu/libfakeroot:${LD_LIBRARY_PATH-}"
export C_INCLUDE_PATH="$IVXV_PHASE3_TOOLS/usr/include:$IVXV_PHASE3_TOOLS/usr/include/x86_64-linux-gnu:${C_INCLUDE_PATH-}"
export CPLUS_INCLUDE_PATH="$IVXV_PHASE3_TOOLS/usr/include/c++/11:$IVXV_PHASE3_TOOLS/usr/include/x86_64-linux-gnu/c++/11:$C_INCLUDE_PATH:${CPLUS_INCLUDE_PATH-}"
export LIBRARY_PATH="$IVXV_PHASE3_TOOLS/usr/lib/x86_64-linux-gnu:$IVXV_PHASE3_TOOLS/usr/lib/gcc/x86_64-linux-gnu/11:${LIBRARY_PATH-}"
export CC=${CC:-x86_64-linux-gnu-gcc-11}
export CXX=${CXX:-x86_64-linux-gnu-g++-11}
export DEB_BUILD_OPTIONS=${DEB_BUILD_OPTIONS:-nocheck}
mkdir -p "$GOPATH" "$GOMODCACHE" "$GRADLE_USER_HOME"

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  printf 'GOROOT=%s\nJAVA_HOME=%s\nGRADLE_HOME=%s\nGOPATH=%s\nGOMODCACHE=%s\nGRADLE_USER_HOME=%s\nPATH=%s\n' \
    "$GOROOT" "$JAVA_HOME" "$GRADLE_HOME" "$GOPATH" "$GOMODCACHE" "$GRADLE_USER_HOME" "$PATH"
  command -v make go java javac gradle dpkg-buildpackage gcc g++ || true
  make --version 2>&1 | head -n 1 || true
  go version 2>&1 || true
  java -version 2>&1 | head -n 1 || true
  gradle --version 2>&1 | head -n 8 || true
fi
