% This function is refactored from the original estimateAIF_4Moss_2019Mar.m file

function myResults = estimateAIF(path2PET, path2PETA, path2MRA, path2GRE, ...
    myFileName, aif_file_name, time_file_name)
%
% estimateAIF estimates AIF of any dynamic PET study, using registered PET
% and MR images.
%
% usage:
%
% myResults = estimateAIFn(path2PET, path2PETA, path2MRA, path2GRE,myFileName);
%
% "path2PET"      : Path to all PET Dicom images - all dynanic no filter PET data
% "path2PETA"     : Path to PET Angiogram images (tracer entering the brain)
% "path2MRA"      : Path to MR Angiogram images
% "path2GRE"      : Path to MR GRE images
% "myFileName"    : file to store all PET and MR images in Matlab format.
%
% Developed by:
%    Mohammad Mehdi Khalighi
%    Senior Scientist
%    GE Healthcare Imaging
%    Applied Science Lab
%    Menlo Park, CA 94025
%
% Rev3 September 2016
% MMK: Clustering all PET dicom images into one single folder
% MMK: Improvement on MRA and PETA segmentation
% MMK: Adding Spill-in
% 
% Rev4 May 2018
% MMK: Added translational motion correction
% MMK: Mapped everything to MRA matrix
%


if exist(myFileName, 'file') == 2
    disp('Loading MR and PET images ...');
    load(myFileName, 'myPET', 'myMR', 'myResults');
else
    myMR  = readMRImages(path2MRA, path2GRE);
    myPET = readO15Images(path2PET, path2PETA);
    disp('Saving MR and PET images ...');
    save(myFileName, 'myPET', 'myMR');
end

TPET4D=sum(myPET.PET4D,4);

maskTB = TPET4D > (mean(TPET4D(:))/2);

maskTB = TPET4D/mean(TPET4D(maskTB)) > 1;
CC = bwconncomp(maskTB);
numPixels = cellfun(@numel,CC.PixelIdxList);
[~, myIndex] = sort(numPixels,'descend');
for idx=2:size(myIndex,2)
    maskTB(CC.PixelIdxList{myIndex(idx)}) = 0;
end
for ii=1:size(maskTB,3)
    maskTB(:,:,ii) = imfill(maskTB(:,:,ii),'holes');
end
myResults.maskTB = maskTB;

maskGM = TPET4D/mean(TPET4D(myResults.maskTB)) > 1;
CC = bwconncomp(maskGM);
numPixels = cellfun(@numel,CC.PixelIdxList);
[~, myIndex] = sort(numPixels,'descend');
for idx=2:size(myIndex,2)
    maskGM(CC.PixelIdxList{myIndex(idx)}) = 0;
end

myResults.maskGM = maskGM;
myResults.maskWM = (myResults.maskTB - myResults.maskGM)>0;

PETA_COW = interp3(myPET.X_PET, myPET.Y_PET, myPET.Z_PET, ...
    myPET.PETA_images, myMR.X_COW, myMR.Y_COW, myMR.Z_COW);
PETA_COW(isnan(PETA_COW)) = 0;
m1=myMR.COW>mean(myMR.COW(:));
m2=PETA_COW>mean(PETA_COW(:));
m0=(m1+m2)>0;
COWn=myMR.COW/mean(myMR.COW(m0));
PETA_COWn=PETA_COW/mean(PETA_COW(m0));

mask1=COWn>0.7;
for ii=1:size(mask1,3)
    mask1(:,:,ii) = imfill(mask1(:,:,ii),'holes');
end

COWn(COWn<mean(COWn(:)))=mean(COWn(COWn>mean(COWn(:))));

FS = round(min([size(myMR.COW,1),size(myMR.COW,2)]) / 65) * 2 + 1;
COWs = imgaussfilt3(COWn, FS);
COWsn=COWs/mean(COWs(m0));

COWns = COWn./COWsn.*mask1;
COWns(isnan(COWns)) = 0;
COWn=myMR.COW/mean(myMR.COW(m0));

maskTB_COW=interp3(myPET.X_PET, myPET.Y_PET, myPET.Z_PET, ...
    double(myResults.maskTB),myMR.X_COW, myMR.Y_COW, myMR.Z_COW);
