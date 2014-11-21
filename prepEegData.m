function D = prepEegData(S)
%function D = prepEegData(S)
%adds event data & sensor locations to D
%inputs:
%   S: struct with following fields
%       D (required):
%           path to file of data to prep
%       sensorCoordinatesPath (required):
%           path to coordinates.xml file
%       events (required):
%           processed array of event data from mff file
%       prefix (required):
%           file name prefix
%           defaults to DataPrep

D = spm_eeg_load(S.D);

D = D.copy(prependToFilename(D.fullfile(), S.prefix));

D = D.events(1, S.events);

sensorCoordinates = getSensorCoordinates(S.sensorCoordinatesPath);

[fiducials, eegSensors] = sensorCoordsToSpm(sensorCoordinates);

D = D.fiducials(fiducials);
D = D.sensors('EEG', eegSensors);

D.save();