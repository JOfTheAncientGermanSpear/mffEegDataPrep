function newName = prependToFilename(filename, prefix)
%function newName = prependToFilename(filename, prefixs)

[p, basename, ext] = fileparts(filename);
newName = [p filesep prefix basename ext];