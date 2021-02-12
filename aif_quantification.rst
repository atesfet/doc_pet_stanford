PET Image Derived Arterial Input Function (AIF) Estimation
==========================================================

Introduction
------------

In this section, we are going to create an image derived AIF for dynamic PET data analysis. We will need the following input files in DICOM format:

1 Dynamic PET data without filtering

2 PET angiogram (PETA)

3 MRA of the neck (3D volume)

4 Gradient echo (GRE) MRI data

We will use the MATLAB script that you can downlaod `here <https://github.com/mosszhaodphil/doc_pet_stanford/tree/master/src>`_.


Estimate AIF
------------

Open the create_aif.m file and check the input files are correctly located. Run this command in your MATLAB terminal.

It will take some time to finish the analysis. To facilitate your studying of this tutorial, I have provided the result AIF.txt for you.

You will need the AIF.txt file to estimate CBF from the Dynamic PET data.


