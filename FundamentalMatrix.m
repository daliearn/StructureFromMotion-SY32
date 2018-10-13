function [FunMatrix] = FundamentalMatrix(points1, points2)
%This function estimates the fundamental matrix with the
%eight-points-algoithm
points1 = transpose(points1);
points2 = transpose(points2);

%Passing in homogenous coordinates
points1 = [points1; ones(1, size(points1, 2))];
points2 = [points2; ones(1, size(points2, 2))];

%The normalize function was given by our professor
[x, T] = normalize(points1, 3, true);
[xp, Tp] = normalize(points2, 3, true);

x = transpose(x);
xp = transpose(xp);

A = zeros(length(x), 9);

%Constitution of A matrix
for i = 1:length(x)
    A(i, :) =  [(xp(i,1)*x(i,1)) (xp(i,1)*x(i,2)) (xp(i,1)) (xp(i,2)*x(i,1)) (xp(i,2)*x(i,2)) xp(i,2) x(i,1) x(i,2) 1];
end

%This set of calculus does point by point the minimisation of Frobenius
%norm as described by the 8 points algorithm.
[U S V] = svd(A);
f = V(:,end);
F = vec2mat(f, 3,3);
[U S V] = svd(F);
S(:,end) = [0;0;0];
Fp = U * S * transpose(V);
Fpfinal = transpose(Tp) * Fp * T;
FunMatrix = Fpfinal

end