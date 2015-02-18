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
        $ERR_VOR) msg="Failed to retrieve orbital data";;
        $ERR_INVALIDFORMAT) msg="Invalid format must be roi_pac or gamma";;
        $ERR_NOIDENTIFIER) msg="Could not retrieve the dataset identifier";;
        $ERR_NODEM) msg="DEM not generated";;
        *) msg="Unknown error";;
    esac

    [ "$retval" != "0" ] && ciop-log "ERROR" "Error $retval - $msg, processing aborted" || ciop-log "INFO" "$msg"
    exit $retval
}

trap cleanExit EXIT

# create a shorter TMPDIR name for some ROI_PAC scripts/binaires 
UUIDTMP="/tmp/`uuidgen`"
#ln -s $TMPDIR $UUIDTMP
mkdir ${UUIDTMP}
export TMPDIR=$UUIDTMP

ciop-log "DEBUG" "working in tmp dir [${TMPDIR}]"

# prepare ROI_PAC environment variables
export INT_BIN=/usr/bin/
export INT_SCR=/usr/share/roi_pac
export PATH=${INT_BIN}:${INT_SCR}:${PATH}

export SAR_ENV_ORB=$TMPDIR/aux
export VOR_DIR=$TMPDIR/vor
export INS_DIR=$SAR_ENV_ORB

cat > $TMPDIR/input

