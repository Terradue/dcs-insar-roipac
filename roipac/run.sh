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

# prepare ROI_PAC environment variables
export INT_BIN=/usr/bin/
export INT_SCR=/usr/share/roi_pac
export PATH=${INT_BIN}:${INT_SCR}:${PATH}

export SAR_ENV_ORB=/application/roipac/aux/asar/
export VOR_DIR=/application/roipac/aux/vor/

cat > $TMPDIR/input
 
# retrieve all inputs, the two ASAR products and the DEM
mkdir -p $TMPDIR/workdir/dem

dem_url=`sed '3q;d' $TMPDIR/input`
dem="`ciop-copy -o $TMPDIR/workdir/dem $dem_url`"

roipac_proc=$TMPDIR/workdir/roi_pac.proc

for sar_url in `head -n 2 $TMPDIR/input
do
  # get the date in format YYMMDD
  sar_date=`ciop-casmeta -f "ical:dtstart" $sar_url | cut -c 3-10 | tr -d "-"`
  sar_identifier=`ciop-casmeta -f "dc:identifier" $sar_url`

  sar_folder=$TMPDIR/workdir/$sar_date 
  mkdir -p $sar_folder
  
  # get ASAR products
  sar="`ciop-copy -o $sar_folder $sar_url`"

  cd $sar_folder
  make_raw_envi.pl $sar_identifier DOR $sardate 1>&2 

  if [ ! -e "$roipac_proc" ]
  then 
    echo "SarDir1=$sardate" > $roipac_proc 
    intdir="int_$sardate"
    geodir="geo_$sardate"
  else    
    echo "SarDir2=$sardate" >> $roipac_proc
    intdir=${intdir}_$sardate
    geodir=${geodir}_$sardate"
done

# generate ROI_PAC proc file
echo >> $roipac_proc < EOF
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

cp $roipac_proc /tmp
cd $TMPDIR/workdir
process_2pass.pl $roipac_proc
  
