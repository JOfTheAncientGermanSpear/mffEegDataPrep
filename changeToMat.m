function D = changeToMat(inputFile)
    [filePath, basename, ~] = fileparts(inputFile);
    D = [filePath filesep basename '.mat'];
end