# retrieve the aux files
mkdir -p $TMPDIR/aux
for input in `cat $TMPDIR/input | grep 'aux='` 
do
    ciop-log "DEBUG" "retrieving aux file ${input#aux=}"
    echo ${input#aux=} | ciop-copy -O $TMPDIR/aux - 2> /dev/null
    [ $? -ne 0 ] && exit $ERR_AUX
done

# retrieve the orbit data
mkdir -p $TMPDIR/vor
for input in `cat $TMPDIR/input | grep 'vor='` 
do
    ciop-log "DEBUG" "retrieving orbit file ${input#aux=}"
    echo ${input#vor=} | ciop-copy -O $TMPDIR/vor - 2> /dev/null
    [ $? -ne 0 ] && exit $ERR_VOR
done

# retrieve the DEM
mkdir -p $TMPDIR/workdir/dem
wps_result="$( ciop-browseresults -r ${CIOP_WF_RUN_ID} -j node_dem -w | tr -d '\r' | tr '\n' ';')"
ciop-log "DEBUG" "dem wps results 1 is ${wps_result}"
wps_result=`echo $wps_result | cut -d ";" -f 1`
ciop-log "DEBUG" "dem wps results is ${wps_result}"

# extract the result URL
curl -L -o $TMPDIR/workdir/dem/dem.tgz "${wps_result}" 2> /dev/null
tar xzf $TMPDIR/workdir/dem/dem.tgz -C $TMPDIR/workdir/dem/ 

dem="`find $TMPDIR/workdir/dem -name "*.dem"`"

# the path to the ROI_PAC proc file
roipac_proc=$TMPDIR/workdir/roi_pac.proc

# get all SAR products

for input in `cat $TMPDIR/input | grep 'sar='`
do
    sar_url=`echo $input | sed "s/^sar=//"`

    # get the date in format YYMMDD
    sar_date=`opensearch-client $sar_url startdate | cut -c 3-10 | tr -d "-"`
    sar_date_short=`echo $sar_date | cut -c 1-4`
  
    ciop-log "DEBUG" "SAR input ${sar_url}"
    ciop-log "INFO" "SAR date: $sar_date and $sar_date_short"

    # get the dataset identifier
    sar_identifier=`opensearch-client $sar_url identifier`
    ciop-log "INFO" "SAR identifier: $sar_identifier"

    sar_folder=$TMPDIR/workdir/$sar_date
    mkdir -p $sar_folder
  
    # get ASAR products
    sar_url=`opensearch-client $sar_url enclosure`
    sar="`ciop-copy -o $sar_folder $sar_url`"

    cd $sar_folder
    ciop-log "DEBUG" "make_raw_envi.pl $sar_identifier DOR $sar_date"
    make_raw_envi.pl $sar_identifier DOR $sar_date 1>&2

    if [ ! -e "$roipac_proc" ]
    then
        echo "SarDir1=$sar_date" > $roipac_proc
        intdir="$sar_date"
        sar1="$sar_date"
        geodir="geo_${sar_date_short}"
    else
        echo "SarDir2=$sar_date" >> $roipac_proc
        intdir=${intdir}-${sar_date}
        sar2="$sar_date"
        base=${sar1}_${sar2}
        geodir=${geodir}-${sar_date_short}
    fi
done 

ciop-log "INFO" "Conversion of SAR pair to RAW completed"

ciop-log "INFO" "Generation of ROI_PAC proc file"

# generate ROI_PAC proc file
cat >> $roipac_proc << EOF
IntDir=int_${intdir}
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

ciop-log "INFO" "Invoking ROI_PAC process_2pass"

cd $TMPDIR/workdir
process_2pass.pl $roipac_proc 1>&2
[ $? -ne 0 ] && exit $ERR_PROCESS2PASS

cd int_${intdir}

ciop-log "INFO" "Geocoding the wrapped interferogram"
cpx2rmg  filt_${intdir}-sim_HDR_4rlks.int  filt_${intdir}-sim_HDR_4rlks.int.hgt
geocode.pl geomap_4rlks.trans filt_${intdir}-sim_HDR_4rlks.int.hgt geo_${intdir}.int

ciop-log "INFO" "Creating geotif files for interferogram phase and magnitude"
/usr/bin/roipac2grdfile -t real -i geo_${intdir}.int -r geo_${intdir}.int.rsc -o geo_${intdir}.int.nc
/usr/bin/roipac2grdfile -t real -i geo_${intdir}.unw -r geo_${intdir}.unw.rsc -o geo_${intdir}.unw.nc

gdal_translate NETCDF:"geo_${intdir}.int.nc":phase geo_${intdir}.int.phase.tif
gdal_translate NETCDF:"geo_${intdir}.int.nc":magnitude geo_${intdir}.int.magnitude.tif
gdal_translate NETCDF:"geo_${intdir}.unw.nc":phase geo_${intdir}.unw.phase.tif

ciop-log "INFO" "Publishing results"
ciop-publish -m $TMPDIR/workdir/*.proc

ciop-log "INFO" "Publishing baseline file"
ciop-publish -m $TMPDIR/workdir/int_${intdir}/*_baseline.rsc

ciop-log "INFO" "Publishing multi-look interferograms"
ciop-publish -m $TMPDIR/workdir/int_${intdir}/${intdir}-sim*.int
ciop-publish -m $TMPDIR/workdir/int_${intdir}/${intdir}-sim*.int.rsc

ciop-publish -m $TMPDIR/workdir/int_${intdir}/filt*${intdir}-sim*.int
ciop-publish -m $TMPDIR/workdir/int_${intdir}/filt*${intdir}-sim*.int.rsc

ciop-publish -m $TMPDIR/workdir/int_${intdir}/filt*${intdir}-sim*.unw
ciop-publish -m $TMPDIR/workdir/int_${intdir}/filt*${intdir}-sim*.unw.rsc

ciop-publish -m $TMPDIR/workdir/int_${intdir}/geo_${intdir}.unw
ciop-publish -m $TMPDIR/workdir/int_${intdir}/geo_${intdir}.unw.rsc

ciop-publish -m $TMPDIR/workdir/int_${intdir}/log
ciop-publish -m $TMPDIR/workdir/int_${intdir}/log1

for file in `find . -name "${intdir}*.cor"`
do
    ciop-publish -m $TMPDIR/workdir/int_${intdir}/$file
    ciop-publish -m $TMPDIR/workdir/int_${intdir}/$file.rsc
done

ciop-log "INFO" "Publishing tif files"
ciop-publish -m $TMPDIR/workdir/int_${intdir}/geo_${intdir}.int.phase.tif
ciop-publish -m $TMPDIR/workdir/int_${intdir}/geo_${intdir}.int.magnitude.tif
ciop-publish -m $TMPDIR/workdir/int_${intdir}/geo_${intdir}.unw.phase.tif

ciop-log "INFO" "Publishing full resolution interferogram"
ciop-publish -m $TMPDIR/workdir/int_${intdir}/$intdir.int
ciop-publish -m $TMPDIR/workdir/int_${intdir}/$intdir.int.rsc


rm -fr $UUIDTMP

ciop-log "INFO" "That's all folks"
