%This is the structure from motion I tried to recode by myself
loadImages
I1 = image1s{1};
I2 = image2s{1};


i1 = HarrisDetect(image1s{1});
i2 = HarrisDetect(image2s{1});

[matchedPoints1, matchedPoints2] = Correlation(i1, i2, image1s{1}, image2s{1});


%%
%We choose eight random points to use the 8 points algorithm
indexes = randperm(size(matchedPoints1,1));
indexes = indexes(1:8);

[FMatrix] = FundamentalMatrix(matchedPoints1(indexes,:), matchedPoints2(indexes, :));
%NB : in the kitty dataset we already know P1 and P2 so we don't really
%need to compute the fundamental Matrix
%%
%Triangulation of the matched points
%Camera params come from the dataset
camMatrix1 = [6.471884e+02 0.000000e+00 6.411610e+02 0.000000e+00; 0.000000e+00 6.471884e+02 1.821622e+02 0.000000e+00; 0.000000e+00 0.000000e+00 1.000000e+00 0.000000e+00];
camMatrix2 = [6.471884e+02 0.000000e+00 6.411610e+02 -3.745166e+02; 0.000000e+00 6.471884e+02 1.821622e+02 0.000000e+00; 0.000000e+00 0.000000e+00 1.000000e+00 0.000000e+00];


[x3Dcoor] = triangulatee(matchedPoints1, matchedPoints2, camMatrix1, camMatrix2);

%%
% Display of 3D points

%Rotation and translation between the cameras
R = [9.998474e-01 1.693211e-02 4.306621e-03; -1.681709e-02 9.995341e-01 -2.547061e-02; -4.735886e-03 2.539430e-02 9.996663e-01];
T = [-5.786164e-01 8.176106e-03 8.309801e-03];

cameraSize = 1;
figure
plotCamera('Size', cameraSize, 'Color', 'r', 'Label', '1', 'Opacity', 0);
hold on
grid on
plotCamera('Location', T, 'Orientation', R, 'Size', cameraSize, ...
    'Color', 'b', 'Label', '2', 'Opacity', 0);

pcshow(transpose(x3Dcoor), 'VerticalAxis', 'y', 'VerticalAxisDir', 'down', ...
    'MarkerSize', 45);

camorbit(0, -30);
camzoom(1.5);

xlabel('x-axis');
ylabel('y-axis');
zlabel('z-axis')

title('Up to Scale Reconstruction of the Scene');

