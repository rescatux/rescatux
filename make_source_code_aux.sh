#!/bin/bash
# Rescapp make_source_code script
# Copyright (C) 2012,2013,2014,2015,2016 Adrian Gibanel Lopez
#
# Rescapp is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Rescapp is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Rescapp.  If not, see <http://www.gnu.org/licenses/>.

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
git archive HEAD | gzip > ${RESCATUX_RELEASE_DIR}/source-code/${BASE_FILENAME}.tar.gz

# chntpw

CHNTPW_GIT_URL="https://github.com/rescatux/chntpw"
CHNTPW_GIT_COMMIT="chntpw-ng-1.01"
CHNTPW_GIT_NAME="chntpw"

get_Git_Tar_Gz "${CHNTPW_GIT_URL}" "${CHNTPW_GIT_COMMIT}" "${RESCATUX_RELEASE_DIR}/source-code/${BASE_FILENAME}-${CHNTPW_GIT_NAME}-${CHNTPW_GIT_COMMIT}.tar.gz"

