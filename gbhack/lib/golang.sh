#!/bin/bash

# Copyright 2014 The Kubernetes Authors All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# The golang package that we are building.
readonly KUBE_GO_PACKAGE=k8s.io/kubernetes
readonly KUBE_GBROOT="${KUBE_OUTPUT_DIR}/gb"

#FIXME## Load contrib target functions
#FIXME#if [ -n "${KUBERNETES_CONTRIB:-}" ]; then
#FIXME#  for contrib in "${KUBERNETES_CONTRIB}"; do
#FIXME#    source "${KUBE_ROOT}/contrib/${contrib}/target.sh"
#FIXME#  done
#FIXME#fi
#FIXME#
#FIXME## The set of server targets that we are only building for Linux
#FIXME#kube::golang::server_targets() {
#FIXME#  local targets=(
#FIXME#    cmd/kube-proxy
#FIXME#    cmd/kube-apiserver
#FIXME#    cmd/kube-controller-manager
#FIXME#    cmd/kubelet
#FIXME#    cmd/hyperkube
#FIXME#    cmd/linkcheck
#FIXME#    plugin/cmd/kube-scheduler
#FIXME#  )
#FIXME#  if [ -n "${KUBERNETES_CONTRIB:-}" ]; then
#FIXME#    for contrib in "${KUBERNETES_CONTRIB}"; do
#FIXME#      targets+=($(eval "kube::contrib::${contrib}::server_targets"))
#FIXME#    done
#FIXME#  fi
#FIXME#  echo "${targets[@]}"
#FIXME#}
#FIXME#readonly KUBE_SERVER_TARGETS=($(kube::golang::server_targets))
#FIXME#readonly KUBE_SERVER_BINARIES=("${KUBE_SERVER_TARGETS[@]##*/}")
#FIXME#
#FIXME## The server platform we are building on.
#FIXME#readonly KUBE_SERVER_PLATFORMS=(
#FIXME#  linux/amd64
#FIXME#)
#FIXME#
#FIXME## The set of client targets that we are building for all platforms
#FIXME#readonly KUBE_CLIENT_TARGETS=(
#FIXME#  cmd/kubectl
#FIXME#)
#FIXME#readonly KUBE_CLIENT_BINARIES=("${KUBE_CLIENT_TARGETS[@]##*/}")
#FIXME#readonly KUBE_CLIENT_BINARIES_WIN=("${KUBE_CLIENT_BINARIES[@]/%/.exe}")
#FIXME#
#FIXME## The set of test targets that we are building for all platforms
#FIXME#kube::golang::test_targets() {
#FIXME#  local targets=(
#FIXME#    cmd/integration
#FIXME#    cmd/gendocs
#FIXME#    cmd/genman
#FIXME#    cmd/mungedocs
#FIXME#    cmd/genbashcomp
#FIXME#    cmd/genconversion
#FIXME#    cmd/gendeepcopy
#FIXME#    cmd/genswaggertypedocs
#FIXME#    examples/k8petstore/web-server
#FIXME#    github.com/onsi/ginkgo/ginkgo
#FIXME#    test/e2e/e2e.test
#FIXME#  )
#FIXME#  if [ -n "${KUBERNETES_CONTRIB:-}" ]; then
#FIXME#    for contrib in "${KUBERNETES_CONTRIB}"; do
#FIXME#      targets+=($(eval "kube::contrib::${contrib}::test_targets"))
#FIXME#    done
#FIXME#  fi
#FIXME#  echo "${targets[@]}"
#FIXME#}
#FIXME#readonly KUBE_TEST_TARGETS=($(kube::golang::test_targets))
#FIXME#readonly KUBE_TEST_BINARIES=("${KUBE_TEST_TARGETS[@]##*/}")
#FIXME#readonly KUBE_TEST_BINARIES_WIN=("${KUBE_TEST_BINARIES[@]/%/.exe}")
#FIXME#readonly KUBE_TEST_PORTABLE=(
#FIXME#  test/images/network-tester/rc.json
#FIXME#  test/images/network-tester/service.json
#FIXME#  hack/e2e.go
#FIXME#  hack/e2e-internal
#FIXME#  hack/ginkgo-e2e.sh
#FIXME#  hack/lib
#FIXME#)
#FIXME#
#FIXME## If we update this we need to also update the set of golang compilers we build
#FIXME## in 'build/build-image/Dockerfile'
#FIXME#readonly KUBE_CLIENT_PLATFORMS=(
#FIXME#  linux/amd64
#FIXME#  linux/386
#FIXME#  linux/arm
#FIXME#  darwin/amd64
#FIXME#  darwin/386
#FIXME#  windows/amd64
#FIXME#)
#FIXME#
#FIXME## Gigabytes desired for parallel platform builds. 11 is fairly
#FIXME## arbitrary, but is a reasonable splitting point for 2015
#FIXME## laptops-versus-not.
#FIXME##
#FIXME## If you are using boot2docker, the following seems to work (note 
#FIXME## that 12000 rounds to 11G):
#FIXME##   boot2docker down
#FIXME##   VBoxManage modifyvm boot2docker-vm --memory 12000
#FIXME##   boot2docker up
#FIXME#readonly KUBE_PARALLEL_BUILD_MEMORY=11
#FIXME#
#FIXME#readonly KUBE_ALL_TARGETS=(
#FIXME#  "${KUBE_SERVER_TARGETS[@]}"
#FIXME#  "${KUBE_CLIENT_TARGETS[@]}"
#FIXME#  "${KUBE_TEST_TARGETS[@]}"
#FIXME#)
#FIXME#readonly KUBE_ALL_BINARIES=("${KUBE_ALL_TARGETS[@]##*/}")
#FIXME#
#FIXME#readonly KUBE_STATIC_LIBRARIES=(
#FIXME#  kube-apiserver
#FIXME#  kube-controller-manager
#FIXME#  kube-scheduler
#FIXME#)
#FIXME#
#FIXME#kube::golang::is_statically_linked_library() {
#FIXME#  local e
#FIXME#  for e in "${KUBE_STATIC_LIBRARIES[@]}"; do [[ "$1" == *"/$e" ]] && return 0; done;
#FIXME#  # Allow individual overrides--e.g., so that you can get a static build of
#FIXME#  # kubectl for inclusion in a container.
#FIXME#  if [ -n "${KUBE_STATIC_OVERRIDES:+x}" ]; then
#FIXME#    for e in "${KUBE_STATIC_OVERRIDES[@]}"; do [[ "$1" == *"/$e" ]] && return 0; done;
#FIXME#  fi
#FIXME#  return 1;
#FIXME#}
#FIXME#
#FIXME## kube::binaries_from_targets take a list of build targets and return the
#FIXME## full go package to be built
#FIXME#kube::golang::binaries_from_targets() {
#FIXME#  local target
#FIXME#  for target; do
#FIXME#    # If the target starts with what looks like a domain name, assume it has a
#FIXME#    # fully-qualified package name rather than one that needs the Kubernetes
#FIXME#    # package prepended.
#FIXME#    if [[ "${target}" =~ ^([[:alnum:]]+".")+[[:alnum:]]+"/" ]]; then
#FIXME#      echo "${target}"
#FIXME#    else
#FIXME#      echo "${KUBE_GO_PACKAGE}/${target}"
#FIXME#    fi
#FIXME#  done
#FIXME#}
#FIXME#
#FIXME## Asks golang what it thinks the host platform is.  The go tool chain does some
#FIXME## slightly different things when the target platform matches the host platform.
#FIXME#kube::golang::host_platform() {
#FIXME#  echo "$(go env GOHOSTOS)/$(go env GOHOSTARCH)"
#FIXME#}
#FIXME#
#FIXME#kube::golang::current_platform() {
#FIXME#  local os="${GOOS-}"
#FIXME#  if [[ -z $os ]]; then
#FIXME#    os=$(go env GOHOSTOS)
#FIXME#  fi
#FIXME#
#FIXME#  local arch="${GOARCH-}"
#FIXME#  if [[ -z $arch ]]; then
#FIXME#    arch=$(go env GOHOSTARCH)
#FIXME#  fi
#FIXME#
#FIXME#  echo "$os/$arch"
#FIXME#}
#FIXME#
#FIXME## Takes the the platform name ($1) and sets the appropriate golang env variables
#FIXME## for that platform.
#FIXME#kube::golang::set_platform_envs() {
#FIXME#  [[ -n ${1-} ]] || {
#FIXME#    kube::log::fatal "!!! Internal error.  No platform set in kube::golang::set_platform_envs"
#FIXME#  }
#FIXME#
#FIXME#  export GOOS=${platform%/*}
#FIXME#  export GOARCH=${platform##*/}
#FIXME#}
#FIXME#
#FIXME#kube::golang::unset_platform_envs() {
#FIXME#  unset GOOS
#FIXME#  unset GOARCH
#FIXME#}

