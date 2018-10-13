function pointLocation = HarrisDetect(Img)
    
    Img = im2double(Img);

    %Mask used to get gradient
    sx = [-1 0 1; -1 0 1; -1 0 1] / 3;
    sy = [1 1 1; 0 0 0; -1 -1 -1] / 3;
    
    %Size of the window = 2h + 1
    h = 4;
    %Parameter for harris detection
    k = 0.05;
    %Number of "corners" returned by harris detector.
    % We could have used a treshold
    nbPoints = 5000;
    
    R = zeros(size(Img));

    Ix = conv2(Img,sx, 'same');
    Iy = conv2(Img,sy, 'same');

    %We calculate this before the loop to speed up the algorithm
    Ix2 = Ix .* Ix;
    Iy2 = Iy .* Iy;
    Ixy = Ix .* Iy;

    for x=(1 + h):( size(Img,1) - h )
        x
        for y = (1 + h):( size(Img,2) - h )
            M = zeros(2,2);
            W = Img(x-h:x+h, y-h:y+h);
            window = double(imgaussfilt(W));

            M(1,1) = sum(sum(window .* Ix2(x-h:x+h, y-h:y+h)));
            M(2,1) = sum(sum(window .* Ixy(x-h:x+h, y-h:y+h)));
            M(1,2) = M(2,1);
            M(2,2) = sum(sum(window .* Iy2(x-h:x+h, y-h:y+h)));

            R(x,y) = det(M) - (k * (trace(M) ^ 2));
        end
    end

    pointLocation = [];
    %These 4 lines allow us to get indexes of the best ranked points
    [sortedValues,sortIndex] = sort(R(:),'descend'); 
    maxIndex = sortIndex(1:nbPoints);
    [x, y] = ind2sub([size(R)],maxIndex);
    pointLocation = [pointLocation; [y x]];

    imshow(insertMarker(Img, pointLocation));
end
