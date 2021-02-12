% This program estiamtes the arterial input function (AIF) for dynamic PET data.
% Required input files (all in DICOM format):
% Dynamic PET data without filtering
% PET angriogram (PETA)
% MRA of the neck (3D volume)
% Gradient echo (GRE)

% Specify input file locations
path2PET = 'DYNAMIC_PET_NO_FILTER';
path2PETA = 'PETA';
path2MRA = 'MRA_AIF';
path2GRE = 'GRE';

% Specify PET MRI file
myFileName = 'PET_MRI_FILES';

% Specify output file names
aif_file_name = 'AIF.txt';
time_file_name = 'time.txt';
my_Results_name = 'AIF_RESULTS.mat';

% Run the function to estimate AIF
my_Results = estimateAIF(path2PET, path2PETA, path2MRA, path2GRE, myFileName, aif_file_name, time_file_name);

% Save the results
save(my_Results_name, 'my_Results');

% Delete the temporary files
delete(myFileName);

disp('Complete!!!');