# Create the GOPATH tree under $KUBE_OUTPUT_DIR
kube::golang::create_gopath_tree() {
  # Ensure the common artifacts dirs exist.
  mkdir -p "${KUBE_OUTPUT_BIN_DIR}"
  mkdir -p "${KUBE_OUTPUT_PKG_DIR}"

  # Rebuild the gb tree, it's cheap.
  rm -rf "${KUBE_GBROOT}"

  local gb_srcdir="${KUBE_GBROOT}/src/${KUBE_GO_PACKAGE}"
  local gb_vnddir="${KUBE_GBROOT}/vendor"
  local gb_bindir="${KUBE_GBROOT}/bin"
  local gb_pkgdir="${KUBE_GBROOT}/pkg"

  # TODO: These symlinks should be relative.
  mkdir -p $(dirname "${gb_srcdir}")
  ln -s "${KUBE_ROOT}" "${gb_srcdir}"
  ln -s "${KUBE_ROOT}/Godeps/_workspace" "${gb_vnddir}"
  ln -s "${KUBE_OUTPUT_BIN_DIR}" "${gb_bindir}"
  ln -s "${KUBE_OUTPUT_PKG_DIR}" "${gb_pkgdir}"
}

# kube::golang::setup_env will check that the `go` and `gb` commands are
# available in ${PATH}. If not running on Travis, it will also check that the
# Go version is good enough for the Kubernetes build.
kube::golang::setup_env() {
  kube::golang::create_gopath_tree

  if [[ -z "$(which go)" ]]; then
    kube::log::usage_from_stdin <<EOF

Can't find 'go' in PATH, please fix and retry.
See http://golang.org/doc/install for installation instructions.

EOF
    exit 2
  fi

  if [[ -z "$(which gb)" ]]; then
    kube::log::usage_from_stdin <<EOF

Can't find 'gb' in PATH, please fix and retry.
See http://getgb.io/docs/install/ for installation instructions.

EOF
    exit 2
  fi

  local min_go="1.3"

  # Travis continuous build uses a head go release that doesn't report
  # a version number, so we skip this check on Travis.  It's unnecessary
  # there anyway.
  if [[ "${TRAVIS:-}" != "true" ]]; then
    local go_version
    go_version=($(go version))
    if [[ "${go_version[2]}" < "go${min_go}" ]]; then
      kube::log::usage_from_stdin <<EOF

Detected 'go' version: ${go_version[*]}.
Kubernetes requires Go version ${min_go} or greater.
See http://golang.org/dl to download newer versions of Go.

EOF
      exit 2
    fi
  fi
}

