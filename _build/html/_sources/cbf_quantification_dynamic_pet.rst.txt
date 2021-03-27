CBF Quantification Using Dynamic PET 
====================================

Introduction
----------------

The goal of this section is to compute voxel-wise CBF using the Dynamic PET data that we have pre-processed in previous steps. We will also tranform the quantified CBF image from PET space to standard MNI-152 2mm space for group analysis.


CBF Quantification
------------------

We are going to use the `fabber <https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FABBER>`_ tool to quantify CBF from our dynamic PET data. The process includes 2 steps: (1), we estimate the voxel-wise CBF using Bayesian inference; (2) we apply spatial regularization to improve the CBF quantification.

Important: please confirm that the the units of your PET data and AIF are consistent. In the example data, the unit of the PET data and AIF is Bq/mL.

Step 1: CBF quantification using Bayesian inference. In order to use `fabber <https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FABBER>`_, we need to provide a list of options that specifies model and scanning parameters. An exmaple option file (fabber_options_PET_DYNAMIC_step_1.txt) has been provided for you. Below is the description of each of the options:

--mask=mask : Brain mask used for analysis

--model=pet_1TCM : Here we are using 1-compartment model

--method=vb : Here we are using variational Bayesian inference

--noise=white : Here we assume the noise of our data is in normal distribution

--data-order=singlefile : Here we are providing a single file to analyze

--aif=signal : Here we specify that the AIF of our dynamic PET is a list of signals

--aif-data=AIF.txt : Here we specify the file name of our AIF file

--time-data=time.txt : Here we specify the file name that contains time of each signal

--allow-bad-voxels : Here we allow bad voxels to improve the robustness of our estimation

Now we can run the command to estimate voxel-wise CBF::

    fabber_pet --data=DYNAMIC_4MM_FILTER --output=fabber_output_step1 -@ fabber_options_PET_DYNAMIC_step_1.txt

The file fabber_output_step1/mean_K1.nii.gz is the estimated CBF image in relative units. We can have a look at it in FSLeyes


Step 2: Apply spatial regularization to improve CBF estimation. We will use the estimation results from Step 1 as the starting point to improve our CBF estimation by applying spatial regularization. Here, we will need a different option file (fabber_options_PET_DYNAMIC_step_2.txt) for the fabber command. The new options are:

--method=spatialvb : Here we are using spatially variational Bayesian inference

--continue-from-mvn=fabber_output_step1/finalMVN : Here we use the results from Step 1 to start the estimation in Step 2.

Now we can run the command to apply spatial regularization::

    fabber_pet --data=DYNAMIC_4MM_FILTER --output=fabber_output_step2 -@ fabber_options_PET_DYNAMIC_step_2.txt


Post-processing
---------------

After model-fitting using FABBER, there may be some artifacts with high signal intensity in or near the macrovasculatures. We can apply some post-processing techniques to reduce the impacts of these artifacts.

First we remove these very high intensity voxels (higher than 99.9 percentile) and NAN voxels with zero::

	fslmaths fabber_output_step2/mean_K1 -nan -uthrP 99.9 fabber_output_step2/mean_K1_uthrP

Secontly, we apply extrapolation to restore these voxels::

	asl_file --data=fabber_output_step2/mean_K1_uthrP --ntis=1 --mask=mask --extrapolate --out=fabber_output_step2/mean_K1_uthrP_extrapolate

Thirdly, we apply a median filter to remove the inpulse artifacts::

	fslmaths fabber_output_step2/mean_K1_uthrP_extrapolate -fmedian -mas mask fabber_output_step2/mean_K1_uthrP_extrapolate_median

Calibration
-----------

After post-processing, the estimated CBF data is still in s-1 unit. In general, we often use the unit of ml/100g/min. We can also convert the unit to ml/100g/min by multiplying 6000. Therefore, we will convert the unit using the following command::

	fslmaths fabber_output_step2/mean_K1_uthrP_extrapolate_median -mul 6000 -mas mask CBF_PET_DYNAMIC

Now let's have a look at CBF_absolute file in FSLeyes. The value of each voxel should be in ml/100g/min unit.

.. image:: /images/cbf_quantification/cbf_absolute.png


Transform from ASL to MNI-152 2mm Space
---------------------------------------

Finally, we can transform the absolute CBF image to MNI-152 2mm standard space using linear and non-linear registration::

    applywarp --ref=${FSLDIR}/data/standard/MNI152_T1_2mm --in=CBF_PET_DYNAMIC --warp=fsl_anat_dir.anat/T1_to_MNI_nonlin_field --premat=output_pet_reg/pet2struct.mat --out=CBF_absolute_standard

