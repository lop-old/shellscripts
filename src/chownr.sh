#!/bin/bash


ENTRIES=(`ls -RA | awk '/:$/&&f{s=$0;f=0}/:$/&&!f{sub(/:$/,"");s=$0;f=1;next}NF&&f{ print s"/"$0 }'`)


if [[ -z $1 ]] || [[ -z $2 ]] || [[ -z $3 ]]; then
	echo
	echo usage: $0 <dir o:g> <file o:g> <path>
	echo
	echo e.g. $0 user:wheel user:wheel ./
	echo
	echo sets dir owner/group to user:wheel as well as for files, recursively
	exit 1
fi
echo
echo "Path: $3"
echo "Setting dirs to:  $1"
echo "Setting files to: $2"
echo
pushd "$3" || exit 1
	for ENTRY in "${ENTRIES[@]}"; do
		if [ ! -z $ENTRY ]; then
			if [ -h "$ENTRY" ]; then
				echo "S: $ENTRY"
			elif [ -d "$ENTRY" ]; then
				echo "D: $ENTRY"
				echo -n "  "
				chown -c "$1" "$ENTRY"
				echo -ne "\r"
			elif [ -f "$ENTRY" ]; then
				echo "F: $ENTRY"
				echo -n "  "
				chown -c "$2" "$ENTRY"
				echo -ne "\r"
			else
				echo "UNKNOWN: $ENTRY"
				echo "HALTING!"
				exit 1
			fi
		fi
	done
popd
echo
echo "Finished!"
echo
