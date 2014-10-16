What you will learn
===================

With this field guide application, you will learn:

1. To manage test data in a sandbox - you will copy Envisat ASAR Level 0 Image Mode data to the sandbox
2. To create an application invoking the ROI_PAC to generate an interferogram 
3. To create an application that uses an external WPS service in a workflow
4. To test the application - you will execute the node and workflow and inspect the results
5. To exploit the application - you will create the Web Processing Service (WPS) interface and invoke it

Where is the code
+++++++++++++++++

The code for this tutorial is available on GitHub repository `InSAR-ROI_PAC <https://github.com/Terradue/InSAR-ROI_PAC>`_.

To deploy the tutorial on a Developer Sandbox:

.. code-block:: console

  cd ~
  git clone https://github.com/Terradue/InSAR-ROI_PAC.git
  cd InSAR-ROI_PAC
  mvn install
  
This will build and deploy the application on the /application volume.

The code can be modified by forking the repository here: `<https://github.com/Terradue/InSAR-ROI_PAC>`_

Before going further, install the dependencies:

.. code-block:: console

  sudo yum install -y roi_pac.x86_64 roi_pac-grdfile.x86_64 

Questions, bugs, and suggestions
++++++++++++++++++++++++++++++++

Please file any questions, bugs or suggestions as `issues <https://github.com/Terradue/InSAR-ROI_PAC/issues/new>`_ or send in a pull request.
