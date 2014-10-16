Two pass processing with ROI_PAC
================================

This application processes a pair of Envisat ASAR data with ROI_PAC (Repeat Orbit Interferometry PACkage), a software package created by the Jet Propulsion Laboratory division of NASA and CalTech for processing SAR images to create InSAR images, named interferograms. 

Read more about `ROI_PAC on Wikipedia <http://en.wikipedia.org/wiki/ROI_PAC>`_.

This field guide has a two-fold objective:

* Implement a Web Processing Service to generate an interferogram using ROI_PAC:

  * Generate a Digital Elevation Model (DEM) 
  * Get the Envisat ASAR auxiliary and orbital data
  * Generate the interferogram

* Demonstrate how to use an external WPS service within a workflow:

  * The DEM generation external WPS service is invoked as a node of the processing workflow 

.. Contents:

.. toctree::
    :maxdepth: 1
   
    What you will learn <learn>
    Addressing a scientific and processing goal <goal>
    Rationales for the processing chain <rational>
    Data preparation <data>
    Workflow design <workflow>
    Processing nodes design <nodes>
    Application integration and testing <testing>
    Application exploitation <exploitation <exploitation>
    Going further <further>
