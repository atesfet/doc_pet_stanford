Data Preparation
================

Data Description
----------------

The `sample dataset <https://github.com/mosszhaodphil/doc_asl_stanford/tree/master/data>`_ was acquired using a GE 3T MRI system. The dataset includes a T1 weighted structural image and an ASL image acquired using GE's product sequence. These files were exported directly from the scanner.

For the ASL data, the file contains the ASL label/control difference image and the proton density M0 image. The main acquisition parameters of our sample ASL data are:

labeling duration: 1.45 seconds

post-labeling delay: 2.025 seconds

labeling efficiency: 85%

Number of backgroun suppressions: 3

Signal reduction due to background suppression: 9%

Number of excitations (NEX): 3

TR of M0 image: 2 seconds


Convert from DICOM to NifTI Format
----------------------------------

We use the `dcm2niix <https://github.com/rordenlab/dcm2niix>`_ software to convert the DICOM files to NIfTI format.

For the T1-weighted structural image::

    dcm2niix -o ./ -z y T1

For the ASL label/control difference image::

    dcm2niix -o ./ -f ASL_data -z y ASL

Rename the ASL label/control difference image::

    immv ASL_data ASL_diff

Rename the proton density M0 image::

    immv ASL_dataa M0


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




