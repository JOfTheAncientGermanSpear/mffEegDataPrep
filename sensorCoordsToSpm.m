function [fiducials, sensors] = sensorCoordsToSpm(sensorCoords)
%function [fiducials, sensors] = sensorCoordsToSpm(sensorCoords)
    
    regSensorsIndxs = arrayfun(@(s)s.type == 0, sensorCoords);
    
    calibSensorsIndxs = arrayfun(@(s)s.type == 2, sensorCoords);
    
    regSensorsCoords = sensorCoords(regSensorsIndxs);
    calibSensorsCoords = sensorCoords(calibSensorsIndxs);
    
    chanpos = zeros(length(regSensorsCoords), 3);
    chantype = repmat({'EEG'}, length(regSensorsCoords), 1);
    
    for i = 1:length(regSensorsCoords)
        mffS = regSensorsCoords(i);
        chanpos(i, :) = [mffS.x, mffS.y, mffS.z];
    end
    
    unit = 'cm';
    
    
    fid = calfidSub(calibSensorsCoords);
    
    
    %sensors
    
    eeg.chanpos = chanpos;
    eeg.chantype = chantype;
    eeg.elecpos = chanpos;
    
    eeg.fid = fid;
    
    eeg.unit = unit;
    
    sensors.eeg = eeg;
    
    
    
    %fiducials
    
    fiducials.pnt = chanpos;
    
    fiducials.fid = fid;
    fiducials.unit = unit;
    
end

function fid = calfidSub(calibSensorsCoords)
    label = repmat({''}, 3, 1);
    pnt = zeros(3);
    label(1) = {'nas'};
    label(2) = {'lpa'};
    label(3) = {'rpa'};
    for i = 1: length(calibSensorsCoords)
        pnt(i,:) = sensorPtSub(calibSensorsCoords(i));
    end
    
    fid.pnt = pnt;
    fid.label = label;
end

function pt = sensorPtSub(sensor)
    pt = [sensor.x, sensor.y, sensor.z];
end