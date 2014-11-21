function timewin = getEventsTimeWin(events, buffer)
%function timewin = getEventsTimeWin(events, buffer)

if nargin < 2
    buffer = [.1 6];
elseif len(buffer) == 1
    buffer = [buffer buffer];
else
end

startTime = events(1).time - buffer(1);
stopTime = events(end).time + buffer(2);

timewin = [startTime stopTime];