Structural Image Processing
===========================

Introduction
------------

The T1-weighted image allows us to perform registration and group analysis for our PET data. However, the raw T1-weighted image from the scanner may contain artifacts due to bias field. We can use FSL tools to reduce these impacts and improve the accuracy of image registration and tissue segmentation.


Processing the T1-weighted Structural Image
-------------------------------------------

We use the `fsl_anat <https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/fsl_anat>`_ to improve the quality of the T1-weighted structural image. The procedure includes: automated cropping, bias field correction, brain extraction, linear and non-linear registration, tissue segmentation:

For the T1-weighted structural image::

    fsl_anat -i T1 -o fsl_anat_dir --nosubcortseg

The process may take a while to finish. The results are saved in the fsl_anat_dir.anat folder.

Further Reading
---------------

The detail explanation on structural image processing can be found in the `FSL Course <https://fsl.fmrib.ox.ac.uk/fslcourse/>`_.




