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

cat > $TMPDIR/input 

# invoke the DEM generation WPS process
wpsdem="`ciop-getparam dem_access_point`"

wpsclient -e \
          -u $wpsdem
          -t 5000 \
          -a \
          -p com.terradue.wps_oozie.process.OozieAbstractAlgorithm \
          -Iformat="roi_pac" \
          -ILevel0_ref="`head -n 1 $TMPDIR/input`" \
          -f $TMPDIR/result
          
# extract the result URL
curl -O $TMPDIR/dem.tgz `cat $TMPDIR/result | xsltproc /application/dem/xslt/getresult.xsl -`

# publish the dem archive
dem_url=`ciop-publish $TMPDIR/dem.tgz`

# create the input for the next job with references to both ASAR data and DEM reference
ciop-publish -s "`cat $TMPDIR/input | tr '\n' ','`,$dem_url"


