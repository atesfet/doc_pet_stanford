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

We will use a sample dataset of a healthy volunteer collected by a GE 3T MRI system. The dataset includes a T1 weighted structural image and an ASL image acquired using GE's product sequence. This dataset can be downloaded here.


Content
-------

.. toctree::
   :maxdepth: 2
   
   data_preparation

   structural_image_processing

   asl_pre_processing

   cbf_quantification


References
==========

You may include the following description in your manuscript:

Voxel-wise CBF in absolute units was estimated by fitting the ASL label/control difference data to the general kinetic model using the variational Bayesian inference technque [1, 2]. The artifact on the edge of the brain due to partial volume effects was corrected using the erosion and extrapolatino technique [3].


 [1]	*Chappell, M.A., Groves, A.R., Whitcher, B., Woolrich, M.W., 2009. Variational Bayesian Inference for a Nonlinear Forward Model. IEEE Trans. Signal Process. 57, 223–236. https://doi.org/10.1109/TSP.2008.2005752*

 [2]	*Groves, A.R., Chappell, M.A., Woolrich, M.W., 2009. Combined spatial and non-spatial prior for inference on MRI time-series. NeuroImage 45, 795–809. https://doi.org/10.1016/j.neuroimage.2008.12.027*

 [3]	*Zhao, M.Y., Mezue, M., Segerdahl, A.R., Okell, T.W., Tracey, I., Xiao, Y., Chappell, M.A., 2017. A systematic study of the sensitivity of partial volume correction methods for the quantification of perfusion from pseudo-continuous arterial spin labeling MRI. NeuroImage 162, 384–397. https://doi.org/10.1016/j.neuroimage.2017.08.072*

