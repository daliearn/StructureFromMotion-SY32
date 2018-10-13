%This have to be adapted if you use another dataset
imagefiles = dir('./images/I1_*.png') ;   
nfiles = length(imagefiles);    % Number of files found

for ii=1:nfiles
   currentfilename = imagefiles(ii).name
   currentimage = imread(strcat('./images/', currentfilename));
   image1s{ii} = currentimage;
end

imagefiles = dir('./images/I2_*.png') ;   
nfiles = length(imagefiles);    % Number of files found

for ii=1:nfiles
   currentfilename = imagefiles(ii).name
   currentimage = imread(strcat('./images/', currentfilename));
   image2s{ii} = currentimage;
end