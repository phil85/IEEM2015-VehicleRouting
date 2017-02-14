function [var_x,var_y,coverage,runTime] = heuristic(reqPasses, units, budget)

% Initialization
numUnits = size(units,1);
m = size(reqPasses,1);
var_x = zeros(numUnits,1);
var_y = zeros(m,1);
coverage = 0;

tic
while (budget > 0 && sum(var_x)<numUnits)
    unequippedUnits = find(var_x==0);
    contribution_coverage = zeros(size(unequippedUnits,1),1);
    contribution_redReqPasses = zeros(size(unequippedUnits,1),1);

    % Compute contributions
    for i=1:size(unequippedUnits,1)
        contribution_coverage(i) = computeContCoverage(units{unequippedUnits(i)},reqPasses);
        contribution_redReqPasses(i) = computeContReqPasses(units{unequippedUnits(i)},reqPasses);
    end
    
    % Equip unit
    [~,I] = sortrows([contribution_coverage contribution_redReqPasses],[-1,-2]);
    selectedUnit = unequippedUnits(I(1));
    var_x(selectedUnit)=1;
    
    % Update coverage,numReqPasses, and budget
    if isempty(units{selectedUnit}.edgePasses)
       break; 
    end
    edgeIDs = units{selectedUnit}.edgePasses(:,1);
    passes = units{selectedUnit}.edgePasses(:,2);
    reqPasses(edgeIDs) = max([reqPasses(edgeIDs) - passes zeros(size(edgeIDs,1),1)],[],2);
    coverage = sum(reqPasses==0);
    var_y(reqPasses==0) = 1;
    budget = budget-units{selectedUnit}.equippingCost;
end
runTime = toc;
end

function contribution = computeContCoverage(unit,reqPasses)
    if ~isempty(unit.edgePasses)
        edgeIDs = unit.edgePasses(:,1);
        passes = unit.edgePasses(:,2);
        candidateEdges = reqPasses(edgeIDs)>0;
        reqPassesAfter = reqPasses(edgeIDs)-passes;
        contribution = sum(reqPassesAfter(candidateEdges)<=0);
    else
       contribution = 0; 
    end
end
function contribution = computeContReqPasses(unit,reqPasses)
    if ~isempty(unit.edgePasses)
        edgeIDs = unit.edgePasses(:,1);
        passes = unit.edgePasses(:,2);
        reqPassesAfter = reqPasses(edgeIDs)-passes;
        negReqPassesAfter = reqPassesAfter<0;
        contribution = sum(passes(~negReqPassesAfter)) + sum(reqPasses(negReqPassesAfter));
    else
        contribution = 0;
    end
end