#FIXME## This will take binaries from $GOPATH/bin and copy them to the appropriate
#FIXME## place in ${KUBE_OUTPUT_BIN_DIR}
#FIXME##
#FIXME## Ideally this wouldn't be necessary and we could just set GOBIN to
#FIXME## KUBE_OUTPUT_BIN_DIR but that won't work in the face of cross compilation.  'go
#FIXME## install' will place binaries that match the host platform directly in $GOBIN
#FIXME## while placing cross compiled binaries into `platform_arch` subdirs.  This
#FIXME## complicates pretty much everything else we do around packaging and such.
#FIXME#kube::golang::place_bins() {
#FIXME#  local host_platform
#FIXME#  host_platform=$(kube::golang::host_platform)
#FIXME#
#FIXME#  kube::log::status "Placing binaries"
#FIXME#
#FIXME#  local platform
#FIXME#  for platform in "${KUBE_CLIENT_PLATFORMS[@]}"; do
#FIXME#    # The substitution on platform_src below will replace all slashes with
#FIXME#    # underscores.  It'll transform darwin/amd64 -> darwin_amd64.
#FIXME#    local platform_src="/${platform//\//_}"
#FIXME#    if [[ $platform == $host_platform ]]; then
#FIXME#      platform_src=""
#FIXME#    fi
#FIXME#
#FIXME#    local gopaths=("${KUBE_GOPATH}")
#FIXME#    # If targets were built inside Godeps, then we need to sync from there too.
#FIXME#    if [[ -z ${KUBE_NO_GODEPS:-} ]]; then
#FIXME#      gopaths+=("${KUBE_ROOT}/Godeps/_workspace")
#FIXME#    fi
#FIXME#    local gopath
#FIXME#    for gopath in "${gopaths[@]}"; do
#FIXME#      local full_binpath_src="${gopath}/bin${platform_src}"
#FIXME#      if [[ -d "${full_binpath_src}" ]]; then
#FIXME#        mkdir -p "${KUBE_OUTPUT_BIN_DIR}/${platform}"
#FIXME#        find "${full_binpath_src}" -maxdepth 1 -type f -exec \
#FIXME#          rsync -pt {} "${KUBE_OUTPUT_BIN_DIR}/${platform}" \;
#FIXME#      fi
#FIXME#    done
#FIXME#  done
#FIXME#}
#FIXME#
#FIXME#kube::golang::fallback_if_stdlib_not_installable() {
#FIXME#  local go_root_dir=$(go env GOROOT);
#FIXME#  local go_host_os=$(go env GOHOSTOS);
#FIXME#  local go_host_arch=$(go env GOHOSTARCH);
#FIXME#  local cgo_pkg_dir=${go_root_dir}/pkg/${go_host_os}_${go_host_arch}_cgo;
#FIXME#
#FIXME#  if [ -e ${cgo_pkg_dir} ]; then
#FIXME#    return 0;
#FIXME#  fi
#FIXME#
#FIXME#  if [ -w ${go_root_dir}/pkg ]; then
#FIXME#    return 0;
#FIXME#  fi
#FIXME#
#FIXME#  kube::log::status "+++ Warning: stdlib pkg with cgo flag not found.";
#FIXME#  kube::log::status "+++ Warning: stdlib pkg cannot be rebuilt since ${go_root_dir}/pkg is not writable by `whoami`";
#FIXME#  kube::log::status "+++ Warning: Make ${go_root_dir}/pkg writable for `whoami` for a one-time stdlib install, Or"
#FIXME#  kube::log::status "+++ Warning: Rebuild stdlib using the command 'CGO_ENABLED=0 go install -a -installsuffix cgo std'";
#FIXME#  kube::log::status "+++ Falling back to go build, which is slower";
#FIXME#
#FIXME#  use_go_build=true
#FIXME#}
#FIXME#
#FIXME## Try and replicate the native binary placement of go install without
#FIXME## calling go install.
#FIXME#kube::golang::output_filename_for_binary() {
#FIXME#  local binary=$1
#FIXME#  local platform=$2
#FIXME#  local output_path="${KUBE_GOPATH}/bin"
#FIXME#  if [[ $platform != $host_platform ]]; then
#FIXME#    output_path="${output_path}/${platform//\//_}"
#FIXME#  fi
#FIXME#  local bin=$(basename "${binary}")
#FIXME#  if [[ ${GOOS} == "windows" ]]; then
#FIXME#    bin="${bin}.exe"
#FIXME#  fi
#FIXME#  echo "${output_path}/${bin}"
#FIXME#}
#FIXME#
#FIXME#kube::golang::build_binaries_for_platform() {
#FIXME#  local platform=$1
#FIXME#  local use_go_build=${2-}
#FIXME#
#FIXME#  local -a statics=()
#FIXME#  local -a nonstatics=()
#FIXME#  local -a tests=()
#FIXME#  for binary in "${binaries[@]}"; do
#FIXME#    if [[ "${binary}" =~ ".test"$ ]]; then
#FIXME#      tests+=($binary)
#FIXME#    elif kube::golang::is_statically_linked_library "${binary}"; then
#FIXME#      statics+=($binary)
#FIXME#    else
#FIXME#      nonstatics+=($binary)
#FIXME#    fi
#FIXME#  done
#FIXME#  if [[ "${#statics[@]}" != 0 ]]; then
#FIXME#      kube::golang::fallback_if_stdlib_not_installable;
#FIXME#  fi
#FIXME#
#FIXME#  if [[ -n ${use_go_build:-} ]]; then
#FIXME#    kube::log::progress "    "
#FIXME#    for binary in "${statics[@]:+${statics[@]}}"; do
#FIXME#      local outfile=$(kube::golang::output_filename_for_binary "${binary}" "${platform}")
#FIXME#      CGO_ENABLED=0 go build -o "${outfile}" \
#FIXME#        "${goflags[@]:+${goflags[@]}}" \
#FIXME#        -ldflags "${goldflags}" \
#FIXME#        "${binary}"
#FIXME#      kube::log::progress "*"
#FIXME#    done
#FIXME#    for binary in "${nonstatics[@]:+${nonstatics[@]}}"; do
#FIXME#      local outfile=$(kube::golang::output_filename_for_binary "${binary}" "${platform}")
#FIXME#      go build -o "${outfile}" \
#FIXME#        "${goflags[@]:+${goflags[@]}}" \
#FIXME#        -ldflags "${goldflags}" \
#FIXME#        "${binary}"
#FIXME#      kube::log::progress "*"
#FIXME#    done
#FIXME#    kube::log::progress "\n"
#FIXME#  else
#FIXME#    # Use go install.
#FIXME#    if [[ "${#nonstatics[@]}" != 0 ]]; then
#FIXME#      go install "${goflags[@]:+${goflags[@]}}" \
#FIXME#        -ldflags "${goldflags}" \
#FIXME#        "${nonstatics[@]:+${nonstatics[@]}}"
#FIXME#    fi
#FIXME#    if [[ "${#statics[@]}" != 0 ]]; then
#FIXME#      CGO_ENABLED=0 go install -installsuffix cgo "${goflags[@]:+${goflags[@]}}" \
#FIXME#        -ldflags "${goldflags}" \
#FIXME#        "${statics[@]:+${statics[@]}}"
#FIXME#    fi
#FIXME#  fi
#FIXME#
#FIXME#  for test in "${tests[@]:+${tests[@]}}"; do
#FIXME#    local outfile=$(kube::golang::output_filename_for_binary "${test}" \
#FIXME#      "${platform}")
#FIXME#    # Go 1.4 added -o to control where the binary is saved, but Go 1.3 doesn't
#FIXME#    # have this flag. Whenever we deprecate go 1.3, update to use -o instead of
#FIXME#    # changing into the output directory.
#FIXME#    pushd "$(dirname ${outfile})" >/dev/null
#FIXME#    go test -c \
#FIXME#      "${goflags[@]:+${goflags[@]}}" \
#FIXME#      -ldflags "${goldflags}" \
#FIXME#      "$(dirname ${test})"
#FIXME#    popd >/dev/null
#FIXME#  done
#FIXME#}
#FIXME#
#FIXME## Return approximate physical memory in gigabytes.
#FIXME#kube::golang::get_physmem() {
#FIXME#  local mem
#FIXME#
#FIXME#  # Linux, in kb
#FIXME#  if mem=$(grep MemTotal /proc/meminfo | awk '{ print $2 }'); then
#FIXME#    echo $(( ${mem} / 1048576 ))
#FIXME#    return
#FIXME#  fi
#FIXME#
#FIXME#  # OS X, in bytes. Note that get_physmem, as used, should only ever
#FIXME#  # run in a Linux container (because it's only used in the multiple
#FIXME#  # platform case, which is a Dockerized build), but this is provided
#FIXME#  # for completeness.
#FIXME#  if mem=$(sysctl -n hw.memsize 2>/dev/null); then
#FIXME#    echo $(( ${mem} / 1073741824 ))
#FIXME#    return
#FIXME#  fi
#FIXME#
#FIXME#  # If we can't infer it, just give up and assume a low memory system
#FIXME#  echo 1
#FIXME#}

