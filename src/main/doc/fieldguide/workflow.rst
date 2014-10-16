Workflow design
===============

Data 
****

You will use Envisat ASAR Image Mode Level 0: two acquisitions over the Baja area, on before and one after the 2010 Baja California earthquake.

An Advanced Synthetic Aperture Radar (ASAR), operating at C-band, ASAR ensured continuity with the image mode (SAR) and the wave mode of the ERS-1/2 AMI. It featured enhanced capability in terms of coverage, range of incidence angles, polarisation, and modes of operation. 
This enhanced capability was provided by significant differences in the instrument design: a full active array antenna equipped with distributed transmit/receive modules which provided distinct transmit and receive beams, a digital waveform generation for pulse "chirp" generation, a block adaptive quantisation scheme, and a ScanSAR mode of operation by beam scanning in elevation.

See :doc:`Data preparation <data>` section for details on the Envisat ASAR data used in this guide.

Software and COTS
*****************

ROI_PAC
-------

You will use the Repeat Orbit Interferometry PACkage (ROI_PAC)[#f1]_, software for processing synthetic aperture radar data to produce differential interferograms. Licenses available at no charge for non-commercial use. 

Workflow structure
------------------

The workflow contains three processing steps to:

* Retrieve the Envisat ASAR auxiliary products ( ) and orbital data ()
* Retrieve a Digital Elevation Model (DEM) using STRM3 data over the area covered by one of the ASAR acquisitions (the DEM generation application is available at: https://github.com/Terradue/srtm-dem)
* Invoke the make_raw_envi on each of the ASAR products; create the ROI_PAC proc file and invoke the process_2pass.pl

.. uml::

  !define DIAG_NAME Workflow example

  !include includes/skins.iuml

  skinparam backgroundColor #FFFFFF
  skinparam componentStyle uml2

  start

  fork
    :node_aux;
    :node_dem;
  end fork
  
  :node_roi_pac;
  
  stop

.. [#f1] `ROI_PAC Website <http://aws.roipac.org/cgi-bin/moin.cgi>`_
.. [#f2] `Shuttle Radar Topography Mission (SRTM) <http://www2.jpl.nasa.gov/srtm/>`_
