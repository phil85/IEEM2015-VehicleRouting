classdef MySolution
   
    properties
        id = -1;
        instanceName = '';
        budget = [];
        timeLim = [];
        coverage = [];
        runTime = [];
        var_x = [];
        var_y = [];
        resultNum = [];
        bestBound = [];
        solApproach = -1;
        solApproachName = [];
    end
    
    methods
        function S = MySolution(id,instanceName,solApproach,solApproachName,budget,timeLim)
            S.id = id;
            S.instanceName = instanceName;
            S.solApproach = solApproach;
            S.solApproachName = solApproachName;
            S.budget = budget;
            S.timeLim = timeLim;
            S.resultNum = -1;
            S.bestBound = -1;
        end   
        function plotSol(this)
            f = figure('visible','off');
            %f = figure;
            load(['data/' this.instanceName '.mat']);
            
            if strcmp(this.instanceName,'IEInstance')
                inst = IEInstance;
            end

            n=inst.nodes;
            e=inst.edges;
            units=inst.units;
            
            w = this.var_y;
            equippedUnitsStr = 'Equipped units = \{';
            makeComma = false;
            for i=1:size(units,1)
                if this.var_x(i)
                    if makeComma
                        equippedUnitsStr = [equippedUnitsStr ',' num2str(units{i}.id)];    
                        makeComma = true;
                    else
                        equippedUnitsStr = [equippedUnitsStr num2str(units{i}.id)];    
                        makeComma = true;
                    end
                end
            end
            
            equippedUnitsStr = [equippedUnitsStr '\}'];
            fileName = [this.instanceName '_' this.solApproachName '_' num2str(this.budget)];

            plotRoadNetwork(n,e,w,{this.solApproachName,['Instance: ' this.instanceName],['Budget: ' num2str(this.budget)],['OFV: ' num2str(this.coverage)],['Run time: ' num2str(this.runTime)],equippedUnitsStr},'Number of passes');
            print([fileName '.png'],'-dpng');
            close(f);
        end        
    end
    
end

