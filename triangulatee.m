function [x3Dcoor] =triangulatee(points1, points2, cam1, cam2)
% With pairs of points and camera parameters, we can get an approximation
% of 3D coordinates of a set of 2D points.
points1 = transpose(points1);
points2 = transpose(points2);

%We will use homogonous coordinates
x = [points1; ones(1, size(points1, 2))];
xp = [points2; ones(1, size(points2, 2))];


x = transpose(x);
xp = transpose(xp);

A = zeros(length(x), 9);

%These are the lines of the two cameras parameters
p1 = cam1(1, :);
p2 = cam1(2, :);
p3 = cam1(3, :);
p_1 = cam2(1, :);
p_2 = cam2(2, :);
p_3 = cam2(3, :);

%For each point we define A and we use svd to know X with AX = 0. X is the
%3D point in homgonous coordinates.
for i = 1:size(x, 1)
    A = [x(i,1) .* p3 - p1; ...
         x(i,2) .* p3 - p2; ...  
         xp(i,1) .* p_3 - p_1; ...
         xp(i,2) .* p_3 - p_2; ...  
        ];
    [U S V] = svd(A);
    x3D(:,i) = V(:,end);
end

%To remove the scale factor, we have to divide by the 4th coordinates each
%point.
for i = 1:size(x3D, 2)
   x3D(:,i) =  x3D(:,i)/x3D(4,i);
end

%We come back in standard coordinates
x3D = x3D(1:3,:)

x3Dcoor =  x3D;
end