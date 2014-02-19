#!/bin/bash
#
# this script will remove records from the dsi table and reload them
# with the latest data
#
# the latest data is downloaded from github and online dialog text files.
# the data is formatted and prepared for sql loading.
#
# lots of external dependencies:
#  - database connection information in file $INFOFILE
#  - download several files using wget
#  - rake command
#  - mysql

# prod values
TMPTOP=/home/bfm/finder
INFOFILE=/home/bfm/finder/finder_info.txt
MKTMPCMD="mktemp -d -p $TMPTOP"

# is this the dev system?
if [ -f /apps/bfmartin.ca-other/service/finder_info.txt-gerty ]; then
    TMPTOP=/tmp
    INFOFILE=/apps/bfmartin.ca-other/service/finder_info.txt-gerty
    MKTMPCMD="mktemp -d --tmpdir=$TMPTOP"
fi

# temporary files
TMPDIR=`$MKTMPCMD`
SQL=$TMPDIR/run.sql
LOAD=$TMPDIR/load.txt

# read the dbinfo file and split it into fields to the INFOARR array
if [ ! -f $INFOFILE ]; then
    echo $INFOFILE not found. exiting....
    exit 1
fi

# remove p: from the host if any. p: is used by php to denote
# persistent connections but we don't need it here
info=`cat $INFOFILE | sed s/p://`
set -- "$info"
declare -a INFOARR=($*)

TOP="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"/..
cd $TOP

# download and format dialog
rake dialog:prepare
# download strips.json
wget -q -O $TOP/data/dsistrips.json https://raw.github.com/bfmartin/finder_dsi/master/data/dsistrips.json

# generate data
$TOP/bin/finder-load.rb > $LOAD

cat <<EOF >$SQL
start transaction;
delete from dsi;
load data local infile '$LOAD'
   replace into table dsi
   fields terminated by '\t'
   lines terminated by '\n'
   (id, pubdate, title, chars, keywords, dialog, bookid, bookname,
    page, title_stem, keywords_stem, dialog_stem);
commit;
EOF

CMD="mysql -h ${INFOARR[0]} -u ${INFOARR[1]} --password=${INFOARR[2]} ${INFOARR[3]}"
# echo $CMD
$CMD < $SQL

# remove the temp dir
rm -rf $TMPDIR
