% Load street map
load('OSMART.mat');

% Load routes of USPS units
load('USPSID.mat');

% Initialization of variables
numUnits = size(uid,1);
edgeUseVector = zeros(size(edges,1),1);
unitUseVector = zeros(numUnits,1);
edges = edges(:,1:2);
edge2UnitMap = zeros(size(edges,1),numUnits);

% Create units
counter = 1;
units = cell(1,1);
for i=1:numUnits
    load(['data/RoutedUSPS/' num2str(uid(i)) '.mat']);
    if ~isempty(Data.edge)
        unit = MyUnit(uid(i));
        unit.equippingCost = 1;
        edgeIDs = unique(Data.edge);
        edgeCount = histc(Data.edge,unique(Data.edge));
        edgePasses = [edgeIDs' edgeCount'];
        unit.edgePasses = edgePasses; 
        units{counter,1} = unit;
        counter = counter +1;
        
        unitUseVector(i)=1;
        edgeUseVector(edgeIDs)=1;
        edge2UnitMap(edgeIDs,i)=1;
    end
end

% Determine number of required passes per edge
rng(24);
reqPasses = randi([0 5],size(edges,1),1);

% Remove unused edges
e = edges(edgeUseVector==1,:);
eInd = find(edgeUseVector);
newEdgeIDs = zeros(size(edges,1),1);
newEdgeIDs(edgeUseVector==1) = 1:size(e,1);
un = unique(e(:)); % unique nodes ids
n = nodes(un,:);
for i = 1:size(n,1)
    e(e(:)==un(i)) = i;
end
reqPasses = reqPasses(edgeUseVector==1);

% Relabel edges of units
numUnits = size(units,1);
for i=1:numUnits
    units{i}.edgePasses(:,1) = newEdgeIDs(units{i}.edgePasses(:,1));
end

% Count total number of potential passes per edge
numPasses = zeros(size(e,1),1);
numUnits = size(units,1);
for i=1:numUnits
   numPasses(units{i}.edgePasses(:,1)) =  numPasses(units{i}.edgePasses(:,1)) + units{i}.edgePasses(:,2);
end

% Plot units
% figure;units{1}.plotUnit(n,e);

% Compute utility matrix for each unit
for i=1:numUnits
   requiredPasses = reqPasses(units{i}.edgePasses(:,1));
   utilityMatrix = zeros(size(units{i}.edgePasses,1),max(requiredPasses));
   utilityVector = zeros(size(units{i}.edgePasses,1),1);
   for j=1:size(units{i}.edgePasses,1)
      for k=1:requiredPasses(j)
          utilityMatrix(j,k) = 1/2^(k-1);
      end
      endPos = min(size(utilityMatrix,2),units{i}.edgePasses(j,2));
      utilityVector(j) = sum(utilityMatrix(j,1:endPos));
   end
   units{i}.utilityMatrix = utilityMatrix;
   units{i}.utilityVector = utilityVector;
end

% Shrink edge2UnitMap
edge2UnitMap(edgeUseVector==0,:) = [];
edge2UnitMap(:,unitUseVector==0) = [];

% Create instance
nodes = n;
edges = e;
USPSInstance = MyInstance(1,'USPSInstance',nodes,edges,reqPasses,0,units,edge2UnitMap);
save('data/USPSInstance.mat','USPSInstance','-v7.3');
