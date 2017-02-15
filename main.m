% Clear workspace
clear

% Add relevant folders to path
addpath(genpath('instances'));
addpath(genpath('subroutines'));
addpath(genpath('model'));
addpath(genpath('data'));

% % Create and solve illustrative example 
% createIllustrativeExample();
% load('data/IEInstance.mat');
% 
% % Initialize experiment
% budgets = 1:4;
% timeLim = 600;
% E = MyExperiment(1,IEInstance,timeLim);
% 
% % Apply heuristic
% E = E.solveHeuristically('revisedHeuristic3',budgets);  
% 
% % Apply exact model
% IEInstance.revisedWriteDat();    
% % E = E.solveExactly('myRevisedModel',budgets,'optimalityMode');    
% E = E.solveExactly('myRevisedModel',budgets,'greedyMode');    
% 
% % Generate plots
% E.plotBudgetVsUtility();
% E.plotBudgetVsRunTime();

% % Plot solutions
% for i=1:length(budgets)
%     E.solutionGroups{1}{i}.plotSol();
%     E.solutionGroups{2}{i}.plotSol();
% end

% Write results to TXT-file
% E.writeResultFile();
% 
% % Save results
% save('output/ResultsIEExperiment.mat','E');
% 
% % Clear workspace
% clear
% 
% % Initialize experiment
% budgets = [2 4 6];
% timeLim = 600;
% max_re = [5,15];
% alpha = [0.5 0.9];
% c_bar = 1;
% 
% for re=max_re
%     for a=alpha
%         for c=c_bar
% 
%         % Read USPS problem instance
%         createInstances('USPSInstance',re,a,c);
%         load(['data/USPSInstance_' num2str(re) '_' num2str(a) '_' num2str(c) '.mat']);
% 
%         E = MyExperiment(1,inst,timeLim);
% 
%         % Apply heuristic
%         E = E.solveHeuristically('revisedHeuristic3',budgets); 
% 
%         % Apply exact model
%         inst.revisedWriteDat();    
%         E = E.solveExactly('myRevisedModel',budgets,'optimalityMode');  
% 
%         % Generate plots
%         E.plotBudgetVsUtility();
%         E.plotBudgetVsRunTime();
% 
%         % Plot solutions
%         for i=1:length(budgets)
%             E.solutionGroups{1}{i}.plotSol();
%             E.solutionGroups{2}{i}.plotSol();
%         end
% 
%         % Write results to TXT-file
%         E.writeResultFile();
% 
%         % Save experiment
%         save('output/ResultsUSPSExperiment.mat','E');
% 
%         end
%     end
% end

% % Clear workspace
clear

% Initialize experiment
budgets = [10,50];
timeLim = 600;
max_re = [5,15];
alpha = [0.5,0.9];
c_bar = [1,3];

for re=max_re
    for a=alpha
        for c=c_bar

            % Read Metro problem instance
            createInstances('MetroInstance',re,a,c);
            load(['data/MetroInstance_' num2str(re) '_' num2str(a) '_' num2str(c) '.mat']);

            E = MyExperiment(1,inst,timeLim);
            
            % Apply exact model
            inst.revisedWriteDat();    
            E = E.solveExactly('myRevisedModel',budgets,'optimalityMode');  
%             E = E.solveExactly('myRevisedModel',budgets,'greedyMode');  

            % Apply heuristic
%             E = E.solveHeuristically('revisedHeuristic3',budgets); 

            % Generage plots
%             E.plotBudgetVsUtility();
%             E.plotBudgetVsRunTime();

%             % Plot solutions
%             for i=1:length(budgets)
%                 E.solutionGroups{1}{1}.plotSol();
%                 E.solutionGroups{2}{i}.plotSol();
%             end

            % Write results to TXT-file
            E.writeResultFile();

            % Save results
            save('output/ResultsMetroExperiment.mat','E');            
            
        end
    end
end


%---------------------------
% Debugging tools
%---------------------------
%E = E.solveExactly('myRevisedModel','Revised_MetroInstance',budgets,'greedyMode');  
% solutionGroup = 1;
% E = E.validateSolutions(solutionGroup,'myRevisedModel','Revised_MetroInstance',budgets);  
% solutionGroup = 3;
% E = E.validateSolutions(solutionGroup,'myRevisedModel','Revised_MetroInstance',budgets);  

% for i=1:length(budgets)
%    x1 = E.solutionGroups{1}{i}.var_x;
%    x2 = E.solutionGroups{2}{i}.var_x;
%    diff(i) = sum(x1~=x2);
% end





