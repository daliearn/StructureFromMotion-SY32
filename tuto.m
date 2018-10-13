%This is the Matlab Tutorial about structure-from-motion algorithm
%%
%Load images
loadImages
I1 = image1s{1};
I2 = image2s{1};
%figure
%imshowpair(I1, I2, 'montage');
%title('Original Images');
%%
%Detect features
imagePoints1 = detectHarrisFeatures(I1, 'MinQuality', 0.01);
%figure     
%imshow(I1, 'InitialMagnification', 50);
%title('150 Strongest Corners from the First Image');
%hold on
%plot(selectStrongest(imagePoints1, 150));
tracker = vision.PointTracker('MaxBidirectionalError', 1, 'NumPyramidLevels', 5);

imagePoints1 = imagePoints1.Location;
initialize(tracker, imagePoints1, I1);

[imagePoints2, validIdx] = step(tracker, I2);
matchedPoints1 = imagePoints1(validIdx, :);
matchedPoints2 = imagePoints2(validIdx, :);

%figure
%showMatchedFeatures(I1, I2, matchedPoints1, matchedPoints2);
%title('Tracked Features');


%%

% Estimate the fundamental matrix
[fMatrix, epipolarInliers] = estimateFundamentalMatrix(...
  matchedPoints1, matchedPoints2, 'Method', 'MSAC', 'NumTrials', 10000);

% Find epipolar inliers
inlierPoints1 = matchedPoints1(epipolarInliers, :);
inlierPoints2 = matchedPoints2(epipolarInliers, :);

% Display inlier matches
figure
showMatchedFeatures(I1, I2, inlierPoints1, inlierPoints2);
title('Epipolar Inliers');

imagePoints1 = detectHarrisFeatures(I1, 'MinQuality', 0.001);

tracker = vision.PointTracker('MaxBidirectionalError', 1, 'NumPyramidLevels', 5);
imagePoints1 = imagePoints1.Location;
initialize(tracker, imagePoints1, I1);

[imagePoints2, validIdx] = step(tracker, I2);
matchedPoints1 = imagePoints1(validIdx, :);
matchedPoints2 = imagePoints2(validIdx, :);

camMatrix1 = [6.471884e+02 0.000000e+00 6.411610e+02 0.000000e+00; 0.000000e+00 6.471884e+02 1.821622e+02 0.000000e+00; 0.000000e+00 0.000000e+00 1.000000e+00 0.000000e+00];
camMatrix2 = [6.471884e+02 0.000000e+00 6.411610e+02 -3.745166e+02; 0.000000e+00 6.471884e+02 1.821622e+02 0.000000e+00; 0.000000e+00 0.000000e+00 1.000000e+00 0.000000e+00];

points3D = triangulate(matchedPoints1, matchedPoints2, transpose(camMatrix1), transpose(camMatrix2));
ptCloud = pointCloud(points3D);
ptCloud = pcdenoise(ptCloud);

indices = findPointsInROI(ptCloud, [ptCloud.XLimits; ptCloud.YLimits; [0 100]]);
pointsToShow = ptCloud.Location(indices,:);


%%
%Display of points and cameras

R = [9.998474e-01 1.693211e-02 4.306621e-03; -1.681709e-02 9.995341e-01 -2.547061e-02; -4.735886e-03 2.539430e-02 9.996663e-01];
T = [-5.786164e-01 8.176106e-03 8.309801e-03];

cameraSize = 1;
figure
plotCamera('Size', cameraSize, 'Color', 'r', 'Label', '1', 'Opacity', 0);
hold on
grid on
plotCamera('Location', T, 'Orientation', R, 'Size', cameraSize, ...
    'Color', 'b', 'Label', '2', 'Opacity', 0);

pcshow(pointsToShow, 'VerticalAxis', 'y', 'VerticalAxisDir', 'down', ...
    'MarkerSize', 45);

camorbit(0, -30);
camzoom(1.5);

xlabel('x-axis');
ylabel('y-axis');
zlabel('z-axis')

title('Up to Scale Reconstruction of the Scene');
