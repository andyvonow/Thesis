%%
close all
writematrix("Regression Analysis: R^2",'RegressionData.csv')

% thisLegend = struct;
% thisLegend(1).leg = legend('','','');
% thisLegend(2).leg = legend('','','');

for MasterVar = 1:MasterNumVar
    ThisSet = extractfield(MasterVars,string(MasterFields(MasterVar)));
    
    %KINDS OF MODELS
    LinearRegressionData{NumVar,NumVar} = {};
    LogRegressionData{NumVar,NumVar} = {};
    %Perform regression between all variables
    for m=1:NumVar %rows
        LinearRegressionData{m,1} = string(VariableNames(m));
        for n=1:NumVar %columns
            %Don't perform regression on similar variables (i.e. MaxForce and IntForce)
            %Don't perform regression on X as well as MassX for same Person, since reg is same.
            if (n < m) && ...
                    ~(contains(VariableNames(m),"Force") == contains(VariableNames(n),"Force")) && ...
                    ~(contains(VariableNames(m),"Accel") == contains(VariableNames(n),"Accel")) && ...
                    ~(contains(VariableNames(n),"MASS") && ~contains(VariableNames(m),"Accel") && ...
                    contains(MasterFields(MasterVar),"P"))
                
                independent = extractfield(ThisSet{1,1},string(VariableNames(m)));
                dependent = extractfield(ThisSet{1,1},string(VariableNames(n)));
                
                LinearRegression = fitlm(independent,dependent);
                LinearRegressionData{m,n+1} = LinearRegression.Rsquared.Ordinary;
                
                %---------------------------------------------------------------------------%
                %---------------------------------------------------------------------------%
                %---------------------------------------------------------------------------%
                 if contains(string(MasterFields(MasterVar)), "P") && ...
                         contains(string(MasterFields(MasterVar)), "Shank") && ...
                        contains(VariableNames(m),"Force_FMMAX") && contains(VariableNames(n),"AMMAX") && ...
                        ~contains(VariableNames(n),"MASS")
                        plotting = true;
                 else
                     plotting = false;
                 end
                 
                 
                 %Plot the relationship?
                if PlotRegressions || plotting
                    
                    figure(1)
                    hold on
                    
                    %remove the "_" from the VariableName
                    xLab = char(string(VariableNames(m)));
                    yLab = char(string(VariableNames(n)));
%                     xLab = xLab(1:5)+": "+xLab(7:length(xLab));
%                     yLab = yLab(1:5)+": "+yLab(7:length(yLab));
                    xLab = xLab(1:5)+" "+xLab(8:length(xLab))+" (N.s)";
                    yLab = yLab(1:3)+" "+yLab(8:length(yLab))+" (ms^-^2.s.kg)";;
                    
                    %Linear Regression line
                    x = linspace(min(independent),max(independent));
                    y = LinearRegression.Coefficients.Estimate(1) + LinearRegression.Coefficients.Estimate(2) * x;
                    
                    %Always plot Acceleration on x-axis
                    if contains(VariableNames(m),"Accel")
                        plot(independent,dependent,'bo')
                        plot(x,y,'r--')
                        xlabel(xLab); ylabel(yLab);
                    else
                        plot(dependent,independent,'bo')
                        plot(y,x,'r--')
                        xlabel(yLab); ylabel(xLab);
                    end
                    
                    legend(string(MasterFields(MasterVar)),"R^2 = " + round(LinearRegression.Rsquared.Ordinary,2),'Location','northwest')
                    
                    title("Integration:"+newline+"Vertical Force vs. Axial Acceleration")
                    
                    hold off
                end
                
                %---------------------------------------------------------------------------%
                %---------------------------------------------------------------------------%
                %---------------------------------------------------------------------------%
                
            else
                LinearRegressionData{m,n+1} = '-';
            end
        end
    end
    
    VarWithoutUnderscores{NumVar,1} = {};
    
    for name=1:NumVar
        if contains(VariableNames{name,1},"Accel_")
            VarWithoutUnderscores{name,1} = replace(VariableNames{name,1},"Accel_","");
        elseif contains(VariableNames{name,1},"Force_")
            VarWithoutUnderscores{name,1} = replace(VariableNames{name,1},"Force_","F_");
        end
    end
    
    %Save Regression Data
    writematrix("",'RegressionData.csv','WriteMode','append')
    writecell({...
        string(replace(cell(MasterFields(MasterVar)),"_AllTrialStats","")),...
        VarWithoutUnderscores{1:21,1}},...
        'RegressionData.csv','WriteMode','append')
    
    %Write Force lines only. (m == row)
    for m=1:NumVar
        if ~contains(string(LinearRegressionData(m,1)),"Accel")
            LinearRegressionData(m,1) = {[replace(string(LinearRegressionData(m,1)),"Force_","")]}; %Don't write "Force_"
            cell2write = LinearRegressionData(m,1:22); %only write acceleration columns
            writecell(cell2write,'RegressionData.csv','WriteMode','append')
            %writecell(LinearRegressionData(m,:),'RegressionData.csv','WriteMode','append')
        end
    end
end

run('ImportRegData1Set.m')
