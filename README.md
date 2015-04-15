## Developer Cloud Sandbox interferogram processing with ROI_PAC

<a href="http://dx.doi.org/10.5281/zenodo.10015"><img src="https://zenodo.org/badge/doi/10.5281/zenodo.10015.png"></a>

This repository contains the application files and scripts to process a pair (Master and Slave) of Envisat ASAR data with [ROI_PAC](http://www.openchannelfoundation.org/projects/ROI_PAC) (Repeat Orbit Interferometry PACkage), a software package jointly created by the Jet Propulsion Laboratory division of NASA and CalTech for processing SAR data to create InSAR (Interferometric synthetic aperture radar) images, or 'interferograms'. This geodetic method uses two or more synthetic aperture radar (SAR) scenes to generate maps of surface deformation or digital elevation models, using differences in the phase of the waves returning to the radar sensor. The technique can potentially measure centimetre-scale changes in deformation over spans of days to years. It has applications for geophysical monitoring of natural hazards, for example earthquakes, volcanoes and landslides, and in structural engineering, in particular monitoring of subsidence and structural stability.

## Quick link

* [Getting Started](#getting-started)
* [Installation](#installation)
* [Submitting the workflow](#submit)
* [Community and Documentation](#community)
* [Authors](#authors)
* [Questions, bugs, and suggestions](#questions)
* [License](#license)

### <a name="getting-started"></a>Getting Started

To run this application you will need a Developer Cloud Sandbox, that can be either requested from:
* ESA [Geohazards Exploitation Platform](https://geohazards-tep.eo.esa.int) for GEP early adopters;
* ESA [Research & Service Support Portal](http://eogrid.esrin.esa.int/cloudtoolbox/) for ESA G-POD related projects and ESA registered user accounts
* From [Terradue's Portal](http://www.terradue.com/partners), provided user registration approval.

A Developer Cloud Sandbox provides Earth Sciences data access services, and helper tools for a user to implement, test and validate a scalable data processing application. It offers a dedicated virtual machine and a Cloud Computing environment.
The virtual machine runs in two different lifecycle modes: Sandbox mode and Cluster mode.
Used in Sandbox mode (single virtual machine), it supports cluster simulation and user assistance functions in building the distributed application.
Used in Cluster mode (a set of master and slave nodes), it supports the deployment and execution of the application with the power of distributed computing for data processing over large datasets (leveraging the Hadoop Streaming MapReduce technology).

### <a name="installation"></a>Installation

#### Pre-requisites

ROI-PAC is a software package available through the Terradue Cloud Platform software repository.

> ROI_PAC is a copyrighted software that requires a license. Licenses are available at no charge for non-commercial use from the [Open Channel Foundation](http://www.openchannelfoundation.org/projects/ROI_PAC). Read the [license terms](http://www.openchannelfoundation.org/project/print_license.php?group_id=282&license_id=61).

```
sudo yum install roi_pac.x86_64 roi_pac-grdfile.x86_64
```

##### Using the releases

Log on the developer cloud sandbox. Download the RPM package from https://github.com/geohazards-tep/InSAR-ROI_PAC/releases.
Install the downloaded package by running these commands in a shell:

```bash
sudo yum -y install InSAR-ROI_PAC-<version>-ciop.x86_64.rpm
```

#### Using the development version

Log on the developer sandbox and run these commands in a shell:

```bash
cd
git clone git@github.com:geohazards-tep/InSAR-ROI_PAC.git
git checkout develop
cd InSAR-ROI_PAC
mvn install
```

### <a name="submit"></a>Submitting the workflow

Run this command in a shell:

```bash
ciop-run
```
Or invoke the Web Processing Service via the Sandbox dashboard or the [Geohazards Thematic Exploitation platform](https://geohazards-tep.eo.esa.int) providing a master and a slave products' URL, e.g.:

* http://catalogue.terradue.int/catalogue/search/ASA_IM__0P/ASA_IM__0CNPDE20090412_092426_000000162078_00079_37207_1556.N1/rdf (master)
* http://catalogue.terradue.int/catalogue/search/ASA_IM__0P/ASA_IM__0CNPAM20080427_092430_000000172068_00079_32197_3368.N1/rdf (slave)

To learn more and find information go to

* [Developer Cloud Sandbox](http://docs.terradue.com/developer) service
* [InSAR ROI_PAC](http://docs.terradue.com/developer/field/insar/tp_roi_pac) field guide chapter
* [ESA Geohazards Exploitation Platform](https://geohazards-tep.eo.esa.int)

### <a name="authors"></a>Authors (alphabetically)

* Francesco Barchetta
* Fabrice Brito
* Fabio D'Andria
* Emmanuel Mathot
* Cesare Rossi

### <a name="questions"></a>Questions, bugs, and suggestions

Please file any bugs or questions as [issues](https://github.com/geohazards-tep/InSAR-ROI_PAC/issues/new) or send in a pull request.

### <a name="license"></a>License

Copyright 2015 Terradue Srl

Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
