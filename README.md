Cloud processing with Envisat ASAR data and ROI_PAC
=

<a href="http://dx.doi.org/10.5281/zenodo.10015"><img src="https://zenodo.org/badge/doi/10.5281/zenodo.10015.png"></a>

This repository contains the application files and scripts to process a pair of Envisat ASAR data with ROI\_PAC (Repeat Orbit Interferometry PACkage), a software package created by the Jet Propulsion Laboratory division of NASA and CalTech for processing SAR images to create InSAR (Interferometric synthetic aperture radar) images, named interferograms. This geodetic method uses two or more synthetic aperture radar (SAR) images to generate maps of surface deformation or digital elevation, using differences in the phase of the waves returning to the satellite or aircraft. The technique can potentially measure centimetre-scale changes in deformation over spans of days to years. It has applications for geophysical monitoring of natural hazards, for example earthquakes, volcanoes and landslides, and in structural engineering, in particular monitoring of subsidence and structural stability.

To run this application, you will need a Developer Cloud Sandbox that can be either requested from the ESA [Research & Service Support Portal](http://eogrid.esrin.esa.int/cloudtoolbox/) for ESA G-POD related projects and ESA registered user accounts, or directly from Terradue's [Portal](http://www.terradue.com/partners), provided user registration approval. 

A Developer Cloud Sandbox provides Earth Science data access services, and assistance tools for a user to implement, test and validate his application.
It runs in two different lifecycle modes: Sandbox mode and Cluster mode. 
Used in Sandbox mode (single virtual machine), it supports cluster simulation and user assistance functions in building the distributed application.
Used in Cluster mode (collections of virtual machines), it supports the deployment and execution of the application with the power of distributed computing processing over large datasets (leveraging the Hadoop Streaming MapReduce technology). 


### Installation

1. Log on the `app roi_pac` sandbox via SSH

2. Install ROI_PAC 

ROI_PAC is installed using yum. It is a package available on the sandbox software repository.

> ROI_pac is copyrighted software that requires a license. Licenses are available at no charge for non-commercial use from [Open Channel Foundation](http://www.openchannelfoundation.org/projects/ROI_PAC). Comply with the ROI\_PAC license by registering and getting a copy of ROI_PAC.

```
sudo yum install roi_pac.x86_64
```

3 Application deployment

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

* invoke the _strm dem_ WPS service with one of the ASAR product reference
* parse the _strm dem_ WPS result to grep the URL to the DEM 
* pass the ASAR dataset and DEM references to the `roipac` processing step

> The processing step `dem` uses the `strm dem` to generate a DEM spanning 1 degree in all directions from the ASAR product's centroid. The _strm dem_ WPS service access point is defined in the file application.xml.

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

### Running the application 

#### Run the processing steps one after the other:

From the `Sandbox roi_pac` shell, to submit the execution of the worklflow node `node_dem` run:

`$ ciop-simjob -f node_dem`

Then, with the inputs from the above `node_dem` execution, the `node_roipac` can be submitted: 

`$ ciop-simjob -f node_roipac`

#### Run the processing steps in a single step:

`$ ciop-simwf`

This will submit the complete worflow with nodes `node_dem` and `node_roipac`

#### Run the processing service via the dashboard

The Sandbox dashboard allows submitting and monitoring an OGC WPS request with a GUI

On a Browser:
* Type the address http://sandbox_ip/dashboard
* Click the Invoke tab
* Fill the processing request 
* Submit the process by clicking "Run"

#### Run the processing service via OGC WPS

Using HTTP GET request with `curl`

`curl http://sandbox_ip/wps/?service=WPS&request=Execute&version=1.0.0&Identifier=&storeExecuteResponse=true&status=true&DataInputs=sar1=http://catalogue.terradue.int/catalogue/search/ASA_IM__0P/ASA_IM__0CNPDE20100502_175016_000000172089_00084_42723_0354.N1/rdf;sar2=http://catalogue.terradue.int/catalogue/search/ASA_IM__0P/ASA_IM__0CNPDE20100328_175019_000000162088_00084_42222_9504.N1/rdf`

Using HTTP POST request with `curl`

TBW

### Learn more

* How to run a [ROI\_PAC on a Sandbox wiki](https://github.com/Terradue/roi_pac/wiki)
* About ROI\_PAC software on [calTech Wiki](http://roipac.org/cgi-bin/moin.cgi), [Open Channel Foundation](http://www.openchannelfoundation.com/projects/ROI_PAC/index.html), [Cornell University](http://www.geo.cornell.edu/eas/PeoplePlaces/Faculty/matt/roi_pac.html/) and the [Georgia Institute of Technology guide](http://shadow.eas.gatech.edu/~anewman/classes/MGM/InSAR/index.html)


### References

* [Developer Cloud Sandbox](https://support.terradue.com/projects/devel-cloud-sb/wiki)
* [ESA Virtual Archive - access SAR data](http://eo-virtual-archive4.esa.int/)
* [SSEP CloudToolbox](http://eogrid.esrin.esa.int/cloudtoolbox/) to request a Developer Cloud Sandbox PaaS and run this application
* [ROI_PAC Web Site](http://www.roipac.org/ROI_PAC)
* [Wikipedia](http://en.wikipedia.org/wiki/ROI_PAC).