maskTB_COW(isnan(maskTB_COW)) = 0;
for ii=1:size(maskTB_COW,3)
    maskTB_COW(:,:,ii)= imfill(maskTB_COW(:,:,ii),'holes');
end
clear COWs COWsn;

PetThr = 10;
MrThr  = 3;

maskCOW=(COWns > MrThr);
%{
startIdxAP = find(sum(sum(maskCOW,3),2),1);
endIdxAP = find(sum(sum(maskCOW,3),2),1,'last');
startIdxLR = find(squeeze(sum(sum(maskCOW,3),1)),1);
endIdxLR = find(squeeze(sum(sum(maskCOW,3),1)),1,'last');
COWn(1:floor(startIdxAP + (endIdxAP - startIdxAP) / 3), :, :) = 0;
COWn(endIdxAP - floor((endIdxAP - startIdxAP) / 4):end, :, :)=0;
PETA_COWn(1:floor(startIdxAP + (endIdxAP - startIdxAP) / 3), :, :) = 0;
PETA_COWn(endIdxAP - floor((endIdxAP - startIdxAP) / 4):end, :, :)=0;
COWn(:,1:floor(startIdxLR + (endIdxLR - startIdxLR) / 4), :) = 0;
COWn(:,endIdxLR - floor((endIdxLR - startIdxLR) / 4):end, :)=0;
PETA_COWn(:,endIdxLR - floor((endIdxLR - startIdxLR) / 4):end, :)=0;
PETA_COWn(:,1:floor(startIdxLR + (endIdxLR - startIdxLR) / 4), :) = 0;
%}
COWn=COWn/mean(COWn(COWn>0));
PETA_COWn=PETA_COWn/mean(PETA_COWn(PETA_COWn>0));

myShift = registerPetaMra(PETA_COWn .* (PETA_COWn > PetThr), COWn .* (COWns > MrThr));

mmCOW = [myMR.Y_COW(2,1,1)-myMR.Y_COW(1,1,1), ...
         myMR.X_COW(1,2,1)-myMR.X_COW(1,1,1), ...
         myMR.Z_COW(1,1,2)-myMR.Z_COW(1,1,1)];
mmShift = myShift .* mmCOW;
myResults.Shift = myShift;
myResults.mmShift = mmShift;

[X_PET, Y_PET, Z_PET] = meshgrid(squeeze(myPET.X_PET(1,:,1)) + mmShift(2), ...
                                 squeeze(myPET.Y_PET(:,1,1)) + mmShift(1), ...
                                 squeeze(myPET.Z_PET(1,1,:)) + mmShift(3));
PETA_COWr = interp3(X_PET, Y_PET, Z_PET, ...
    myPET.PETA_images, myMR.X_COW, myMR.Y_COW, myMR.Z_COW);
PETA_COWr(isnan(PETA_COWr)) = 0;
PETA_COWrn = PETA_COWr/mean(PETA_COWr(m0));

%{
PETA_COWrn(1:floor(startIdxAP + (endIdxAP - startIdxAP) / 3), :, :) = 0;
PETA_COWrn(endIdxAP - floor((endIdxAP - startIdxAP) / 4):end, :, :)=0;
PETA_COWrn(:,endIdxLR - floor((endIdxLR - startIdxLR) / 4):end, :)=0;
PETA_COWrn(:,1:floor(startIdxLR + (endIdxLR - startIdxLR) / 4), :) = 0;
%}

PETA_COWrn=PETA_COWrn/mean(PETA_COWrn(PETA_COWrn>0));
PetThr = 1+1*std(PETA_COWrn(PETA_COWrn>0)); % MMK cvhanged 0.5 to 2
clear PETA_COWr;

maskPETA = PETA_COWrn > PetThr;
%maskPETA = imclose(maskPETA,strel('disk',5));

[Mc, Nc, Zc] = size(COWn);
maskCOWn = ones(size(COWn));
if ((myMR.Z_COW(1,1,end) - myMR.Z_COW(1,1,1)) > 0)
    maskCOWn(:,:,end-Zc/5:end) = 0;
else
    maskCOWn(:,:,1:Zc/5) = 0;
