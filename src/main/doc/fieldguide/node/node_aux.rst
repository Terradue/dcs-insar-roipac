Node node_aux
=============

The aux job template defines the streaming executable and the wall time.

The job template includes the path to the streaming executable.

.. literalinclude:: ../src/src/main/app-resources/application.xml
  :language: xml
  :tab-width: 1
  :lines: 6
  
The job template defines a single parameter:

+----------------+------------------------------------------------+--------------------------------------------------------------------------+
| Parameter name | Default value                                  | Description                                                              | 
+================+================================================+==========================================================================+
| aux_catalogue  | http://catalogue.terradue.int/catalogue/search | URL to the OpenSearch catalogue containing the auxliary and orbital data | 
+----------------+------------------------------------------------+--------------------------------------------------------------------------+

which translates to:

.. literalinclude:: ../src/src/main/app-resources/application.xml
  :language: xml
  :tab-width: 1
  :lines: 7-13

The job template set the property ciop.job.max.tasks so have a single instance of this process:

.. literalinclude:: ../src/src/main/app-resources/application.xml
  :language: xml
  :tab-width: 1
  :lines: 14-16

Here's the job template including the elements described above:

.. literalinclude:: ../src/src/main/app-resources/application.xml
  :language: xml
  :tab-width: 1
  :lines: 4-18


The streaming executable implements the activities:

.. uml::

  !define DIAG_NAME Workflow example

  !include includes/skins.iuml

  skinparam backgroundColor #FFFFFF
  skinparam componentStyle uml2

  start

  :Source libraries;
  
  :Get auxiliary catalogue parameter value;
  
   while (check stdin?) is (line)
    :Get references to ASA_CON_AX ASA_INS_AX ASA_XCA_AX ASA_XCH_AX DOR_VOR_AX;
    :Stage-out references to ASA_CON_AX ASA_INS_AX ASA_XCA_AX ASA_XCH_AX DOR_VOR_AX;
  endwhile (empty)
  
  stop

The streaming executable source is available here: `/application/auxc/run.sh <https://github.com/Terradue/InSAR-ROI_PAC/blob/master/src/main/app-resources/aux/run.sh>`_
