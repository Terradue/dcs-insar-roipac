#!/bin/bash
 
# source the ciop functions (e.g. ciop-log)
source ${ciop_job_include}

# define the exit codes
SUCCESS=0
ERR_INVALIDFORMAT=2
ERR_NOIDENTIFIER=5
ERR_NODEM=7

# add a trap to exit gracefully
function cleanExit ()
{
local retval=$?
local msg=""
case "$retval" in
$SUCCESS) msg="Processing successfully concluded";;
$ERR_INVALIDFORMAT) msg="Invalid format must be roi_pac or gamma";;
$ERR_NOIDENTIFIER) msg="Could not retrieve the dataset identifier";;
$ERR_NODEM) msg="DEM not generated";;
*) msg="Unknown error";;
esac
[ "$retval" != "0" ] && ciop-log "ERROR" "Error $retval - $msg, processing aborted" || ciop-log "INFO" "$msg"
exit $retval
}
trap cleanExit EXIT

export PATH=/application/dem/bin:$PATH 

cat | grep rdf > $TMPDIR/input 
cp $TMPDIR/input /tmp

ciop-log "DEBUG" "input contains: `cat $TMPDIR/input`"

# invoke the DEM generation WPS process
wpsdem="`ciop-getparam dem_access_point`"

set -x

wpsclient -e \
          -u $wpsdem \
          -t 5000 \
          -a \
          -p com.terradue.wps_oozie.process.OozieAbstractAlgorithm \
          -Iformat="roi_pac" \
          -ILevel0_ref="`head -n 1 $TMPDIR/input`" \
          -f $TMPDIR/result 1>&2

cp $TMPDIR/result /tmp
          
# extract the result URL
curl -L -s "`cat $TMPDIR/result | xsltproc /application/dem/xslt/getresult.xsl -`" | xsltproc /application/dem/xslt/metalink.xsl - | grep http | xargs -i curl -L -s {} -o $TMPDIR/dem.tgz 

# publish the dem archive
dem_url=`ciop-publish $TMPDIR/dem.tgz`

ciop-log "DEBUG" "DEM HDFS path: $dem_url"

# create the input for the next job with references to both ASAR data and DEM reference
cat $TMPDIR/input | while read line
do
	echo "sar=$line"
done

echo "DEM=$dem_url"


