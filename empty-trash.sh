#!/usr/bin/env bash

# "set -euo pipefail" makes the script stop in several error conditions,
# such as when a command fails, an undefined variable is used,
# or a command in a pipeline fails 

set -euo pipefail 

# "TRASH_DIR" is the variable that stores the path to the trash directory

TRASH_DIR="${HOME}/.local/share/Trash"

# If the trash directory does not exist, the script exits successfully
# before trying to remove files from a non-existent path

if [[ ! -d "$TRASH_DIR" ]]; then
	exit 0
fi

# These commands remove the trashed files and their associated metadata

rm -rf -- "${TRASH_DIR}/files/"*

rm -rf -- "${TRASH_DIR}/info/"*