end
maskCOWn(1:161,:,:) = 0;
if contains(myFileName,'upp1811')
    maskCOWn(:,:,56:end) = 0; 
    maskCOWn(141:end,:,:) = 0;
end;
maskCOWn(1:Mc/4-1,:,:) = 0; maskCOWn(Mc-Mc/4+1:end,:,:) = 0;
maskCOWn(:,1:Nc/4-1,:) = 0; maskCOWn(:,Nc-Nc/4+1:end,:) = 0;

COWn = COWn .* maskCOWn;
%{
COWn(:,:,75:end) = 0; % for all
%COWn(:,:,65:end) = 0; % for upp 1512
%COWn(:,:,56:end) = 0; % for upp 1811
%COWn(141:end,:,:) = 0; % for upp 1811
COWn(161:end,:,:) = 0; % for upp 1427 & 1402 & 1320
COWn(1:Mc/4-1,:,:) = 0; COWn(Mc-Mc/4+1:end,:,:) = 0;
COWn(:,1:Nc/4-1,:) = 0; COWn(:,Nc-Nc/4+1:end,:) = 0;
%}
COWnn = COWn; 
COWss = COWn;
COWnn(COWn > MrThr)=0;
COWss(COWn < MrThr)=0;
sdnn = zeros([size(COWn,3) 1]);
mss  = zeros([size(COWn,3) 1]);
myTh = zeros([size(COWn,3) 1]);


%COWn(:,:,55:end)=0; % for upp 1811
%COWn(:,:,70:end)=0; % for upp 1267 MMK

for ii=1:size(COWn,3)
    tmpnn=COWnn(:,:,ii);
    tmpss=COWss(:,:,ii);
    sdnn(ii) = std(tmpnn(COWnn(:,:,ii)>0));
    mss(ii)  = mean(tmpss(COWss(:,:,ii)>0));
    myTh(ii) = max((1+mss(ii))/2, 1+3*sdnn(ii)); %changed 3 to 2 MMK
    myTh(ii) = min(mss(ii)-sdnn(ii)/2, myTh(ii));
    maskCOW(:,:,ii) = (COWn(:,:,ii) > myTh(ii)) .* maskPETA(:,:,ii);
end

'Debug here...'
%bwconncomp(myTh)

%bwconncomp(maskPETA)

clear COWnn COWss sdnn mss myTh;



CC = bwconncomp(maskCOW);
%CC.PixelIdxList
numPixels = cellfun(@numel,CC.PixelIdxList);
[~, myIndex] = sort(numPixels,'descend');
clusterThr = 0.8*numPixels(myIndex(2));
'Debug end here...'
noise=find(numPixels<clusterThr);
for idx=1:size(noise,2)
    maskCOW(CC.PixelIdxList{noise(idx)}) = 0;
end

for ii=1:size(maskCOW,3)
    maskCOW(:,:,ii)=imfill(maskCOW(:,:,ii),'holes');
end

myFS=16;
myST=strel('rectangle', [ceil(myFS/2) myFS]);

maskCOWd=zeros(size(maskCOW));
for ii=1:size(maskCOWd,3)
    maskCOWd(:,:,ii) = imdilate(logical(maskCOW(:,:,ii)),myST);
end
for ii=1:size(maskCOWd,2)
    maskCOWd(:,ii,:) = imdilate(logical(squeeze(maskCOWd(:,ii,:))),myST);
end

maskCOWd(maskCOWn==0) = 0;
maskPETA = maskPETA .* maskCOWd;

myFS=16; %MMK 4
myST = strel('rectangle',[myFS/2 myFS]);
maskSpillIn = false(size(maskPETA));
for ii=1:size(maskSpillIn,3)
    maskSpillIn(:,:,ii) = imdilate(logical(maskPETA(:,:,ii)),myST);
end
for ii=1:size(maskSpillIn,2)
    maskSpillIn(:,ii,:) = imdilate(logical(squeeze(maskSpillIn(:,ii,:))),myST);
end
maskSpillIn = maskSpillIn .* (1-maskPETA);
maskSpillIn(maskCOWn==0) = 0;

