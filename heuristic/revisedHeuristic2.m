function [var_x,passesVector,utility,runTime] = revisedHeuristic2(units, budget, edge2unitMap)

% Start clock
tic

% Initialization
numUnits = size(units,1);
var_x = zeros(numUnits,1);
passesVector = zeros(size(edge2unitMap,1),1);
utilityVector = zeros(numUnits,1);
idVector = transpose(1:numUnits);
utility = 0;
costVector = zeros(numUnits,1);
candidateUnits = find(costVector<=budget);
edge2unitMap(:,~candidateUnits) = 0;
for i=1:numUnits
   utilityVector(i) = sum(units{i}.utilityVector);
   costVector(i) = units{i}.equippingCost;
end

while (~isempty(candidateUnits))
    
    % Sort candidate units according to their improvement in utility
    %[~,id] = sort(utilityVector(candidateUnits),'descend');
    [~,id] = sortrows([utilityVector(candidateUnits) idVector(candidateUnits)],[-1,2]);
    candidateUnits = candidateUnits(id);
    
    % Equip unit
    selectedUnit = candidateUnits(1);
    if utilityVector(selectedUnit)>0
        var_x(selectedUnit)=1;  
    else
       break; 
    end
    
    % Update utility and budget
    utility = utility + utilityVector(selectedUnit);
    budget = budget-units{selectedUnit}.equippingCost;
    
    % Update passes vector
    passesVector(units{selectedUnit}.edgePasses(:,1)) = passesVector(units{selectedUnit}.edgePasses(:,1)) + units{selectedUnit}.edgePasses(:,2);
    
    % Update candidate units
    candidateUnits(1) = [];
    candidateUnits = candidateUnits(costVector(candidateUnits)<=budget);
    
    % Update utility vectors of candidate units
    edge2unitMap(:,selectedUnit) = 0;
    if ~isempty(candidateUnits)
        idx = units{selectedUnit}.utilityVector>0;
        %e = units{selectedUnit}.edgePasses(idx,1);
        e = units{selectedUnit}.edgePasses(:,1);
        for i=1:size(e,1)
            unitIDs = find(edge2unitMap(e(i),:)==1);
            for j=1:length(unitIDs)
               pos = find(units{unitIDs(j)}.edgePasses(:,1)==e(i));
               numColumns = size(units{unitIDs(j)}.utilityMatrix,2);
               startPos = passesVector(e(i))+1;
               if startPos > numColumns
                   units{unitIDs(j)}.utilityVector(pos) = 0;
               else
                   endPos = startPos+units{unitIDs(j)}.edgePasses(pos,2)-1;
                   endPos = min(endPos,numColumns);
                   units{unitIDs(j)}.utilityVector(pos) = sum(units{unitIDs(j)}.utilityMatrix(pos,startPos:endPos));
               end
            end
        end
    end    
    for i=1:length(candidateUnits)
       unit = units{candidateUnits(i)};
%        idx = unit.utilityVector>0;
%        unit.edgePasses = unit.edgePasses(idx,:);
%        unit.utilityVector = unit.utilityVector(idx);
       utilityVector(candidateUnits(i)) = sum(unit.utilityVector);
       units{candidateUnits(i)} = unit;
    end
end

% Stop clock
runTime = toc;
end



