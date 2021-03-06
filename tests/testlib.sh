#!/bin/bash

is_md5sum_available ()
{
    which md5sum > /dev/null 2>&1 && return 0

    echo "ERROR: md5sum not found"

    exit 1
}

get_md5 ()
{
     md5sum "$1" | awk '{ print $1}'
}

abort_msg ()
{
    echo "$1" >&2

    exit 1
}

check_sum ()
{
    [ "$2" == "$3" ] && return 0
    abort_msg "$1"
}

check_sizemax ()
{
    local MSG="$1"
    local FILE="$2"
    local MAXSIZE="$3"
    local SIZE=`stat -c "%s" "$FILE"`

    [ "$SIZE" -lt "$MAXSIZE" ] && return 0

    abort_msg "$MSG"
}

handle_check ()
{
    local TDIR=`mktemp -d /tmp/handle_check-XXXXXX`
    local TMP2="$TDIR/check-output.lis"


    mkdir "$TDIR/check"

    echo "**** Checking: $2"
    ( is_md5sum_available
      eval "$1" "$TDIR/check" ) > $TMP2 2>&1

    RET="$?"

    [ -s $TMP2 ] && sed 's/^/  |  /' $TMP2

    if [ "$RET" == "0" ]
    then
        echo "--> PASS"
    else
        echo "--> FAIL"
    fi

    rm -rf $TDIR

    return $RET
}

cre_sparse_file ()
{
    local FILE="$1"
    local SIZE="$2"

    truncate -s "$SIZE" "$FILE"
}

overwrite_file ()
{
    local FILE="$1"
    local POS="$2"

    dd "of=$FILE" ibs=1 "seek=$POS" obs=1 conv=notrunc 2>/dev/null
}