myResults.maskCOW = maskCOW;
myResults.maskPETA = maskPETA;
myResults.maskSpillIn = maskSpillIn;

k5=[0.1530 0.1919 0.2060 0.1919 0.1530]/sum([0.1530 0.1919 0.2060 0.1919 0.1530]);
k3=[0.3149 0.5000 0.3149]/sum([0.3149 0.5000 0.3149]);
k33=repmat(k3, [3 1]).*(repmat(k3, [3 1]))';
k333=repmat(k33,[1 1 3]).*(repmat(permute(k3,[3 1 2]),[3 3 1]));
k3335=repmat(k333,[1 1 1 5]).*(repmat(permute(k5,[4 3 1 2]),[3 3 3 1]));
PET4D_filtered = convn(myPET.PET4D, k3335, 'same');

NoTPoints = size(myPET.PET4D,4);
AIFnc = zeros([NoTPoints,1]);
SpillIn = zeros([NoTPoints,1]);
for kk=1:NoTPoints
    if (kk<30)
        PET4D_COW = interp3(X_PET, Y_PET, Z_PET, ...
            myPET.PET4D(:,:,:,kk), myMR.X_COW, myMR.Y_COW, myMR.Z_COW);
        PET4D_COW(isnan(PET4D_COW)) = 0;
    else
        PET4D_COW = interp3(X_PET, Y_PET, Z_PET, ...
            PET4D_filtered(:,:,:,kk), myMR.X_COW, myMR.Y_COW, myMR.Z_COW);
        PET4D_COW(isnan(PET4D_COW)) = 0;
    end        
    temp=PET4D_COW.*maskPETA;
    AIFnc(kk)= sum(temp(:));
    temp=PET4D_COW.*maskSpillIn;
    SpillIn(kk)= sum(temp(:));
end

corSpillIn = SpillIn / sum(maskSpillIn(:)) * ...
             (sum(maskPETA(:)) / sum(maskCOW(:)) - 1);
AIF = AIFnc / sum(maskCOW(:)) - corSpillIn;
%plot(myPET.T1, AIF/1000, 'linewidth', 2);

TM=squeeze(sum(sum(sum(PET4D_filtered .* ...
    repmat(myResults.maskTB,[1 1 1 NoTPoints]),1),2),3)) / sum(myResults.maskTB(:));
GM=squeeze(sum(sum(sum(PET4D_filtered .* ...
    repmat(myResults.maskGM,[1 1 1 NoTPoints]),1),2),3)) / sum(myResults.maskGM(:));
WM=squeeze(sum(sum(sum(PET4D_filtered .* ...
    repmat(myResults.maskWM,[1 1 1 NoTPoints]),1),2),3)) / sum(myResults.maskWM(:));

clear cc;
cc(:,1) = interp1(myPET.T1, AIF,         myPET.T1(1):myPET.T1(end),'spline')';
cc(:,2) = interp1(myPET.T1, corSpillIn,  myPET.T1(1):myPET.T1(end),'spline')';
cc(:,3) = (myPET.T1(1):myPET.T1(end))' - myPET.T1(1);
cc(:,4) = interp1(myPET.T1, GM,          myPET.T1(1):myPET.T1(end),'spline')';

tmp = zeros([size(cc,1), 1]);
tmp(floor(myPET.T1-myPET.T1(1)+1)) = 1;
tmp(1:30)=10; tmp(30+2:3:60)=(9.5:-0.5:5)';
tmp(60+2:3:120)=(5*1.5.^(-(1:20)/5))';
cc(:,5) = tmp;
f2 = @(x,c) sum(([c(:,4).*c(:,5);zeros([size(c,1)-1 1])] - ...
    (conv(x(1)*(c(:,1)- x(2) * c(:,2)),exp(-x(1)*c(:,3)))).*[c(:,5); zeros([size(c,1)-1 1])]).^2);
XX = fminsearch(@(x) f2(x,cc),[0.052;10]);
if (XX(2) > 0), XX(2)=0; end
%XX(2) = 0; %MMK

corSpillIn = SpillIn / sum(maskSpillIn(:)) * ...
             (sum(maskPETA(:)) / sum(maskCOW(:)) - 1) * (1 + XX(2));

