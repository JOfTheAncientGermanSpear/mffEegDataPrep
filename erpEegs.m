function pipelineInputs = erpEegs(tests, mffPathBase)
%function pipelineInputs = erpEegs(tests, mffPathBase)

pipelineInputs = cellfun(@(t) createPipelineInput(t, mffPathBase), tests, 'UniformOutput', false);
pipelineInputs = [pipelineInputs{:}];

end