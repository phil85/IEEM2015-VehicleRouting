classdef MyUnit
    
    properties
        id = -1;
        edgePasses = [];
        equippingCost = 0;
        utilityVector = [];
        utilityMatrix = [];
    end
    
    methods
        function U = MyUnit(id)
            U.id = id;
        end        
        function plotUnit(this,nodes,edges)
            w = zeros(size(edges,1),1);
            w(this.edgePasses(:,1))=this.edgePasses(:,2);
            plotRoadNetwork(nodes,edges,w,['Unit ' num2str(this.id)],'Passes');
        end
    end
end

