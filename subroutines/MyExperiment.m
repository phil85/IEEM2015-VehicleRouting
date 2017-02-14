classdef MyExperiment
    
    properties
        id
        instance
        timeLim_exactApproach
        solutionGroups 
    end
    
    methods
        function E = MyExperiment(id,inst,timeLim)
            E.id = id;
            E.instance = inst;
            E.timeLim_exactApproach = timeLim;
        end          
        function E = solveHeuristically(this,nameOfHeuristic,budgets)
            
            % Write script
            groupCounter = length(this.solutionGroups)+1;
            this.solutionGroups{groupCounter} = cell(length(budgets),1);
            
            for i=1:length(budgets)
                disp(i);
                solution = MySolution(i,this.instance.name,2,nameOfHeuristic,budgets(i),-1);
                solution.bestBound = this.instance.bestBound(i);
                % Run heuristic
                a = this.instance.a;
                switch nameOfHeuristic
                    case 'heuristic'
                        [solution.var_x,solution.var_y,solution.coverage,solution.runTime] = heuristic(this.instance.reqPasses, this.instance.units, budgets(i));
                    case 'revisedHeuristic'
                        [solution.var_x,solution.var_y,solution.coverage,solution.runTime] = revisedHeuristic(this.instance.reqPasses, this.instance.units, budgets(i));
                    case 'revisedHeuristic2'
                        [solution.var_x,solution.var_y,solution.coverage,solution.runTime] = revisedHeuristic2(this.instance.units, budgets(i), this.instance.edge2UnitMap);        
                    case 'revisedHeuristic3'
                        [solution.var_x,solution.var_y,solution.coverage,solution.runTime] = revisedHeuristic3(this.instance.reqPasses, this.instance.units, budgets(i), this.instance.edge2UnitMap,a, this.instance.U);
                end
                this.solutionGroups{groupCounter}{i} = solution;
            end
            E = this;
        end                   
        function E = solveExactly(this,modelName,budgets,mode)
            % Write script
            this.writeScript(modelName,budgets,mode);
            
            % Write bat file
            fileID = fopen('mymodel/start.bat','w');
            fprintf(fileID,['ampl "../script/script_' this.instance.name '.txt"']);
            fclose(fileID);
            
            % Run optimization
            cd mymodel
            system('start.bat');
            cd ..
            
            % Parse results
            E = this.parseResults(modelName,budgets,mode);
        end 
        function E = validateSolutions(this,solutionGroup,modelName,budgets)
            % Write script
            this.writeValidationScript(solutionGroup,modelName,budgets);
            
            % Write bat file
            fileID = fopen('mymodel/start.bat','w');
            fprintf(fileID,['ampl "../script/script_' this.instance.name '.txt"']);
            fclose(fileID);
            
            % Run optimization
            cd mymodel
            system('start.bat');
            cd ..
            
            % Parse results
            E = this.parseValidationResults(solutionGroup,modelName,budgets);
        end                 
        function writeScript(this,modelName,budgets,mode)
            % Write script
            instanceName = this.instance.name;
            pathScript = ['script/script_' instanceName '.txt'];
            pathModel = ['model ' modelName '.mod'];
            pathInstance = ['data ../data/' instanceName '.dat'];
            pathOutput = '../output/';
            
            fileID = fopen(pathScript,'w');
            fprintf(fileID,'option solver gurobi.exe;\n option reset_initial_guesses 1; option display_precision 0; \n');
            fprintf(fileID,['option gurobi_options ''mipgap 0 bestbound 1 outlev 1 timelim ' num2str(this.timeLim_exactApproach) ''';\n']);
            fprintf(fileID,'option display_1col 100000;\n'); 
            fprintf(fileID,'reset;\n');
            fprintf(fileID,[pathModel ';\n']);
            fprintf(fileID,[pathInstance ';\n']);
            for i=1:length(budgets)
                fprintf(fileID,'let B:= %d;\n',budgets(i));
                if strcmp(mode,'greedyMode') && i>1
                    fprintf(fileID,'fix{i in I:x[i]=1} x[i]:=1;\n');    
                end
                fprintf(fileID,'solve;\n');
                fprintf(fileID,['option show_stats 1 > "' pathOutput 'STATS_' instanceName '_' modelName '_' mode '_' num2str(budgets(i)) '.out";\n']);
                fprintf(fileID,['display COVERAGE > "' pathOutput 'OFV_' instanceName '_' modelName '_' mode '_' '_' num2str(budgets(i)) '.out";\n']);
                fprintf(fileID,['display _solve_elapsed_time > "' pathOutput 'TIME_' instanceName '_' modelName '_' mode '_' '_' num2str(budgets(i)) '.out";\n']);
                fprintf(fileID,['display x > "' pathOutput 'X_' instanceName '_' modelName '_' mode '_' '_' num2str(budgets(i)) '.out";\n']);
                if strcmp(modelName,'myModel')
                    fprintf(fileID,['display y > "' pathOutput 'Y_' instanceName '_' modelName '_' mode '_' '_' num2str(budgets(i)) '.out";\n']);                    
                else
                    fprintf(fileID,['display{e in E} sum{i in I}a[i,e]*x[i] > "' pathOutput 'U_' instanceName '_' modelName '_' mode '_' '_' num2str(budgets(i)) '.out";\n']);
                end
                fprintf(fileID,['display solve_result_num > "' pathOutput 'RESULTNUM_' instanceName '_' modelName '_' mode '_' '_' num2str(budgets(i)) '.out";\n']);
                fprintf(fileID,['display COVERAGE.bestbound > "' pathOutput 'BESTBOUND_' instanceName '_' modelName '_' mode '_' '_' num2str(budgets(i)) '.out";\n']);
                fprintf(fileID,'close;\n');
            end
            fclose(fileID);
        end 
        function writeValidationScript(this,solutionGroup,modelName,budgets)
            
            nameOfHeuristic = this.solutionGroups{solutionGroup}{1}.solApproachName;
            instanceName = this.instance.name;
            % Write script
            pathScript = ['script/script_' instanceName '.txt'];
            pathModel = ['model ' modelName '.mod'];
            pathInstance = ['data ../data/' instanceName '.dat'];
            pathOutput = '../output/validation/';
            
            fileID = fopen(pathScript,'w');
            fprintf(fileID,'option solver gurobi.exe;\n option reset_initial_guesses 1; option display_precision 0; \n');
            fprintf(fileID,'option gurobi_options ''mipgap 0 outlev 1'';\n');
            fprintf(fileID,'option display_1col 100000;\n'); 
            fprintf(fileID,'reset;\n');
            fprintf(fileID,[pathModel ';\n']);
            fprintf(fileID,[pathInstance ';\n']);
            for i=1:length(budgets)
                fprintf(fileID,'let B:= %d;\n',budgets(i));
                for j=1:length(this.solutionGroups{solutionGroup}{i}.var_x)
                    fprintf(fileID,['fix x[' num2str(j) '] := %d;\n'],this.solutionGroups{solutionGroup}{i}.var_x(j));
                end
                fprintf(fileID,'solve;\n');
                fprintf(fileID,['option show_stats 1 > "' pathOutput 'STATS_' instanceName '_' modelName '_' nameOfHeuristic '_' num2str(budgets(i)) '.out";\n']);
                fprintf(fileID,['display COVERAGE > "' pathOutput 'OFV_' instanceName '_' modelName '_' nameOfHeuristic '_' num2str(budgets(i)) '.out";\n']);
                fprintf(fileID,['display _solve_elapsed_time > "' pathOutput 'TIME_' instanceName '_' modelName '_' nameOfHeuristic '_' num2str(budgets(i)) '.out";\n']);
                fprintf(fileID,['display x > "' pathOutput 'X_' instanceName '_' modelName '_' nameOfHeuristic '_' num2str(budgets(i)) '.out";\n']);
                if strcmp(modelName,'myModel')
                    fprintf(fileID,['display y > "' pathOutput 'Y_' instanceName '_' modelName '_' nameOfHeuristic '_' num2str(budgets(i)) '.out";\n']);                    
                else
                    fprintf(fileID,['display{e in E} sum{i in I}a[i,e]*x[i] > "' pathOutput 'U_' instanceName '_' modelName '_' nameOfHeuristic '_' num2str(budgets(i)) '.out";\n']);
                end
                fprintf(fileID,['display solve_result_num > "' pathOutput 'RESULTNUM_' instanceName '_' modelName '_' nameOfHeuristic '_' num2str(budgets(i)) '.out";\n']);
                fprintf(fileID,'close;\n');
            end
            fclose(fileID);
        end        
        function E = parseResults(this,modelName,budgets,mode)
            % Write script
            instanceName = this.instance.name;
            pathOutput = 'output/';
            groupCounter = length(this.solutionGroups)+1;
            this.solutionGroups{groupCounter} = cell(length(budgets),1);
            
            for i=1:length(budgets)
                % Read OFV
                solution = MySolution(i,instanceName,1,[modelName '-' mode], budgets(i),this.timeLim_exactApproach);
                fileName = [pathOutput 'OFV_' instanceName '_' modelName '_' mode '_' '_' num2str(budgets(i)) '.out'];
                fileID = fopen(fileName,'r');
                solution.coverage = fscanf(fileID,'COVERAGE = %f');
                fclose(fileID);

                % Read run time
                fileName = [pathOutput 'TIME_' instanceName '_' modelName '_' mode '_' '_' num2str(budgets(i))  '.out'];
                fileID = fopen(fileName,'r');
                solution.runTime = fscanf(fileID,'_solve_elapsed_time = %f');
                fclose(fileID);

                % Get values for variable X
                fileName = [pathOutput 'X_' instanceName '_' modelName '_' mode '_' '_' num2str(budgets(i))  '.out'];
                fileID = fopen(fileName,'r');
                fscanf(fileID,'x [*] :=\n');    
                tmp = fscanf(fileID,'%d %d\n',[2 Inf]);    
                tmp = tmp';
                fclose(fileID);
                solution.var_x = tmp(:,2); 

                if strcmp(modelName,'myModel')
                    % Get values for variable Y
                    fileName = [pathOutput 'Y_' instanceName '_' modelName '_' mode '_' '_' num2str(budgets(i))  '.out'];
                    fileID = fopen(fileName,'r');
                    fscanf(fileID,'y [*] :=\n');    
                    tmp = fscanf(fileID,'%d %d\n',[2, Inf]);    
                    tmp = tmp';
                    fclose(fileID);
                    solution.var_y = tmp(:,2);
                else
                    % Get values for variable U (numPasses)
                    fileName = [pathOutput 'U_' instanceName '_' modelName '_' mode '_' '_' num2str(budgets(i))  '.out'];
                    fileID = fopen(fileName,'r');
                    fscanf(fileID,'sum{i in I} a[i,e]*x[i] [*] :=\n');    
                    tmp = fscanf(fileID,'%d %d\n',[2, Inf]);    
                    tmp = tmp';
                    fclose(fileID);
                    solution.var_y = tmp(:,2);
                end

                % Read result num
                fileName = [pathOutput 'RESULTNUM_' instanceName '_' modelName '_' mode '_' '_' num2str(budgets(i))  '.out'];
                fileID = fopen(fileName,'r');
                solution.resultNum = fscanf(fileID,'solve_result_num = %d');
                
                % Read best bound
                fileName = [pathOutput 'BESTBOUND_' instanceName '_' modelName '_' mode '_' '_' num2str(budgets(i))  '.out'];
                fileID = fopen(fileName,'r');
                this.instance.bestBound(i) = fscanf(fileID,'COVERAGE.bestbound = %f');
                solution.bestBound = this.instance.bestBound(i);
                fclose(fileID);  
                this.solutionGroups{groupCounter}{i} = solution;
            end
            E = this;            
        end 
        function E = parseValidationResults(this,solutionGroup,modelName,budgets)
            
            nameOfHeuristic = this.solutionGroups{solutionGroup}{1}.solApproachName;
            instanceName = this.instance.name;
            % Write script
            pathOutput = 'output/validation/';
            groupCounter = length(this.solutionGroups)+1;
            this.solutionGroups{groupCounter} = cell(length(budgets),1);
            
            for i=1:length(budgets)
                % Read OFV
                solution = MySolution(i,instanceName,1,[modelName '_forValidating_',nameOfHeuristic],budgets(i),this.timeLim_exactApproach);
                fileName = [pathOutput 'OFV_' instanceName '_' modelName '_' nameOfHeuristic '_' num2str(budgets(i)) '.out'];
                fileID = fopen(fileName,'r');
                solution.coverage = fscanf(fileID,'COVERAGE = %f');
                fclose(fileID);

                % Read run time
                fileName = [pathOutput 'TIME_' instanceName '_' modelName '_' nameOfHeuristic '_' num2str(budgets(i))  '.out'];
                fileID = fopen(fileName,'r');
                solution.runTime = fscanf(fileID,'_solve_elapsed_time = %f');
                fclose(fileID);

                % Get values for variable X
                fileName = [pathOutput 'X_' instanceName '_' modelName '_' nameOfHeuristic '_' num2str(budgets(i))  '.out'];
                fileID = fopen(fileName,'r');
                fscanf(fileID,'x [*] :=\n');    
                tmp = fscanf(fileID,'%d %d\n',[2 Inf]);    
                tmp = tmp';
                fclose(fileID);
                solution.var_x = tmp(:,2); 

                if strcmp(modelName,'myModel')
                    % Get values for variable Y
                    fileName = [pathOutput 'Y_' instanceName '_' modelName '_' nameOfHeuristic '_' num2str(budgets(i))  '.out'];
                    fileID = fopen(fileName,'r');
                    fscanf(fileID,'y [*] :=\n');    
                    tmp = fscanf(fileID,'%d %d\n',[2, Inf]);    
                    tmp = tmp';
                    fclose(fileID);
                    solution.var_y = tmp(:,2);
                else
                    % Get values for variable U (numPasses)
                    fileName = [pathOutput 'U_' instanceName '_' modelName '_' nameOfHeuristic '_' num2str(budgets(i))  '.out'];
                    fileID = fopen(fileName,'r');
                    fscanf(fileID,'sum{i in I} a[i,e]*x[i] [*] :=\n');    
                    tmp = fscanf(fileID,'%d %d\n',[2, Inf]);    
                    tmp = tmp';
                    fclose(fileID);
                    solution.var_y = tmp(:,2);
                end

                % Read result num
                fileName = [pathOutput 'RESULTNUM_' instanceName '_' modelName '_' nameOfHeuristic '_' num2str(budgets(i))  '.out'];
                fileID = fopen(fileName,'r');
                solution.resultNum = fscanf(fileID,'solve_result_num = %d');
                fclose(fileID);  
                this.solutionGroups{groupCounter}{i} = solution;
            end
            E = this;
        end         
        function plotBudgetVsUtility(this)
            figure;
            set(gcf,'color','w');
            
            % Prepare data 
            markSymbols = ['o';'x';'d'];
            markColors = ['r';'b';'g'];
            legendEntries = cell(length(this.solutionGroups),1);
            for i=1:length(this.solutionGroups)
                data_x = zeros(length(this.solutionGroups{i}),1);
                data_y = zeros(length(this.solutionGroups{i}),1);
                for j=1:length(this.solutionGroups{i})
                    data_x(j) = this.solutionGroups{i}{j}.budget;
                    data_y(j) = this.solutionGroups{i}{j}.coverage;
                end
                % Plot data
                scatter(data_x,data_y,markSymbols(i),markColors(i),'LineWidth',1.5); 
                hold on;
                % Add to legend string
                legendEntries{i} = this.solutionGroups{i}{1}.solApproachName;
            end
            
            xlabel('Budget');
            ylabel('Total utility');
            
            % Legend
            legend(legendEntries,'Location','EastOutside','Orientation','vertical');
%             legend('boxoff');
            legendmarkeradjust(1.5);
            title(['Budget vs. Utility - Instance: ' this.instance.name]);
            print(['budgetVsUtility_' this.instance.name '.png'],'-dpng');
            close(gcf);
        end
        function plotBudgetVsRunTime(this)
            
            figure;
            set(gcf,'color','w');
            
            % Prepare data 
            markSymbols = ['o';'x';'d'];
            markColors = ['r';'b';'g'];
            legendEntries = cell(length(this.solutionGroups),1);
            for i=1:length(this.solutionGroups)
                data_x = zeros(length(this.solutionGroups{i}),1);
                data_y = zeros(length(this.solutionGroups{i}),1);
                for j=1:length(this.solutionGroups{i})
                    data_x(j) = this.solutionGroups{i}{j}.budget;
                    data_y(j) = this.solutionGroups{i}{j}.runTime;
                end
                % Plot data
                scatter(data_x,data_y,markSymbols(i),markColors(i),'LineWidth',1.5); 
                hold on;
                % Add to legend string
                legendEntries{i} = this.solutionGroups{i}{1}.solApproachName;
            end
            
            xlabel('Budget');
            ylabel('Run time [s]');
            
            % Legend
            legend(legendEntries,'Location','EastOutside','Orientation','vertical');
%             legend('boxoff');
            legendmarkeradjust(1.5);
            title(['Budget vs. RunTime - Instance: ' this.instance.name]);
            print(['budgetVsRunTime_' this.instance.name '.png'],'-dpng');
            close(gcf);            
        end  
        function writeResultFile(this)
            % Write script
            fileName = 'results/results.txt';
            if exist(fileName,'file')
                fileID = fopen(fileName,'a');
            else
                fileID = fopen(fileName,'w');
                fprintf(fileID,'Instance,re,a,c,Solution approach,Budget,isOptimal,OFV,BestBound,Gap,RunTime,TotalNumberOfPasses\n');
            end
            
            % Write exact results
            for i=1:length(this.solutionGroups)
                sols = this.solutionGroups{i};
                for j=1:length(sols)
                   isOptimal = sols{j}.resultNum==0;
                   fprintf(fileID,'%s,%d,%f,%d,%s,%d,%d,%f,%f,%f,%f,%d\n',...
                       sols{j}.instanceName, ...
                       this.instance.re, ...
                       this.instance.a, ...
                       this.instance.c, ...
                       sols{j}.solApproachName, ...
                       sols{j}.budget, ...                       
                       isOptimal, ...
                       sols{j}.coverage, ...
                       sols{j}.bestBound, ...
                       (sols{j}.bestBound-sols{j}.coverage)/sols{j}.coverage, ...
                       sols{j}.runTime, ...
                       sum(sols{j}.var_y));
                end                
            end

            fclose(fileID);
        end   
    end
    
end

