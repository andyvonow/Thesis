%Linear Regression
%P 1,2,3,4 in Global Fit

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
                
                %                 LogRegression = fitlm(log(independent),dependent);
                %                 LogRegressionData{m,n+1} = LogRegression.Rsquared.Ordinary;
                
                plotting = false;
                
                
                
                %---------------------------------------------------------------------------%
                %---------------------------------------------------------------------------%
                %---------------------------------------------------------------------------%
                %Plot the relationship?
                
                mVariable = "Force_FMMAX";
                nVariable = "MMAX";
                
                if contains(string(MasterFields(MasterVar)), "P") && ...
                        contains(VariableNames(m),mVariable) && ...
                        contains(VariableNames(n),nVariable) && ...
                        ~contains(VariableNames(n),"MASS")
                    
                    if contains(string(MasterFields(MasterVar)),"Shank")
                        figureNumber = 1;
                        plotting = true;
%                     
%                     elseif contains(string(MasterFields(MasterVar)),"Ankle")
%                         figureNumber = 3;
%                         plotting = false;
                    end
                end
                
%                 mVariable = "Force_FZINTEG";
%                 nVariable = "XINTEG";
%                 
%                 if contains(string(MasterFields(MasterVar)), "P") && ...
%                         contains(VariableNames(m),mVariable) && ...
%                         contains(VariableNames(n),nVariable) && ...
%                         contains(VariableNames(n),"MASS")
%                     if contains(string(MasterFields(MasterVar)),"Shank")
%                         figureNumber = 2;
%                         plotting = true;
%                     end
%                 end
                
                if PlotRegressions || plotting
                    
                    figure(figureNumber)
                    hold on
                    
                    SectionName = MasterFields(MasterVar);
                    switch SectionName{1}(2)
                        case '1'
                            dotsColour = 'b';
                            legendNumber = 1;
                        case '2'
                            dotsColour = 'r';
                            legendNumber = 2;
                        case '3'
                            dotsColour = 'k';
                            legendNumber = 3;
                        case '4'
                            dotsColour = 'm';
                            legendNumber = 4;
                    end
                    %remove the "_" from the VariableName
                    xLab = char(string(VariableNames(m)));
                    yLab = char(string(VariableNames(n)));
                    xLab = xLab(1:5)+": "+xLab(8:length(xLab))+" (N)";
                    yLab = yLab(1:5)+": "+yLab(8:length(yLab))+" (g)";
                    
                    %Linear Regression line
                    x = linspace(min(independent),max(independent));
                    y = LinearRegression.Coefficients.Estimate(1) + ...
                        LinearRegression.Coefficients.Estimate(2) * x;
                    
                    %Always plot Acceleration on x-axis
                    if contains(VariableNames(m),"Accel")
                        plot(independent,dependent,[dotsColour,'.'])
                        plot(x,y,[dotsColour,'--'])
                        xlabel(xLab); ylabel(yLab);
                    else
                        plot(dependent,independent,[dotsColour,'.'])
                        plot(y,x,[dotsColour,'--'])
                        xlabel(yLab); ylabel(xLab);
                    end
                    
                    switch figureNumber
                        case 1
                            switch legendNumber
                                case 1
                                    leg1 = legend([replace(string(MasterFields(MasterVar)),SectionName{1}(3:7),""),['R^2 = ',num2str(round(LinearRegression.Rsquared.Ordinary,2))]]);
                                case 2
                                    leg1 = legend([leg1.String(1),leg1.String(2),replace(string(MasterFields(MasterVar)),SectionName{1}(3:7),""),['R^2 = ',num2str(round(LinearRegression.Rsquared.Ordinary,2))]]);
                                case 3
                                    leg1 = legend([leg1.String(1),leg1.String(2),leg1.String(3),leg1.String(4),replace(string(MasterFields(MasterVar)),SectionName{1}(3:7),""),['R^2 = ',num2str(round(LinearRegression.Rsquared.Ordinary,2))]]);
                                case 4
                                    leg1 = legend([leg1.String(1),leg1.String(2),leg1.String(3),leg1.String(4),leg1.String(5),leg1.String(6),replace(string(MasterFields(MasterVar)),SectionName{1}(3:7),""),['R^2 = ',num2str(round(LinearRegression.Rsquared.Ordinary,2))]],'Location','northwest');
                            end
                        case 2
                            switch legendNumber
                                case 1
                                    leg2 = legend([replace(string(MasterFields(MasterVar)),SectionName{1}(3:7),""),['R^2 = ',num2str(round(LinearRegression.Rsquared.Ordinary,2))]]);
                                case 2
                                    leg2 = legend([leg2.String(1),leg2.String(2),replace(string(MasterFields(MasterVar)),SectionName{1}(3:7),""),['R^2 = ',num2str(round(LinearRegression.Rsquared.Ordinary,2))]]);
                                case 3
                                    leg2 = legend([leg2.String(1),leg2.String(2),leg2.String(3),leg2.String(4),replace(string(MasterFields(MasterVar)),SectionName{1}(3:7),""),['R^2 = ',num2str(round(LinearRegression.Rsquared.Ordinary,2))]]);
                                case 4
                                    leg2 = legend([leg2.String(1),leg2.String(2),leg2.String(3),leg2.String(4),leg2.String(5),leg2.String(6),replace(string(MasterFields(MasterVar)),SectionName{1}(3:7),""),['R^2 = ',num2str(round(LinearRegression.Rsquared.Ordinary,2))]]);
                            end
