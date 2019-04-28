#!/bin/bash
# Rescatux make-source-code-aux script
# Copyright (C) 2012,2013,2014,2015,2016 Adrian Gibanel Lopez
#
# Rescatux is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Rescatux is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Rescatux.  If not, see <http://www.gnu.org/licenses/>.

set -x
set -v


# 1 parametre = Git url
# 2 parametre = Git commit
# 3 parametre = Final Tar.gz
function get_Git_Tar_Gz () {
  local GIT_URL="$1"
  local GIT_COMMIT="$2"
  local FINAL_TAR_GZ="$3"
  local TMP_REPO_DIR="git"

  local PRE_FUNCTION_PWD="$(pwd)"

  local GIT_TEMP_FOLDER="$(mktemp -d)"

  cd "${GIT_TEMP_FOLDER}"
  mkdir ${TMP_REPO_DIR}
  git clone "${GIT_URL}" "${TMP_REPO_DIR}"
  cd ${TMP_REPO_DIR}
  git checkout "${GIT_COMMIT}"

  git archive HEAD | gzip > ${FINAL_TAR_GZ}

  cd "${PRE_FUNCTION_PWD}"
  rm -rf "${GIT_TEMP_FOLDER}"


}

RESCATUX_RELEASE_DIR="$(pwd)/rescatux-release"
BASE_FILENAME="rescatux-`head -n 1 VERSION`"
RESCATUX_GIT_COMMIT="$(git rev-parse HEAD)"
git archive HEAD | gzip > "${RESCATUX_RELEASE_DIR}/source-code/${BASE_FILENAME}-main-rescatux-repo-${RESCATUX_GIT_COMMIT}.tar.gz"

# live-build

LIVEBUILD_GIT_URL="https://github.com/rescatux/live-build/"
LIVEBUILD_GIT_COMMIT="rescatux-0.40b7"
LIVEBUILD_GIT_NAME="live-build"

get_Git_Tar_Gz "${LIVEBUILD_GIT_URL}" "${LIVEBUILD_GIT_COMMIT}" "${RESCATUX_RELEASE_DIR}/source-code/${BASE_FILENAME}-${LIVEBUILD_GIT_NAME}-${LIVEBUILD_GIT_COMMIT}.tar.gz"