AIF = AIFnc / sum(maskCOW(:)) - corSpillIn;
   
myResults.Time = myPET.T1;

clear cc;
cc(:,1) = interp1(myPET.T1, AIF, myPET.T1(1):myPET.T1(end),'spline')';
cc(:,2) = interp1(myPET.T1, TM,  myPET.T1(1):myPET.T1(end),'spline')';
cc(:,3) = (myPET.T1(1):myPET.T1(end))' - myPET.T1(1);
tmp = zeros([size(cc,1), 1]);
tmp(floor(myPET.T1-myPET.T1(1)+1)) = 1;
tmp(1:30)=10; tmp(30+2:3:60)=(9.5:-0.5:5)';
tmp(60+2:3:120)=(5*1.5.^(-(1:20)/5))';
%tmp(60+2:3:120)=5;
cc(:,4) = tmp;
f = @(x,c) sum(([c(:,2).*c(:,4) ;zeros([size(c,1)-1 1])] - ...
    ((1-x(3))*x(1)*conv(c(:,1),exp(-x(2)*c(:,3))) - x(3)*[c(:,1) ;zeros([size(c,1)-1 1])]) .* [c(:,4); zeros([size(c,1)-1 1])]).^2);

XWB = fminsearch(@(x) f(x,cc),[0.052;0.022;0]);
cc(:,2) = interp1(myPET.T1, GM, myPET.T1(1):myPET.T1(end),'spline')';
XGM = fminsearch(@(x) f(x,cc),[0.052;0.022;0]);
cc(:,2) = interp1(myPET.T1, WM, myPET.T1(1):myPET.T1(end),'spline')';
XWM = fminsearch(@(x) f(x,cc),[0.052;0.022;0]);

myResults.CBF_WB = XWB(1) * 60 * 100 / 1.032;
myResults.CBF_WM = XWM(1) * 60 * 100 / 1.032;
myResults.CBF_GM = XGM(1) * 60 * 100 / 1.032;
myResults.Perm_WB = XWB(1) / XWB(2);
myResults.Perm_WM = XWM(1) / XWM(2);
myResults.Perm_GM = XGM(1) / XGM(2);
myResults.Va_WB = 100 * XWB(3);
myResults.Va_WM = 100 * XWM(3);
myResults.Va_GM = 100 * XGM(3);
myResults.AIF = AIF;
myResults.AIFnc = AIFnc / sum(maskCOW(:));
myResults.corSpillIn = corSpillIn;
myResults.X2= XX(2);
myResults.GM = GM;
myResults.WB = TM;
myResults.WM = WM;

disp(myFileName);
disp([myResults.CBF_GM myResults.CBF_WM myResults.CBF_WB]);
disp([myResults.Perm_GM myResults.Perm_WM myResults.Perm_WB]);
disp('Saving everything ...');
save(myFileName, 'myPET', 'myMR', 'myResults');

disp('Saving AIF and time ...');
dlmwrite(aif_file_name, myResults.AIF, 'precision', 10);
dlmwrite(time_file_name, myPET.T1);


end

function myPET = readO15Images(path2PET, path2PETA)

file_to_delete = strcat(path2PETA, '/.DS_Store');
delete(file_to_delete);
disp('Reading PETA images...');
files = dir(path2PETA);
fileNo = size(files,1)-2;
info = dicominfo([path2PETA '/' files(3).name], 'UseDictionaryVR', true);
myPET.PETA_images = single(zeros([info.Width, info.Height, info.NumberOfSlices]));

PET_X_pos = double((0:info.Rows - 1)) * info.PixelSpacing(1) + info.ImagePositionPatient(1) + double(info.Private_0009_10cb);
PET_Y_pos = double((0:info.Columns - 1)) * info.PixelSpacing(1) + info.ImagePositionPatient(2) + double(info.Private_0009_10cd);
PET_Z_pos = zeros(1,info.NumberOfSlices);
PET_Z_pos(1) = info.ImagePositionPatient(3) + double(info.Private_0009_10cf);

