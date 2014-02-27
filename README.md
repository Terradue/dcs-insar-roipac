Running ROI_PAC on a Sandbox
=

Repeat Orbit Interferometry PACkage (ROI\_PAC) is a software package created by the Jet Propulsion Laboratory division of NASA and CalTech for processing SAR images to create InSAR images, named interferograms [Wikipedia](http://en.wikipedia.org/wiki/ROI_PAC)



### Pre-requisites


1 Start a CentOS6.5 sandbox from the Developer Cloud Sandbox marketplace 

2 Start a DEM generation appliance from the Developer Cloud Sandbox marketplace 

3 Install FFTW 

```
sudo yum install fftw.x86_64 fftw-static.x86_64 fftw-devel.x86_64
```

4 Install ROI_PAC 

ROI_PAC is installed using yum. It is a package available on the sandbox software repository.

> ROI_pac is copyrighted software that requires a license. Licenses are available at no charge for non-commercial use from [Open Channel Foundation](http://www.openchannelfoundation.org/projects/ROI_PAC). Comply with the ROI\_PAC license by registering and getting a copy of ROI_PAC.

```
sudo yum install roi_pac.x86_64
```

### Application deployment

Use `ciop-github` to clone the repository in the `application` volume:

```
ciop-github clone -g https://github.com/Terradue/roi_pac.git
```

Check the contents of `/application` with:

```
ls -la /application
```

All files from the repo have been cloned locally in /application.

> the CIOP Toolbox `ciop-github` utility allows cloning this repository to the `/application` filesystem. Once clone, the usual git commands (add, commit, push, etc.) can be used as for any other github repository

### Understanding the processing steps

#### Processing step `dem`

##### Inputs

The processing step `dem` takes the two Envisat ASAR datasets references:

* http://catalogue.terradue.int/catalogue/search/ASA_IM__0P/ASA_IM__0CNPDE20100502_175016_000000172089_00084_42723_0354.N1/rdf
* http://catalogue.terradue.int/catalogue/search/ASA_IM__0P/ASA_IM__0CNPDE20100328_175019_000000162088_00084_42222_9504.N1/rdf

These products are also available on the European Space Agency (ESA) virtual archive available at http://eo-virtual-archive4.esa.int/ 

Browsing for data does not require registering while downloading the data requires an ESA UM-SSO account (a few steps starting here http://eosupport.eo.esa.int/sso/registration.php)

The query URL on the virtual archive is:

http://eo-virtual-archive4.esa.int/search/ASA_IM__0P/html?startIndex=0&start=2010-03-28&stop=2010-05-02&bbox=-116,30,-112,33&track=[084,084]

##### Parameters

The processing step `dem` uses the DEM generation appliance OGC WPS service to generate a DEM spanning 1 degree in all directions from the ASAR product centroid.

The processing step `dem` needs the DEM generation appliance OGC WPS service access point:

http://<DEM generation appliance IP>:8080/wps/WebProcessingService

##### Pseudo-code

* invoke the DEM generation appliance OGC WPS service with one of the ASAR product reference
* parse the DEM generation appliance OGC WPS result to grep the URL to the DEM 
* pass the ASAR dataset and DEM references to the `roi_pac` processing step

##### Output

The processing step `dem` produces references to 

* The ASAR datasets
  * http://catalogue.terradue.int/catalogue/search/ASA_IM__0P/ASA_IM__0CNPDE20100502_175016_000000172089_00084_42723_0354.N1/rdf
  * http://catalogue.terradue.int/catalogue/search/ASA_IM__0P/ASA_IM__0CNPDE20100328_175019_000000162088_00084_42222_9504.N1/rdf 
* the DEM 

#### Processing step `roi_pac`

##### Inputs

##### Parameters

##### Pseudo-code

##### Output

#### Future work

##### Auxiliary and orbital data

The auxiliary and orbital data are contained in the repository. This is not practical for processing time-series of interferograms. 
To overcome this, the `roi_pac` step could be enhanced to pick-up the auxiliary and orbital data needed for each pair of ASAR data from a virtual archive with temporal queries:

* get the ASAR product start and stop times
* query the catalogue for all needed auxiliary data using the times above as time of interest
* download the auxiliary data locally 
* repeat the approach for the orbital data

##### More improvements 

#### Exploitation 

This application can be exploited as an OGC Web Processing Service and scale-up on Cloud computing resources to produce interferograms that can be used as input in other toolboxes such as [STAMPS](http://homepages.see.leeds.ac.uk/~earahoo/stamps/) or [GIAnT](ftp://ftp.gps.caltech.edu/pub/piyush/AGU_giant_high.pdf).

### References

* [Developer Cloud Sandbox](https://support.terradue.com/projects/devel-cloud-sb/wiki)
* [ESA Virtual Archive - access SAR data](http://eo-virtual-archive4.esa.int/)
* [ROI_PAC Web Site](http://www.roipac.org/ROI_PAC)
