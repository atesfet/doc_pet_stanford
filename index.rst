=================================================================
Dynamic Positron Emission Tomography (PET) Data Analysis Tutorial
=================================================================

This tutorial aims to demonstrate how to obtain perfusion or cerebral blood flow (CBF) using dynamic O15-water PET data collected by GE 3T MRI (or PET/MRI) scanners at Stanford University. The same technique can be applied to dynamic PET data acquired using other tracers such as FDG.

Pre-requisite
-------------

1 Download and install `FSL <https://fsl.fmrib.ox.ac.uk/fsl/fslwiki>`_

2 Download and install `dcm2niix <https://github.com/rordenlab/dcm2niix>`_

3 Understand the basics of `PET imaging <http://mriquestions.com/what-is-asl.html>`_

4 Able to visualize PET neuroimaging data in NIfTI format


Sample Data
-----------

We will use a sample dataset of a healthy volunteer collected by a GE 3T MRI system. The dataset includes a T1 weighted structural image and an ASL image acquired using GE's PET/MRI system. This dataset can be downloaded here.


Content
-------

.. toctree::
   :maxdepth: 2
   
   dynamic_pet_data_reconstruction

   data_preparation

   structural_image_processing

   pet_pre_processing

   aif_quantification

   cbf_quantification


References
==========

You may include the following description in your manuscript:

An image-derived arterial input function (AIF) was estimated from dynamic PET data in the carotid arteries including corrections for spill-in and out artifacts using the high-resolution segmentation of the cervical MRA and GRE data for masking [1]. This AIF and dynamic PET data were then incorporated into the one-compartment pharmacokinetic model to quantify voxel-wise CBF. The model was implemented in the spatially regularized Variational Bayesian Inference framework in FSL [2].


 [1]	*Khalighi MM, Deller TW, Fan AP, et al. Image-derived input function estimation on a TOF-enabled PET/MR for cerebral blood flow mapping. Journal of Cerebral Blood Flow & Metabolism. 2018;38(1):126-135. doi:10.1177/0271678X17691784*

 [2]	*YOUR NEUROIMAGE REF GOES HERE*


