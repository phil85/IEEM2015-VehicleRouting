% Create map of illustrative example
nodes = zeros(14,2);
nodes(1,:) = [0 5];
nodes(2,:) = [3 5];
nodes(3,:) = [5 5];
nodes(4,:) = [7 5];
nodes(5,:) = [3 4];
nodes(6,:) = [5 4];
nodes(7,:) = [7 4];
nodes(8,:) = [0 3];
nodes(9,:) = [3 3];
nodes(10,:) = [5 3];
nodes(11,:) = [7 3];
nodes(12,:) = [0 1];
nodes(13,:) = [3 1];
nodes(14,:) = [5 1];

edges = zeros(20,2);
edges(1,:) = [1 2];
edges(2,:) = [2 3];
edges(3,:) = [3 4];
edges(4,:) = [5 6];
edges(5,:) = [6 7];
edges(6,:) = [8 9];
edges(7,:) = [9 10];
edges(8,:) = [10 11];
edges(9,:) = [12 13];
edges(10,:) = [13 14];
edges(11,:) = [14 11];
edges(12,:) = [1 8];
edges(13,:) = [8 12];
edges(14,:) = [2 5];
edges(15,:) = [5 9];
edges(16,:) = [9 13];
edges(17,:) = [6 10];
edges(18,:) = [10 14];
edges(19,:) = [4 7];
edges(20,:) = [7 11];

reqPasses = zeros(20,1);
reqPasses(1) = 1;
reqPasses(2) = 5;
reqPasses(3) = 4;
reqPasses(4) = 3;
reqPasses(5) = 5;
reqPasses(6) = 3;
reqPasses(7) = 3;
reqPasses(8) = 4;
reqPasses(9) = 2;
reqPasses(10) = 3;
reqPasses(11) = 2;
reqPasses(12) = 4;
reqPasses(13) = 3;
reqPasses(14) = 1;
reqPasses(15) = 5;
reqPasses(16) = 3;
reqPasses(17) = 5;
reqPasses(18) = 2;
reqPasses(19) = 5;
reqPasses(20) = 1;

% Plot map
% figure
% plotRoadNetwork(nodes,edges,reqPasses,'Road network','Required passes');

% Unit 1
unit1 = MyUnit(1);
unit1.equippingCost = 1;
edgePasses = [
  12 2;
  13 2;
  9 2;
  16 2;
  7 2;
  8 2;
];
unit1.edgePasses = edgePasses;
%unit1.plotUnit(nodes,edges);

% Unit 2
unit2 = MyUnit(2);
unit2.equippingCost = 1;
edgePasses = [
    12 3;
    6 3;
    7 3;
    8 3;
    20 3;
    19 3;
];
unit2.edgePasses = edgePasses;
%unit2.plotUnit(nodes,edges);

% Unit 3
unit3 = MyUnit(3);
unit3.equippingCost = 1;
edgePasses = [
    3 4;
    2 4;
    14 4;
    4 4;
    17 4;
    18 4;
];
unit3.edgePasses = edgePasses;
% unit3.plotUnit(nodes,edges);

% Unit 4
unit4 = MyUnit(4);
unit4.equippingCost = 1;
edgePasses = [
  1 3;
  14 3;
  15 3;
  16 3;
  10 3;
  11 3;
];
unit4.edgePasses = edgePasses;
% unit4.plotUnit(nodes,edges);

% Unit 5
unit5 = MyUnit(5);
unit5.equippingCost = 1;
edgePasses = [
    9 2;
    10 2;
    18 2;
    17 2;
    5 2;
];
unit5.edgePasses = edgePasses;
% unit5.plotUnit(nodes,edges);

units = cell(5,1);
units{1} = unit1;
units{2} = unit2;
units{3} = unit3;
units{4} = unit4;
units{5} = unit5;

% Create edge2unitMap
numUnits = size(units,1);
edge2UnitMap = zeros(size(edges,1),numUnits);
edgeUseVector = zeros(size(edges,1),1);
for i=1:numUnits
    edgeUseVector(units{i}.edgePasses(:,1))=1;
    edge2UnitMap(units{i}.edgePasses(:,1),i)=1;
end

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

% Create matrix containing u_ej values
max_j = max(reqPasses);
U = zeros(size(edges,1),max_j);
for i=1:size(edges,1)
   for j=1:reqPasses(i)
%        % generate random number in the interval [0,b] 
%        if j==1
%           b = 1; 
%        else
%           b = U(i,j-1); 
%        end
%        U(i,j) = 0 + b*rand(1);
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
      utilityVector(j) = sum(utilityMatrix(j,1:units{i}.edgePasses(j,2)));
   end
   units{i}.utilityMatrix = utilityMatrix;
   units{i}.utilityVector = utilityVector;
end

% Shrink edge2UnitMap
edge2UnitMap(edgeUseVector==0,:) = [];

% Create instance
nodes = n;
edges = e;
IEInstance = MyInstance(1,'IEInstance',U,nodes,edges,reqPasses,0,units,edge2UnitMap,5,0.5,1);
save('data/IEInstance.mat','IEInstance','-v7.3');
