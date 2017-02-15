function createInstances(dataName, re,a,c)

% Set random seed
rng(24);

% Load street map
load('OSMART.mat');

% Load routes of USPS units
if strcmp(dataName,'USPSInstance')
    load('USPSID.mat');    
end
if strcmp(dataName,'MetroInstance')
    load('WMATAMetroBusID.mat');
end

% Initialization of variables
numUnits = length(uid);
edgeUseVector = zeros(size(edges,1),1);
unitUseVector = zeros(numUnits,1);
edges = edges(:,1:2);
edge2UnitMap = zeros(size(edges,1),numUnits);

% Create units
counter = 1;
units = cell(1,1);
switch c
    case 1
        equippingCost = 1;
    case 2
        equippingCost = [1,3];
    case 3
        equippingCost = [1,3,5];
end

% Set path
if strcmp(dataName,'USPSInstance')
    path = 'data/RoutedUSPS/';
end
if strcmp(dataName,'MetroInstance')
    path = 'data/RoutedMetro/';
end

for i=1:numUnits
    load([path num2str(uid(i)) '.mat']);
    if ~isempty(Data.edge)
        unit = MyUnit(uid(i));
        % Draw equipping cost
        id = randi(c);
        unit.equippingCost = equippingCost(id);
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
reqPasses = randi([0 re],size(edges,1),1);

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

% Create matrix containing u_ej values
max_j = max(reqPasses);
U = zeros(size(reqPasses,1),max_j);
for i=1:size(reqPasses,1)
   for j=1:reqPasses(i)
%        % generate random number in the interval [0,b] 
%        if j==1
%           b = 1; 
%        else
%           b = U(i,j-1); 
%        end
%        U(i,j) = 0 + b*rand(1);
%        U(i,j) = 1-0.5^j;
        U(i,j) = 0.5^j;
   end
end

% Compute utility matrix for each unit
for i=1:numUnits
   requiredPasses = reqPasses(units{i}.edgePasses(:,1));
   utilityMatrix = zeros(size(units{i}.edgePasses,1),max(requiredPasses));
   utilityVector = zeros(size(units{i}.edgePasses,1),1);
   for j=1:size(units{i}.edgePasses,1)
      for k=1:requiredPasses(j)
          utilityMatrix(j,k) = U(units{i}.edgePasses(j,1),k);
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

instName = [dataName '_' num2str(re) '_' num2str(a) '_' num2str(c)];
inst = MyInstance(1,instName,U,nodes,edges,reqPasses,0,units,edge2UnitMap,re,a,c);
save(['data/' instName '.mat'],'inst','-v7.3');
