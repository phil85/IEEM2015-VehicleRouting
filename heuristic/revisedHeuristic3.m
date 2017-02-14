function [var_x,passesVector,utility,runTime] = revisedHeuristic3(reqPasses, units, budget, edge2unitMap,a,U)

% Start clock
tic

% Initialization
numUnits = size(units,1);
var_x = zeros(numUnits,1);
passesVector = zeros(size(edge2unitMap,1),1);
edgeUtilityVector = zeros(size(edge2unitMap,1),1);
unitUtilityVector = zeros(numUnits,1);
%idVector = transpose(1:numUnits);
costVector = zeros(numUnits,1);
candidateUnits = find(costVector<=budget);
edge2unitMap(:,~candidateUnits) = 0;
for i=1:numUnits
   unitUtilityVector(i) = sum(units{i}.utilityVector);
   costVector(i) = units{i}.equippingCost;
end
s = unitUtilityVector./costVector;
utilityMap = U;

while (~isempty(candidateUnits))
    
    % Sort candidate units according to their improvement in utility
    [~,id] = sort(s(candidateUnits),'descend');
    candidateUnits = candidateUnits(id);
    
    % Equip unit
    selectedUnit = candidateUnits(1);
    if unitUtilityVector(selectedUnit)>0
        var_x(selectedUnit)=1;  
    else
       break; 
    end
    
    % Update budget
    budget = budget-units{selectedUnit}.equippingCost;
    
    % Update passes and edgeUtility vector
    passesVector(units{selectedUnit}.edgePasses(:,1)) = passesVector(units{selectedUnit}.edgePasses(:,1)) + units{selectedUnit}.edgePasses(:,2);
    edgeUtilityVector(units{selectedUnit}.edgePasses(:,1)) = edgeUtilityVector(units{selectedUnit}.edgePasses(:,1)) + units{selectedUnit}.utilityVector;
    
    % Update candidate units
    candidateUnits(1) = [];
    candidateUnits = candidateUnits(costVector(candidateUnits)<=budget);
    
    % Update utility vectors of candidate units
    edge2unitMap(:,selectedUnit) = 0;
    if ~isempty(candidateUnits)
        idx = units{selectedUnit}.utilityVector>0;
        e = units{selectedUnit}.edgePasses(idx,1);
        map = edge2unitMap(e,:);
        unitIDs = find(sum(map,1)>0);
        
        for i=1:length(unitIDs)
           unit = units{unitIDs(i)};
           [unitUtilityVector(unitIDs(i)),unit.utilityVector] = getUtility(unit,passesVector,utilityMap,edgeUtilityVector);
           idx = unit.utilityVector>0;
           edge2unitMap(unit.edgePasses(~idx,1),unitIDs(i)) = 0;
           unit.edgePasses = unit.edgePasses(idx,:);
           unit.utilityVector = unit.utilityVector(idx);
           units{unitIDs(i)} = unit;
        end
        s(unitIDs) = unitUtilityVector(unitIDs)./costVector(unitIDs);
    end
end
utility = sum(edgeUtilityVector);

function [utility,utilityVector]= getUtility(unit,coverageVector,utilityMap,edgeUtilityVector)
    edgeIDs = unit.edgePasses(:,1);
    passes = unit.edgePasses(:,2);
    newCoverageVector = coverageVector(edgeIDs)+passes;

    K = min(max(newCoverageVector),size(utilityMap,2));
    utilityMap = utilityMap(edgeIDs,1:K);
    newCoverageMap = zeros(size(utilityMap));
    for k=1:K
        newCoverageMap(:,k) = newCoverageVector>k-1;
    end
    utilityVector = sum(utilityMap.*newCoverageMap,2)-edgeUtilityVector(edgeIDs);
    utility = sum(utilityVector);
end

% Stop clock
runTime = toc;
end



