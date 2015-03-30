function writeEvents(events, durations, fileName, beginTime, timeFromGmt)
%function writeEvents(events, fileName, beginTime, '-04:00')
	eventTrack = com.mathworks.xml.XMLUtils.createDocument('eventTrack');
	eventTrackEl = eventTrack.getDocumentElement;
	eventTrackEl.setAttribute('xmlns', 'http://www.egi.com/event_mff');
	eventTrackEl.setAttribute('xmlns:xsi', 'http://www.w3.org/2001/XMLSchema-instance');

	function node = textNode(name, text)
		node = eventTrack.createElement(name);
		if nargin > 1
			node.appendChild(eventTrack.createTextNode(text));
        end
	end

	eventTrackEl.appendChild(textNode('name', '8 DINs'));

	eventTrackEl.appendChild(textNode('trackType', 'STIM'));
    
    function key = createKey(code, desc)
        key = eventTrack.createElement('key');	
        key.appendChild(textNode('keyCode', code));
        data = textNode('data', num2str(desc));
        data.setAttribute('dataType', 'string');
        key.appendChild(data);
    end

	numEvents = length(events);

	for i = 1:numEvents
		eData = events(i);
		event = eventTrack.createElement('event');

        bTime = beginTime + seconds(eData.time);
        yearMonthDay = datestr(bTime, 'yyyy-mm-dd');
        hourMinSec = [datestr(bTime, 'HH:MM:') num2str(bTime.Second)];
        bTime = [yearMonthDay 'T' hourMinSec timeFromGmt];
        
		event.appendChild(textNode('beginTime', bTime));
		event.appendChild(textNode('duratation', num2str(durations(i))));
		event.appendChild(textNode('code', 'DIN1'));
		event.appendChild(textNode('label', eData.label));
        event.appendChild(textNode('description', num2str(i)));
		event.appendChild(textNode('sourceDevice'));

		keys = eventTrack.createElement('keys');

		keys.appendChild(createKey('gidx', i));
		keys.appendChild(createKey('cidx', i));

		event.appendChild(keys);

		eventTrackEl.appendChild(event);
	end

    
	xmlwrite(fileName, eventTrack);
end