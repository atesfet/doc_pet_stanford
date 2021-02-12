PET Data Reconstructiion
========================

Introduction
------------

In this section, we are going to learn how to reconstruct PET data from PET sinogram. We are going to divide this section into XXX parts: (1) identify the starting point of PET signal; (2) create PET angiogram (PETA) data; (3) create static PET data; (4) create dynamic PET data without filters; (5) create dynamic PET data with spatial filters.


Step 1: Identify The Starting Point of PET signal
-------------------------------------------------

Select the LST file and click on PETRecon/Replay.

.. image:: /images/pet_recon/step_1/select_file.jpg

Now we need to create a static dummy file of 5min to locate the exact timepoint at which the PET signal was detected.

.. image:: /images/pet_recon/step_1/static_dummy_specification.jpg

Now click start recon button

.. image:: /images/pet_recon/step_1/static_dummy_click_recon.jpg

After a while, the signal curve appears at the top right corner. In this case, it seems that the signal starts after 60 seconds.

.. image:: /images/pet_recon/step_1/static_dummy_curve.jpg

After a while, the signal curve appears at the top right corner. In this case, it seems that the signal starts after 60 seconds.

.. image:: /images/pet_recon/step_1/static_dummy_curve.jpg

Now we are going to create a dynamic dummy PET of 100 frames with a pre-delay of 1min (or 60 seconds as we found previously).

Return to the file list and create a new recon window.

.. image:: /images/pet_recon/step_1/select_file.jpg

Use the following settings to create a dynamic dummy PET data of 100 frames with a pre-delay of 60 seconds.

Return to the file list and create a new recon window.

.. image:: /images/pet_recon/step_1/dynamic_dummy_specification.jpg

.. image:: /images/pet_recon/step_1/dynamic_dummy_100_frames.png

While we are waiting for the recon the finish, we could further narrow down the exact starting time of the PET signal.

Select the dynamic dummy file.

Open a C shell terminal and go to directory /usr/g/research/mehdi::

    cd usr/g/research/mehdi

.. image:: /images/pet_recon/step_1/c_shell_mehdi.jpg

Run the following command::

    petCounts.sh.org | sort -n

In the results, we can see that at time point 30 the PET signal becomes greater than zero. If you cannot see the entire results, just keep waiting for the recon to finish. It will take some time for each time point to process. Therefore, the actual timepoint of the start of PET signal is at 90 (pre-delay is 60 seconds plus the 30 seconds here). We will use this information in the subsequent steps.

We also see that at time point 59 the signal reaches the maximum. Since we need to create PETA profile, we need to obtain the increasing part of the PET signal. Typically it is from the start of the PET signal to the following 15-25 seconds. Here we will use 20 seconds for the PETA signal.

.. image:: /images/pet_recon/step_1/c_shell_pet_count.jpg

Now we have identified the actual starting time of the PET signal (at time point 90) and the duration of the PETA signal (20 seconds, but to be verified).


Step 2: Create PETA
-------------------

We are going to a create PETA image to facilitate the estimation of AIF. Open a new PET recon window.

.. image:: /images/pet_recon/step_2/select_file.jpg

We create a PETA image that starts at time point 90 and for 20 seconds. Use 3 iterations of 4mm filter and 192 x 192 matrix and ZTE attenuation correction.

.. image:: /images/pet_recon/step_2/peta_specification.jpg

.. image:: /images/pet_recon/step_2/peta_options.jpg

To select the desired PET recon type

.. image:: /images/pet_recon/step_2/peta_recon_type.png

To select the Recon Option

.. image:: /images/pet_recon/step_2/peta_zte.png

After the recon is complete. We can view the PETA image by selecting the PETA data and the localizer MRI data and click on ImageQC.

.. image:: /images/pet_recon/step_2/peta_select.jpg

The PETA data looks something like this. If you can see the blood (dark) signal in the arteries, it means that the PETA data is acceptable.

.. image:: /images/pet_recon/step_2/peta_aif.jpg


Step 3: Static PET Data Reconstruction
--------------------------------------

After identifying the exact time point of the starting point of the PET signal, we are ready to create a Static PET data for analysis. Open a reconstruction window:

.. image:: /images/pet_recon/step_3/static_select.jpg

Since the half-life of our tracer (O15-water) is 2.04 minutes, we are going to create a Static PET data of 2 minutes to maximize the SNR. We will use the similar reconstruction options as in the PETA data. Pre-delay: 90 seconds; filter: 4mm; number of iterations: 4; matrix: 192x192; Attenuation correction: ZTE

.. image:: /images/pet_recon/step_3/static_options.jpg

.. image:: /images/pet_recon/step_3/static_type.jpg


















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




