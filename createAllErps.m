function createAllErps(mffBasepath, edfBasepath )
%function createAllErps(mffBasepath, edfBasepath )

tests = {'hand1','hand2','hand3','lang1','lang2'};

pipelineInputs = cellfun(@(t) createPipelineInput(t, mffBasepath, edfBasepath), tests, 'UniformOutput', false);

cellfun(@(i) runPipeline(i), pipelineInputs, 'UniformOutput', false);

end
