function [matchedPoints1, matchedPoints2] = Correlation(pointLocations1, pointLocations2, I1, I2)

I1 = im2double(I1);
I2 = im2double(I2);

%Size of the window for SSD
h = 4;

Matrix = zeros(size(pointLocations1,1), size(pointLocations2,1));

%For each combination of corners detected, we calculate the sum of square
%difference to estimate the correlation between thes points.
for i=1: size(pointLocations1,1)
    i
    for j=1: size(pointLocations2,1)
      
        x1 = pointLocations1(i, 1) - h;
        x2 = pointLocations1(i, 1) + h;
        y1 = pointLocations1(i, 2) - h;
        y2 = pointLocations1(i, 2) + h;
        
        window1 = I1(y1 : y2, x1 : x2 );
        
        x1 = pointLocations2(j, 1) - h;
        x2 = pointLocations2(j, 1) + h;
        y1 = pointLocations2(j, 2) - h;
        y2 = pointLocations2(j, 2) + h;
        
        window2 = I2(y1 : y2, x1 : x2 );
        
        summ = (window1 - window2).^2;
        Matrix(i,j) = sum(sum(summ));
    end
end
%%
%We sort thes pairs of points by score in correlation
[sortedValues,sortIndex] = sort(Matrix(:),'ascend'); 
maxIndex = sortIndex(1:size(pointLocations1,1));
[x, y] = ind2sub([size(Matrix)],maxIndex)
xy = [x y];

%Then we'll remove points linked to two or more points
%Each point have to be linked to only one point
i = 1;
while i < size(xy,1)
    j = i;
    while j < size(xy,1)
        if(xy(j,1) == xy(i,1))
            xy(j,:) = [];
        end
        j = j+1;
    end
    i = i +1;
end
i = 1;
while i < size(xy,1)
    j = i;
    while j < size(xy,1)
        if(xy(j,2) == xy(i,2))
            xy(j,:) = [];
        end
        j = j+1;
    end
    i = i +1;
end
%%
xx = zeros(size(xy, 1), 2);
yy = zeros(size(xy, 1), 2);

for i = 1:size(xy, 1)
   xx(i,:) = pointLocations1(xy(i,1), :);
   yy(i,:) = pointLocations2(xy(i,2), :);
end

matchedPoints1 = xx;
matchedPoints2 = yy;

%showMatchedFeatures(I1, I2, xx, yy)

%%
%Deletion of outliers (without RANSAC)

%For each pair we calculate the distance between the two points
diff = sqrt((xx(:,1) - yy(:,1)).^2 + (xx(:,2) - yy(:,2)).^2);

vec = zeros(size(xy));
normalizedVec = zeros(size(xy));

%We calculate the mean vector i.e the mean of coordinate of all vectors
%described by pair of points
for i = 1:size(xy, 1)
   vec(i, :) = xx(i,:) - yy(i,:);
   normalizedVec(i, :) = vec(i, :) / norm(vec(i, :));
end

meanVec = mean(normalizedVec);

xxFinal = [];
yyFinal = [];

%This is our "dirty" way to delete outliers : if the norm of the vector is
%much greater than the mean vector or if the angle with the mean vector is
%to important we consider it as an outlier. 

%NB : this way os very bad for the general case but works a bit for cars on
%roads
for i = 1:size(diff, 1)
   if (diff(i) < 5 * norm(median(vec)))
       if ( dot(meanVec, (xx(i,:) - yy(i,:))) / (norm(meanVec) * norm((xx(i,:) - yy(i,:)))) > 0.9)
          xxFinal = [xxFinal; xx(i, :)];
          yyFinal = [yyFinal; yy(i, :)];
       end
   end
   
end
matchedPoints1 = xxFinal;
matchedPoints2 = yyFinal;
showMatchedFeatures(I1, I2, xxFinal, yyFinal);

end
