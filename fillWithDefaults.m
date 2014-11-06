function filledObj = fillWithDefaults( obj, def )
%function filledObj = fillWithDefaults( obj, def )
%example:
%   obj.a = 1;
%   def.a = 2;
%   def.b = 3;
%   res = fillWithDefaults(obj, def) % res.a:1; res.b:3

if nargin < 2
    def = {};
end

keys = fieldnames(obj);

numKeys = length(keys);


filledObj = def;

for i = 1:numKeys
    key = keys{i};
    objVal = obj.(key);
    
    if isfield(def, key)
        defVal = def.(key);
        if isstruct(defVal) && isstruct(objVal)
            objVal = fillWithDefaults(objVal, defVal);
        end
    end
    
    filledObj.(key) = objVal;
end

end