for ii=1:fileNo
    info = dicominfo([path2PETA '/' files(ii+2).name], 'UseDictionaryVR', true);
    myPET.dicominfo(info.InstanceNumber) = info;
    myPET.PETA_images(:, :, info.InstanceNumber) = ...
       single(info.RescaleSlope * single(dicomread(info)) + info.RescaleIntercept);
    PET_Z_pos(info.InstanceNumber) = info.ImagePositionPatient(3) + double(info.Private_0009_10cf);
end

[myPET.X_PET,myPET.Y_PET,myPET.Z_PET] = meshgrid(PET_X_pos, PET_Y_pos, PET_Z_pos);
myPET.Vp = abs((PET_X_pos(2)-PET_X_pos(1))*(PET_Y_pos(2)-PET_Y_pos(1))*(PET_Z_pos(2)-PET_Z_pos(1)));

myPET.PW = info.PatientWeight;

myPET.total_dose = 800;
myPET.ScanTimeDoseCor = 1;

file_to_delete = strcat(path2PET, '/.DS_Store');
delete(file_to_delete);
disp('Reading all Dynamcic PET frames...');
files = dir(path2PET);
fileNo = size(files,1)-2;
info = dicominfo([path2PET '/' files(3).name], 'UseDictionaryVR', true);
NumberOfTimeSlices = uint16(ceil(single(fileNo) / single(info.NumberOfSlices)));
PET4D = single(zeros([info.Width, info.Height, info.NumberOfSlices, NumberOfTimeSlices]));
TT=single(zeros([NumberOfTimeSlices,1]));
timeCntr = 1 ;
for ii=1:fileNo
    info = dicominfo([path2PET '/' files(ii+2).name], 'UseDictionaryVR', true);
    timePoint = uint16(info.Private_0009_10d8);
    sliceNo = info.InstanceNumber - (timePoint - 1) * info.NumberOfSlices;
    timeIndex = find(TT==(info.FrameReferenceTime + info.ActualFrameDuration/2));
    if (isempty(timeIndex))
        TT(timeCntr) = (info.FrameReferenceTime + info.ActualFrameDuration/2);
        timeIndex = timeCntr;
        timeCntr = timeCntr + 1;
    end
    PET4D(:, :, sliceNo, timeIndex) = ...
       single(info.RescaleSlope * single(dicomread(info)) + info.RescaleIntercept);
end

if (NumberOfTimeSlices ~= (timeCntr-1))
    disp(['Error: Not all time points were read in: ', path2PET]);
    disp('There is a possibility of overlap. Please check your data.');
end

[timePoints, myIndex] = sort(TT);
myPET.T1 = (timePoints) / 1000;
myPET.T2 = (floor(myPET.T1(1)):ceil(myPET.T1(end)));
myPET.PET4D = PET4D(:,:,:,myIndex);

end

function myMR = readMRImages(path2MRA, path2GRE)

file_to_delete = strcat(path2MRA, '/.DS_Store');
delete(file_to_delete);
disp('Reading MRA images...');
files = dir(path2MRA); % List all dicom files
NumberOfSlices = size(files,1)-2;
info = dicominfo([path2MRA '/' files(3).name]);
myMR.COW = single(zeros([info.Width, info.Height, NumberOfSlices]));
COW_X_pos = double((0:info.Rows - 1)) * info.PixelSpacing(1) + info.ImagePositionPatient(1); % - double(info.Private_0009_10cb);
COW_Y_pos = double((0:info.Columns - 1)) * info.PixelSpacing(1) + info.ImagePositionPatient(2); % - double(info.Private_0009_10cd);
COW_Z_pos = zeros(1,NumberOfSlices);
COW_Z_pos(1) = info.ImagePositionPatient(3); % - double(info.Private_0009_10cf);

for ii=1:NumberOfSlices
    info = dicominfo([path2MRA '/' files(ii+2).name]);
    myMR.COW(:, :, info.InstanceNumber) = single(dicomread(info));
    COW_Z_pos(info.InstanceNumber) = info.ImagePositionPatient(3);
end

