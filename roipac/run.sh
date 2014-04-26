#!/bin/bash
 
# source the ciop functions (e.g. ciop-log)
source ${ciop_job_include}

# define the exit codes
SUCCESS=0
ERR_AUX=4
ERR_VOR=6
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
$ERR_AUX) msg="Failed to retrieve auxiliary products";;
$ERR_INVALIDFORMAT) msg="Invalid format must be roi_pac or gamma";;
$ERR_NOIDENTIFIER) msg="Could not retrieve the dataset identifier";;
$ERR_NODEM) msg="DEM not generated";;
*) msg="Unknown error";;
esac
[ "$retval" != "0" ] && ciop-log "ERROR" "Error $retval - $msg, processing aborted" || ciop-log "INFO" "$msg"
exit $retval
}
trap cleanExit EXIT

export TMPDIR=/tmp/wd2

# prepare ROI_PAC environment variables
export INT_BIN=/usr/bin/
export INT_SCR=/usr/share/roi_pac
export PATH=${INT_BIN}:${INT_SCR}:${PATH}

export SAR_ENV_ORB=/application/roipac/aux/asar/
export VOR_DIR=/application/roipac/aux/vor/
export INS_DIR=$SAR_ENV_ORB

cat > $TMPDIR/input

# retrieve the aux files

mkdir -p $TMPDIR/aux
for input in `cat $TMPDIR/input | grep aux` 
do
  echo $input | ciop-copy -O $TMPDIR/aux -

  res=$?
  
  [ $res != 0 ] && exit $ERR_AUX
done

# retrieve the orbit data
mkdir -p $TMPDIR/vor
for input in `cat $TMPDIR/input | grep vor` 
do
  echo $input | ciop-copy -O $TMPDIR/vor -

  res=$?
  
  [ $res != 0 ] && exit $ERR_VOR
done

# retrieve all inputs, the two ASAR products and the DEM
mkdir -p $TMPDIR/workdir/dem

dem_url=`cat $TMPDIR/input | grep DEM | cut -d "=" -f 2`
ciop-log "DEBUG" "DEM URL: $dem_url"

ciop-copy -o $TMPDIR/workdir/dem/ $dem_url

dem="`find $TMPDIR/workdir/dem -name "*.dem"`"

roipac_proc=$TMPDIR/workdir/roi_pac.proc

for input in `cat $TMPDIR/input | grep sar` 
do
  sar_url=`echo $input | cut -d "=" -f 2`

  # get the date in format YYMMDD
  sar_date=`ciop-casmeta -f "ical:dtstart" $sar_url | cut -c 3-10 | tr -d "-"`
  sar_date_short=`echo $sar_date | cut -c 1-4`
  ciop-log "INFO" "SAR date: $sar_date and $sar_date_short"

  # get the dataset identifier
  sar_identifier=`ciop-casmeta -f "dc:identifier" $sar_url`
  ciop-log "INFO" "SAR identifier: $sar_identifier"

  sar_folder=$TMPDIR/workdir/$sar_date 
  mkdir -p $sar_folder
  
  # get ASAR products
  sar="`ciop-copy -o $sar_folder $sar_url`"

  cd $sar_folder
  ciop-log "DEBUG" "make_raw_envi.pl $sar_identifier DOR $sar_date"
  make_raw_envi.pl $sar_identifier DOR $sar_date 1>&2 

  if [ ! -e "$roipac_proc" ]
  then 
    echo "SarDir1=$sar_date" > $roipac_proc 
    intdir="int_$sar_date"
    geodir="geo_$sar_date_short"
  else    
    echo "SarDir2=$sar_date" >> $roipac_proc
    intdir=${intdir}_$sar_date
    geodir=${geodir}-${sar_date_short}
  fi
done

# generate ROI_PAC proc file
cat >> $roipac_proc << EOF
IntDir=$intdir
SimDir=sim_3asec
# new sim for this track at 4rlks
do_sim=yes
GeoDir=$geodir

# standard pixel ratio for Envisat beam I2
pixel_ratio=5

FilterStrength=0.6
UnwrappedThreshold=0.05

OrbitType=HDR
Rlooks_int=4
Rlooks_unw=4
Rlooks_sim=4

#flattening=topo
flattening=orbit

# run focusing on both scenes at the same time
concurrent_roi=yes

# little-endian DEM
DEM=$dem
MODEL=NULL
cleanup=no

#unw_method=snaphu_mcf
#unw_method=icu
unw_method=old

EOF

cd $TMPDIR/workdir

process_2pass.pl $roipac_proc 1>&2

ciop-log "INFO" "Compressing results" 
tar cvfz $intdir.tgz $intdir
tar cvfz $geodir.tgz $geodir
tar cvfz sim_3asec.tgz sim_3asec

ciop-log "INFO" "That's all folks"


