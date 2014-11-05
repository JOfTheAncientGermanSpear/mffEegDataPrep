function [mffEvents, Fs] = readMffEvents(mff_path)
%function [mffEvents, Fs] = readMffEvents(mff_path)
        hdr = read_mff_header(mff_path, 0);
    
        Fs = hdr.Fs;

        mffEvents = read_mff_event(mff_path);
end