disp('Reading Ax_GRE images...');
file_to_delete = strcat(path2GRE, '/.DS_Store');
delete(file_to_delete);
files = dir(path2GRE);
NumberOfSlices = size(files,1)-2;
info = dicominfo([path2GRE '/' files(3).name]);
myMR.GRE = single(zeros([info.Width, info.Height, NumberOfSlices]));
GRE_X_pos=(info.ImagePositionPatient(1):double(info.ReconstructionDiameter)/double(info.Rows):...
    (double(info.ReconstructionDiameter)+info.ImagePositionPatient(1)-double(info.ReconstructionDiameter)/double(2*info.Rows)));
GRE_Y_pos=(info.ImagePositionPatient(2):double(info.ReconstructionDiameter)/double(info.Columns):...
    (info.ReconstructionDiameter+info.ImagePositionPatient(2)-double(info.ReconstructionDiameter)/double(2*info.Columns)));
GRE_Z_pos = zeros(1,NumberOfSlices);
GRE_Z_pos(1) = info.ImagePositionPatient(3);

for ii=1:NumberOfSlices
    info = dicominfo([path2GRE '/' files(ii+2).name]);
    myMR.GRE(:, :, info.InstanceNumber) = single(dicomread(info));
    GRE_Z_pos(info.InstanceNumber) = info.ImagePositionPatient(3);
end

[myMR.X_COW,myMR.Y_COW,myMR.Z_COW] = meshgrid(COW_X_pos, COW_Y_pos, COW_Z_pos);
[myMR.X_GRE,myMR.Y_GRE,myMR.Z_GRE] = meshgrid(GRE_X_pos, GRE_Y_pos, GRE_Z_pos);
myMR.Vm = (COW_X_pos(2)-COW_X_pos(1))*(COW_Y_pos(2)-COW_Y_pos(1))*(COW_Z_pos(2)-COW_Z_pos(1));

end


function myShift = registerPetaMra(maskPETA_COW, maskCOW)

myShift = [0 0 0];
mytmp = zeros(31,1);
Sm = size(maskCOW);
for ii=-25:25
    tmp = maskPETA_COW(max(1,1-myShift(1)):min(Sm(1), Sm(1)-myShift(1)), ...
                       max(1,1-myShift(2)):min(Sm(2), Sm(2)-myShift(2)), ...
                       max(1,1-ii):        min(Sm(3), Sm(3)-ii)) .* ...
               maskCOW(max(1,1+myShift(1)):min(Sm(1), Sm(1)+myShift(1)), ...
                       max(1,1+myShift(2)):min(Sm(2), Sm(2)+myShift(2)), ...
                       max(1,1+ii):        min(Sm(3), Sm(3)+ii));
    mytmp(ii+26) = sum(tmp(:));
end
[~, iMax] = max(mytmp);
myShift(3) = iMax - 26;    

mytmp = zeros(31,1);
for ii=-15:15
    tmp = maskPETA_COW(max(1,1-ii):        min(Sm(1),Sm(1)-ii), ...
                       max(1,1-myShift(2)):min(Sm(2),Sm(2)-myShift(2)), ...
                       max(1,1-myShift(3)):min(Sm(3),Sm(3)-myShift(3))) .* ...
               maskCOW(max(1,1+ii):        min(Sm(1),Sm(1)+ii), ...
                       max(1,1+myShift(2)):min(Sm(2),Sm(2)+myShift(2)), ...
                       max(1,1+myShift(3)):min(Sm(3),Sm(3)+myShift(3)));
    mytmp(ii+16) = sum(tmp(:));
end
[~, iMax] = max(mytmp);
myShift(1) = iMax - 16;

mytmp = zeros(31,1);
for ii=-15:15
    tmp = maskPETA_COW(max(1,1-myShift(1)):min(Sm(1),Sm(1)-myShift(1)), ...
                       max(1,1-ii):        min(Sm(2),Sm(2)-ii), ...
                       max(1,1-myShift(3)):min(Sm(3),Sm(3)-myShift(3))) .* ...
               maskCOW(max(1,1+myShift(1)):min(Sm(1),Sm(1)+myShift(1)), ...
                       max(1,1+ii):        min(Sm(2),Sm(2)+ii), ...
                       max(1,1+myShift(3)):min(Sm(3),Sm(3)+myShift(3)));
    mytmp(ii+16) = sum(tmp(:));
end
[~, iMax] = max(mytmp);
myShift(2) = iMax - 16;

end
