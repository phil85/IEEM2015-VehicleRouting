function [var_x,coverageVector,utility,runTime] = revisedHeuristic(reqPasses, units, budget)

% Start clock
tic

% Initialization
numUnits = size(units,1);
m = size(reqPasses,1);
var_x = zeros(numUnits,1);
utility = 0;
K = max(reqPasses);
costVector = zeros(numUnits,1);
hasPassesVector = zeros(numUnits,1);
coverageVector = zeros(m,1);
idVector = transpose(1:numUnits);
utilityMap = zeros(m,K);
for i=1:K
    utilityMap(:,i) = 1/2^(i-1);
    utilityMap(reqPasses<i,i) = 0;
end
for i=1:numUnits
    costVector(i) = units{i}.equippingCost;
    hasPassesVector(i) = ~isempty(units{i}.edgePasses);
end
candidateUnits = find(costVector<=budget & hasPassesVector);


while (~isempty(candidateUnits))
    % Initialization of unit-specific utility contributions
    contribution = zeros(size(candidateUnits,1),1);
    
    % Compute unit-specific contributions
    for i=1:size(candidateUnits,1)
        contribution(i) = computeContribution(units{candidateUnits(i)},coverageVector,utilityMap,K);
    end
    
    % Equip unit
    %[~,I] = sort(contribution,'descend');
    [~,I] = sortrows([contribution idVector(candidateUnits)],[-1,2]);
    selectedUnit = candidateUnits(I(1));
    if contribution(I(1))>0
        var_x(selectedUnit)=1;  
    else
       break; 
    end
    
    % Update coverage vector, budget and candidate units
    if isempty(units{selectedUnit}.edgePasses)
       break; 
    end
    edgeIDs = units{selectedUnit}.edgePasses(:,1);
    passes = units{selectedUnit}.edgePasses(:,2);
    coverageVector(edgeIDs) = coverageVector(edgeIDs)+passes;
    utility = utility+contribution(I(1));
    budget = budget-units{selectedUnit}.equippingCost;
    
    % Update candidate units
    candidateUnits(I(1)) = [];
    candidateUnits = candidateUnits(costVector(candidateUnits)<=budget);
end

% Stop clock
runTime = toc;
end

function contribution = computeContribution(unit,coverageVector,utilityMap,K)
    if ~isempty(unit.edgePasses)
        edgeIDs = unit.edgePasses(:,1);
        passes = unit.edgePasses(:,2);
        oldCoverageVector = coverageVector(edgeIDs);
        newCoverageVector = coverageVector(edgeIDs)+passes;
        
        K = min(max(newCoverageVector),K);
        utilityMap = utilityMap(edgeIDs,1:K);
        oldCoverageMap = zeros(size(utilityMap));
        newCoverageMap = zeros(size(utilityMap));
        for i=1:K
            oldCoverageMap(:,i) = oldCoverageVector>i-1;
            newCoverageMap(:,i) = newCoverageVector>i-1;
        end
        contribution = sum(sum(utilityMap.*newCoverageMap))-sum(sum(utilityMap.*oldCoverageMap));
    else
        contribution = 0;
    end
end



