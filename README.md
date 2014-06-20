Cloud processing with Envisat ASAR data and ROI_PAC
=

<a href="http://dx.doi.org/10.5281/zenodo.10015"><img src="https://zenodo.org/badge/doi/10.5281/zenodo.10015.png"></a>

This repository contains the application files and scripts to process a pair of Envisat ASAR data with ROI_PAC (Repeat Orbit Interferometry PACkage), a software package created by the Jet Propulsion Laboratory division of NASA and CalTech for processing SAR images to create InSAR (Interferometric synthetic aperture radar) images, named interferograms. This geodetic method uses two or more synthetic aperture radar (SAR) images to generate maps of surface deformation or digital elevation, using differences in the phase of the waves returning to the satellite or aircraft. The technique can potentially measure centimetre-scale changes in deformation over spans of days to years. It has applications for geophysical monitoring of natural hazards, for example earthquakes, volcanoes and landslides, and in structural engineering, in particular monitoring of subsidence and structural stability.

### Getting Started 

To run this application, you will need a Developer Cloud Sandbox that can be either requested from the ESA [Research & Service Support Portal](http://eogrid.esrin.esa.int/cloudtoolbox/) for ESA G-POD related projects and ESA registered user accounts, or directly from [Terradue's Portal](http://www.terradue.com/partners), provided user registration approval. 

A Developer Cloud Sandbox provides Earth Science data access services, and assistance tools for a user to implement, test and validate his application.
It runs in two different lifecycle modes: Sandbox mode and Cluster mode. 
Used in Sandbox mode (single virtual machine), it supports cluster simulation and user assistance functions in building the distributed application.
Used in Cluster mode (collections of virtual machines), it supports the deployment and execution of the application with the power of distributed computing processing over large datasets (leveraging the Hadoop Streaming MapReduce technology). 

### Installation 

Log on the developer sandbox.

Install ROI_PAC using yum. It is a package available on the sandbox software repository.

> ROI_pac is copyrighted software that requires a license. Licenses are available at no charge for non-commercial use from [Open Channel Foundation](http://www.openchannelfoundation.org/projects/ROI_PAC). Comply with the ROI\_PAC license by registering and getting a copy of ROI_PAC.

```
sudo yum install roi_pac.x86_64
```

Run these commands in a shell:

```bash
cd
git clone git@github.com:Terradue/InSAR-ROI_PAC.git
cd InSAR-ROI_PAC
mvn install
```

### Submitting the processing

Invoke the application via its OGC Web Processing Service interface via:

* the sandbox dashboard
* the Browser with a GET request to the WPS access point
* a POST request to the WPS access point

Learn more: [Submitting an application via the WPS interface](http://docs.terradue.com/developer/faq/wps) 


### Community and Documentation

To learn more and find information go to 

* [Developer Cloud Sandbox](http://docs.terradue.com/developer) service 
* [InSAR ROI_PAC](http://docs.terradue.com/developer/field/insar/tp_roi_pac) field guide chapter

### Authors

* Fabio D'Andria
* Francesco Barchetta
* Fabrice Brito
* Emmannuel Mathot

### License

Copyright 2014 Terradue Srl

Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0

