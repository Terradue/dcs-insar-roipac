Running ROI_PAC on a Sandbox
=

This repository contains the application files and scripts to process a pair of Envisat ASAR data with ROI\_PAC (Repeat Orbit Interferometry PACkage), a software package created by the Jet Propulsion Laboratory division of NASA and CalTech for processing SAR images to create InSAR images, named interferograms [Wikipedia](http://en.wikipedia.org/wiki/ROI_PAC)

To run this application, you will need a Developer Cloud Sandbox that can be requested from the ESA RSS Portal (http://eogrid.esrin.esa.int/cloudtoolbox/) for ESA G-POD related projects and ESA registered user accounts, or directly from Terradue's Portal (http://www.terradue.com/partners), provided user registration approval. 



### Installation

1 Start a CentOS6.5 sandbox from the Developer Cloud Sandbox marketplace, call it `Sandbox roi_pac`

2 Start a DEM generation appliance from the Developer Cloud Sandbox marketplace, call it `Sandbox dem`

3 Install ROI_PAC 

ROI_PAC is installed using yum. It is a package available on the sandbox software repository.

> ROI_pac is copyrighted software that requires a license. Licenses are available at no charge for non-commercial use from [Open Channel Foundation](http://www.openchannelfoundation.org/projects/ROI_PAC). Comply with the ROI\_PAC license by registering and getting a copy of ROI_PAC.

```
sudo yum install roi_pac.x86_64
```

4 Application deployment

Use `ciop-github` to clone the repository in the `application` volume:

```
ciop-github clone -g https://github.com/Terradue/roi_pac.git
```

### Getting started

We will process an Envisat pair from 2010 Baja California earthquake.

The application is described in the Application Descriptor file (application.xml), it describes two processing nodes:
* processing step `dem`
* processing step `roipac`

#### Processing step `dem`

The processing step `dem` takes the two Envisat ASAR datasets references:

* http://catalogue.terradue.int/catalogue/search/ASA_IM__0P/ASA_IM__0CNPDE20100502_175016_000000172089_00084_42723_0354.N1/rdf
* http://catalogue.terradue.int/catalogue/search/ASA_IM__0P/ASA_IM__0CNPDE20100328_175019_000000162088_00084_42222_9504.N1/rdf

> These products are also available on the European Space Agency (ESA) virtual archive available at http://eo-virtual-archive4.esa.int/search/ASA_IM__0P/html?startIndex=0&start=2010-03-28&stop=2010-05-02&bbox=-116,30,-112,33&track=[084,084]
Browsing for data does not require registering while downloading the data requires an ESA UM-SSO account (a few steps starting here http://eosupport.eo.esa.int/sso/registration.php)

The `dem` processing tasks are: 

* invoke the `Sandbox dem` WPS service with one of the ASAR product reference
* parse the `Sandbox dem` WPS result to grep the URL to the DEM 
* pass the ASAR dataset and DEM references to the `roi_pac` processing step

> The processing step `dem` uses the `Sandbox dem` to generate a DEM spanning 1 degree in all directions from the ASAR product's centroid. The `Sandbox dem` WPS service access point is defined in the file application.xml, edit it with the `Sandbox dem` IP.

The processing step `dem` produces references to 

* The ASAR datasets
  * http://catalogue.terradue.int/catalogue/search/ASA_IM__0P/ASA_IM__0CNPDE20100502_175016_000000172089_00084_42723_0354.N1/rdf
  * http://catalogue.terradue.int/catalogue/search/ASA_IM__0P/ASA_IM__0CNPDE20100328_175019_000000162088_00084_42222_9504.N1/rdf 
* the DEM  

#### Processing step `roipac`

The `roipac` processing step takes as inputs the references to the `dem` processing step outputs to generate the interferogram out of the Envisat ASAR pair of products.

The `roipac` processing tasks are: 

* Copy the generated DEM to the working directory 
* For each of the Envisat ASAR products:
 * Copy the product to the working directory
 * Invoke ROI\_PAC's `make_raw_envi.pl` script to convert to the RAW format
* Generate the ROI\_PAC proc file
* Invoke ROI\_PAC's `process_2pass.pl` script to generate the interferogramme  


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