%                         case 3
%                             switch legendNumber
%                                 case 1
%                                     leg3 = legend([replace(string(MasterFields(MasterVar)),SectionName{1}(3:7),""),['R^2 = ',num2str(LinearRegression.Rsquared.Ordinary)]]);
%                                 case 2
%                                     leg3 = legend([leg3.String(1),leg3.String(2),replace(string(MasterFields(MasterVar)),SectionName{1}(3:7),""),['R^2 = ',num2str(LinearRegression.Rsquared.Ordinary)]]);
%                                 case 3
%                                     leg3 = legend([leg3.String(1),leg3.String(2),leg3.String(3),leg3.String(4),replace(string(MasterFields(MasterVar)),SectionName{1}(3:7),""),['R^2 = ',num2str(LinearRegression.Rsquared.Ordinary)]]);
%                                 case 4
%                                     leg3 = legend([leg3.String(1),leg3.String(2),leg3.String(3),leg3.String(4),leg3.String(5),leg3.String(6),replace(string(MasterFields(MasterVar)),SectionName{1}(3:7),""),['R^2 = ',num2str(LinearRegression.Rsquared.Ordinary)]]);
%                             end
                    end
                    
                    sgtitle(SectionName{1}(3:7))
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
        VarWithoutUnderscores{1:19,1}},...
        'RegressionData.csv','WriteMode','append')
    
    %Write Force lines only. (m == row)
    for m=1:NumVar
        if ~contains(string(LinearRegressionData(m,1)),"Accel")
            LinearRegressionData(m,1) = {[replace(string(LinearRegressionData(m,1)),"Force_","")]}; %Don't write "Force_"
            cell2write = LinearRegressionData(m,1:20); %only write acceleration columns
            writecell(cell2write,'RegressionData.csv','WriteMode','append')
            %writecell(LinearRegressionData(m,:),'RegressionData.csv','WriteMode','append')
        end
    end
end

%%
%Add global correlations to the graphs
one = fitlm([MasterVars.Shank.Accel_AMMAX],[MasterVars.Shank.Force_FMMAX]);
% two = fitlm([MasterVars.Shank.Accel_AMMAX],[MasterVars.Shank.Force_FZINTEG]);
% thr = fitlm([MasterVars.Ankle.Accel_AMMAX],[MasterVars.Ankle.Force_FMMAX]);

timeone = linspace(min([MasterVars.Shank.Accel_AMMAX]),max([MasterVars.Shank.Accel_AMMAX]));
% timetwo = linspace(min([MasterVars.Shank.Accel_AMMAX]),max([MasterVars.Shank.Accel_AMMAX]));
% timethr = linspace(min([MasterVars.Ankle.Accel_AMMAX]),max([MasterVars.Ankle.Accel_AMMAX]));

figure(1)
hold on
plot(timeone,one.Coefficients.Estimate(1) + one.Coefficients.Estimate(2) .* timeone,'g-');
legend([...
    leg1.String(1),leg1.String(2),leg1.String(3),leg1.String(4),...
    leg1.String(5),leg1.String(6),leg1.String(7),leg1.String(8),...
    ["Cohort Fit"+newline+"R^2 = "+num2str(round(one.Rsquared.Ordinary,2))]],...
    'Location','northwest');

% figure(2)
% hold on
% plot(timetwo,two.Coefficients.Estimate(1) + two.Coefficients.Estimate(2) .* timetwo,'g-');
% legend([...
%     leg2.String(1),leg2.String(2),leg2.String(3),leg2.String(4),...
%     leg2.String(5),leg2.String(6),leg2.String(7),leg2.String(8),...
%     ["Global Fit"+newline+"R^2 = "+num2str(two.Rsquared.Ordinary)]]);

% figure(3)
% hold on
% plot(timethr,thr.Coefficients.Estimate(1) + thr.Coefficients.Estimate(2) .* timethr,'g-');
% legend([...
%     leg3.String(1),leg3.String(2),leg3.String(3),leg3.String(4),...
%     leg3.String(5),leg3.String(6),leg3.String(7),leg3.String(8),...
%     ["Global Fit"+newline+"R^2 = "+num2str(thr.Rsquared.Ordinary)]]);


