classdef MyInstance
    
    properties
        U = [];
        id = -1;
        name = '';
        nodes = [];
        edges = [];
        reqPasses = [];
        budget = 0;
        units = [];
        edge2UnitMap = [];
        bestBound = [];
        re = -1;
        a = -1;
        c = -1;
    end
    
    methods
        function I = MyInstance(id,name,U,nodes,edges,reqPasses,budget,units,edge2UnitMap,re,a,c)
            I.U = U;
            I.id = id;
            I.name = name;
            I.nodes = nodes;
            I.edges = edges;
            I.reqPasses = reqPasses;
            I.budget = budget;
            I.units = units;
            I.edge2UnitMap = edge2UnitMap;
            I.re = re;
            I.a = a;
            I.c = c;
            I.bestBound = -1;
        end    
        function writeDat(this)
            
            tmp = what('data');
            path = [tmp(1).path '\'];
            fileID = fopen([path this.name '.dat'],'w');
            
            m = size(this.edges,1);
            numUnits = size(this.units,1);
            
            % Set of edges
            fprintf(fileID,'set E:= ');
            for i=1:m
                fprintf(fileID,'%d ',i);
            end
            fprintf(fileID,';\n\n');
            
            % Set of units
            fprintf(fileID,'set I:= ');
            for i=1:numUnits
                fprintf(fileID,'%d ',i);
            end
            fprintf(fileID,';\n\n');
            
            % Budget
            fprintf(fileID,'param B:= %f;\n\n',this.budget);

            % Equipping cost
            fprintf(fileID,'param c :=\n');
            for i=1:numUnits
                fprintf(fileID,'%d %f\n',i,this.units{i}.equippingCost);
            end
            fprintf(fileID,';\n\n');
            
            % Required number of passes
            fprintf(fileID,'param r := \n');
            for i=1:m
                fprintf(fileID,'[%d] %d \n',i,this.reqPasses(i));
            end
            fprintf(fileID,';\n\n');
            
            % Passes per unit
            fprintf(fileID,'let{i in I,e in E} a[i,e] := 0;\n');
            for i=1:numUnits
                if ~isempty(this.units{i}.edgePasses)
                    for j=1:size(this.units{i}.edgePasses,1)
                        fprintf(fileID,'let a[%d,%d] := %d; \n',i,this.units{i}.edgePasses(j,1),this.units{i}.edgePasses(j,2));
                    end
                end
            end
           
            fclose(fileID);
        end      
        function revisedWriteDat(this)
            
            path = 'data\';
            fileID = fopen([path this.name '.dat'],'w');
            
            m = size(this.edges,1);
            numUnits = size(this.units,1);
            
            % Set of edges
            fprintf(fileID,'set E:= ');
            for i=1:m
                fprintf(fileID,'%d ',i);
            end
            fprintf(fileID,';\n\n');
            
            % Set of units
            fprintf(fileID,'set I:= ');
            for i=1:numUnits
                fprintf(fileID,'%d ',i);
            end
            fprintf(fileID,';\n\n');
            
            % Set K
            fprintf(fileID,'set K:= ');
            for i=1:max(this.reqPasses)
                fprintf(fileID,'%d ',i);
            end
            fprintf(fileID,';\n\n');            
            
            % Budget
            fprintf(fileID,'param B:= %f;\n\n',this.budget);

            % Equipping cost
            fprintf(fileID,'param c :=\n');
            for i=1:numUnits
                fprintf(fileID,'%d %f\n',i,this.units{i}.equippingCost);
            end
            fprintf(fileID,';\n\n');
            
            % Required number of passes
            fprintf(fileID,'param r := \n');
            for i=1:m
                fprintf(fileID,'[%d] %d \n',i,this.reqPasses(i));
            end
            fprintf(fileID,';\n\n');
            
            % Passes per unit
            fprintf(fileID,'let{i in I,e in E} a[i,e] := 0;\n');
            for i=1:numUnits
                if ~isempty(this.units{i}.edgePasses)
                    for j=1:size(this.units{i}.edgePasses,1)
                        fprintf(fileID,'let a[%d,%d] := %d; \n',i,this.units{i}.edgePasses(j,1),this.units{i}.edgePasses(j,2));
                    end
                end
            end
            fprintf(fileID,'\n');
            
            % Increase in utility parameter uk
            fprintf(fileID,'let{i in E,k in K} uk[i,k] := 0;\n');
            for i=1:m
                for k=1:this.reqPasses(i)
                    fprintf(fileID,'let uk[%d,%d] := %f; \n',i,k,this.U(i,k));
                end
            end
            fclose(fileID);
        end            
    end
    
end

