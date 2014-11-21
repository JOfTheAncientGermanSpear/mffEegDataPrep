function sensors = getSensorCoordinates(sensorsPath)
%function sensors = getSensors(sensorsPath)

theObject = javaObject('com.egi.services.mff.api.Coordinates', true);
sensorCoordinates = theObject.unmarshal(sensorsPath, true);

javaSensors = sensorCoordinates.getSensorLayout.getSensors();

numSensors = javaSensors.capacity();

sensors = repmat(struct('x', NaN, 'y', NaN, 'z', NaN, 'number', NaN, 'type', NaN), numSensors, 1);

for i = 1:numSensors
    javaS = javaSensors.get(i - 1); %java indexing
    s.x = javaS.getX();
    s.y = javaS.getY();
    s.z = javaS.getZ();
    s.number = javaS.getNumber();
    s.type = javaS.getType();
    sensors(i) = s;
end

end