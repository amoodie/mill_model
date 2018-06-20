
function [modelEvalZsN, modelEvalCsN] = normalize_model(modelEvalZs, modelEvalCs)
    modelEvalZsN = modelEvalZs ./ modelEvalZs(end);
    modelEvalCsN = modelEvalCs ./ modelEvalCs(1);
    
end
