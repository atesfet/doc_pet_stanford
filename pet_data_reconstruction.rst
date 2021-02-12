PET Data Reconstructiion
========================

Introduction
------------

In this section, we are going to learn how to reconstruct PET data from PET sinogram. We are going to divide this section into XXX parts: (1) identify the starting point of PET signal; (2) create PET angiogram (PETA) data; (3) create static PET data; (4) create dynamic PET data without filters; (5) create dynamic PET data with spatial filters.





Step 1: Identify The Starting Point of PET signal
-------------------------------------------------

Select the LST file and click on PETRecon/Replay.

.. image:: /images/pet_recon/step_1/select_file.jpg





Visualize the Images
--------------------

We use `FSLeyes <https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FSLeyes>`_ to view the T1-wieghted structural and ASL images.

We can view the T1-wieghted structural image, which should look like the following:

.. image:: /images/data_preparation/T1_structure.png

The ASL label/control difference image should look like the following:

.. image:: /images/data_preparation/ASL_label_control.png

The proton density M0 image should look like the following:

.. image:: /images/data_preparation/M0.png


Potential Issues
----------------

It is possible that the the ASL label/control different and M0 images are store together in a single NifTI file. We may use the command tool `fslroi <https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/Fslutils>`_ to separate the images. ::

    fslroi <input> <output> <tmin> <tsize>