# Build binaries targets specified
#
# Input:
#   $@ - targets and go flags.  If no targets are set then all binaries targets
#     are built.
#   KUBE_BUILD_PLATFORMS - Incoming variable of targets to build for.  If unset
#     then just the host architecture is built.
kube::golang::build_binaries() {
  # Create a sub-shell so that we don't pollute the outer environment
  (
    # Check for `go` binary and set ${GOPATH}.
    kube::golang::setup_env

#FIXME#    local host_platform
#FIXME#    host_platform=$(kube::golang::host_platform)
#FIXME#
#FIXME#    # Use eval to preserve embedded quoted strings.
#FIXME#    local goflags goldflags
#FIXME#    eval "goflags=(${KUBE_GOFLAGS:-})"
#FIXME#    goldflags="${KUBE_GOLDFLAGS:-} $(kube::version::ldflags)"
#FIXME#
#FIXME#    local use_go_build
    local -a targets=()
    local arg
    for arg; do
#FIXME#      if [[ "${arg}" == "--use_go_build" ]]; then
#FIXME#        use_go_build=true
#FIXME#      elif [[ "${arg}" == -* ]]; then
#FIXME#        # Assume arguments starting with a dash are flags to pass to go.
#FIXME#        goflags+=("${arg}")
#FIXME#      else
        targets+=("${arg}")
#FIXME#      fi
    done

    if [[ ${#targets[@]} -eq 0 ]]; then
      # Sadly, gb is busted with symlinks, for now.
      kube::log::fatal "gb requires explicit targets"
    fi
    cd "${KUBE_GBROOT}"
    gb build "${targets[*]}"
    cd -
    kube::log::fatal "FIXME: left off here"
    #TODO
    # - cross-compile
    # - static linking
    # - flags
    # - parallel

#FIXME#    if [[ ${#targets[@]} -eq 0 ]]; then
#FIXME#      targets=("${KUBE_ALL_TARGETS[@]}")
#FIXME#    fi
#FIXME#
#FIXME#    local -a platforms=("${KUBE_BUILD_PLATFORMS[@]:+${KUBE_BUILD_PLATFORMS[@]}}")
#FIXME#    if [[ ${#platforms[@]} -eq 0 ]]; then
#FIXME#      platforms=("${host_platform}")
#FIXME#    fi
#FIXME#
#FIXME#    local binaries
#FIXME#    binaries=($(kube::golang::binaries_from_targets "${targets[@]}"))
#FIXME#
#FIXME#    local parallel=false
#FIXME#    if [[ ${#platforms[@]} -gt 1 ]]; then
#FIXME#      local gigs
#FIXME#      gigs=$(kube::golang::get_physmem)
#FIXME#
#FIXME#      if [[ ${gigs} -ge ${KUBE_PARALLEL_BUILD_MEMORY} ]]; then
#FIXME#        kube::log::status "Multiple platforms requested and available ${gigs}G >= threshold ${KUBE_PARALLEL_BUILD_MEMORY}G, building platforms in parallel"
#FIXME#        parallel=true
#FIXME#      else
#FIXME#        kube::log::status "Multiple platforms requested, but available ${gigs}G < threshold ${KUBE_PARALLEL_BUILD_MEMORY}G, building platforms in serial"
#FIXME#        parallel=false
#FIXME#      fi
#FIXME#    fi
#FIXME#
#FIXME#    if [[ "${parallel}" == "true" ]]; then
#FIXME#      kube::log::status "Building go targets for ${platforms[@]} in parallel (output will appear in a burst when complete):" "${targets[@]}"
#FIXME#      local platform
#FIXME#      for platform in "${platforms[@]}"; do (
#FIXME#          kube::golang::set_platform_envs "${platform}"
#FIXME#          kube::log::status "${platform}: go build started"
#FIXME#          kube::golang::build_binaries_for_platform ${platform} ${use_go_build:-}
#FIXME#          kube::log::status "${platform}: go build finished"
#FIXME#        ) &> "/tmp//${platform//\//_}.build" &
#FIXME#      done
#FIXME#
#FIXME#      local fails=0
#FIXME#      for job in $(jobs -p); do
#FIXME#        wait ${job} || let "fails+=1"
#FIXME#      done
#FIXME#
#FIXME#      for platform in "${platforms[@]}"; do
#FIXME#        cat "/tmp//${platform//\//_}.build"
#FIXME#      done
#FIXME#
#FIXME#      exit ${fails}
#FIXME#    else
#FIXME#      for platform in "${platforms[@]}"; do
#FIXME#        kube::log::status "Building go targets for ${platform}:" "${targets[@]}"
#FIXME#        kube::golang::set_platform_envs "${platform}"
#FIXME#        kube::golang::build_binaries_for_platform ${platform} ${use_go_build:-}
#FIXME#      done
#FIXME#    fi
  )
}
