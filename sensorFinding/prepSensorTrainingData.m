function [X, y] = prepSensorTrainingData(sensorImagesPath, notSensorImagesPath)
%function [X, y] = prepSensorTrainingData(sensorImagesPath, notSensorImagesPath)

sensorImages = getImagesSub(sensorImagesPath);

notSensorImages = getImagesSub(notSensorImagesPath);

X = [sensorImages; notSensorImages];

numSensors = size(sensorImages, 1);
numNotSensors = size(notSensorImages, 1);

y = [ones(numSensors, 1); zeros(numNotSensors, 1)];

end


function images = getImagesSub(basePath)
    files = dir([basePath '*.png']);
    imagesCell = arrayfun(@(f) rgb2gray(imread([basePath f.name])), files, 'UniformOutput', 0);
    
    newLength = 30;
    numSamples = length(imagesCell);
    images = zeros(numSamples, newLength^2);
    
    for i = 1:numSamples
        im = resizeSub(double(imagesCell{i}), newLength);
        images(i,:) = im(:)';
    end
end

function resizedIm = resizeSub(im, numSamples)
    currentR = size(im, 1);
    currentC = size(im, 2);
    
    numSpaces = numSamples - 1;
    
    calcSpacing = @(l) (l - 1)/numSpaces;
    
    rowSpacing = calcSpacing(currentR);
    colSpacing = calcSpacing(currentC);
    
    [X, Y] = meshgrid(1:rowSpacing:currentR, 1:colSpacing:currentC);
    imReady = zeros(size(im, 1) + 3, size(im, 2) + 3);
    imReady(2:end-2,2:end-2) = double(im);
    resizedIm = interp2(imReady, X, Y, 'cubic');
end