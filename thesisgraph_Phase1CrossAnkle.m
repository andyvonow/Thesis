%Linear Regression
%P 1,2,4 in Global Fit; Validate on P3.
for variable = 1:2
    if variable == 1
        ForceVar = "Force_FZINTEG";
        AccelVar = "Accel_AXINTEGMASS";
    elseif variable == 2
        ForceVar = "Force_FMINTEG";
        AccelVar = "Accel_AMINTEGMASS";
    end
    
    
    
    close all
    
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
                        (contains(VariableNames(n),"MASS") && ~contains(VariableNames(m),"Accel") && ...
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
                    
                    
                    %                 VariableNames(n)
                    CVPersonsStr = num2str(reshape(CVPersons',1,[]));
                    
                    SectionName = MasterFields(MasterVar);
                    SectionName{1}(2);
                    
                    %Plot the relationship?
                    if contains(string(MasterFields(MasterVar)), "P") && ...
                            contains(VariableNames(m),ForceVar) && contains(VariableNames(n),AccelVar)
                        if contains(string(MasterFields(MasterVar)),"Ankle")
                            figureNumber = 3;
                            plotting = true;
                            
                            %if this person is the NCV, don't plot, but do save the
                            %correlation coefficient.
                            if contains(SectionName{1}(2),num2str(NCV))
                                plotting = false;
                                thisNCV = LinearRegression;
                            end
                        end
                    end
                    
                    
                    
                   
                 
                         
                    if plotting
                        
%                         figure(figureNumber)
%                         hold on
                        
                        switch strfind(CVPersonsStr,SectionName{1}(2))
                            case 1
                                dotsColour = 'b';
                                legendNumber = 1;
                            case 4
                                dotsColour = 'r';
                                legendNumber = 2;
                            case 7
                                dotsColour = 'k';
                                legendNumber = 3;
                        end
                        
                        %remove the "_" from the VariableName
                        xLab = char(string(VariableNames(m)));
                        yLab = char(string(VariableNames(n)));
                        
                        xLab = xLab(1:5)+" "+xLab(8:length(xLab))+" (N.s)";
                        yLab = yLab(1:3)+" "+yLab(8:length(yLab))+" (ms^-^2.s.kg)";;
                        
                        %Linear Regression line
                        x = linspace(min(independent),max(independent));
                        y = LinearRegression.Coefficients.Estimate(1) + LinearRegression.Coefficients.Estimate(2) * x;
                        
%                         %Always plot Acceleration on x-axis
%                         if contains(VariableNames(m),"Accel")
%                             plot(independent,dependent,[dotsColour,'.'])
%                             plot(x,y,[dotsColour,'--'])
%                             xlabel(xLab); ylabel(yLab);
%                         else
%                             plot(dependent,independent,[dotsColour,'.'])
%                             plot(y,x,[dotsColour,'--'])
%                             xlabel(yLab); ylabel(xLab);
%                         end
%                         
%                         switch figureNumber
% 
%                             case 3
%                                 switch legendNumber
%                                     case 1
%                                         leg3 = legend([replace(string(MasterFields(MasterVar)),SectionName{1}(3:7),""),['R^2 = ',num2str(round(LinearRegression.Rsquared.Ordinary,2))]]);
%                                     case 2
%                                         leg3 = legend([leg3.String(1),leg3.String(2),replace(string(MasterFields(MasterVar)),SectionName{1}(3:7),""),['R^2 = ',num2str(round(LinearRegression.Rsquared.Ordinary,2))]]);
%                                     case 3
%                                         leg3 = legend([leg3.String(1),leg3.String(2),leg3.String(3),leg3.String(4),replace(string(MasterFields(MasterVar)),SectionName{1}(3:7),""),['R^2 = ',num2str(round(LinearRegression.Rsquared.Ordinary,2))]]);
%                                 end
%                         end
%                         
%                         title("Leave-One-Out: "+SectionName{1}(3:7))
%                         hold off
                    end
                    
                    %---------------------------------------------------------------------------%
                    %---------------------------------------------------------------------------%
                    %---------------------------------------------------------------------------%
                    
                else
                    LinearRegressionData{m,n+1} = '-';
                end
            end
        end
    end
    
    %%
    
    %Add global correlations to the graphs
    thr = fitlm([MasterVars.AnkleN3.(AccelVar)],[MasterVars.AnkleN3.(ForceVar)]);
    
    timethr = linspace(min([MasterVars.AnkleN3.(AccelVar)]),max([MasterVars.AnkleN3.(AccelVar)]));
    
%     figure(3)
%     hold on
%     plot(timethr,thr.Coefficients.Estimate(1) + thr.Coefficients.Estimate(2) .* timethr,'g-');
%     legend([...
%         leg3.String(1),leg3.String(2),leg3.String(3),leg3.String(4),...
%         leg3.String(5),leg3.String(6),...
%         ["Global Fit"+newline+"R^2 = "+num2str(round(thr.Rsquared.Ordinary,2))]],'Location','northwest');
    
    % "F = " + num2str(thr.Coefficients.Estimate(1)) + " + " + num2str(thr.Coefficients.Estimate(2)) + " * A"
    
    
    %Validate Global Equation Fit
    OrigAccel = [MasterVars.("P"+num2str(NCV)+"Ankle").(AccelVar)];
    OrigForce = [MasterVars.("P"+num2str(NCV)+"Ankle").(ForceVar)];
    
    P3Predicted = thr.Coefficients.Estimate(1) + thr.Coefficients.Estimate(2) .* OrigAccel;
    
%     figure(6); clf;
%     hold on
%     plot(OrigAccel, OrigForce,'b.')
%     plot(OrigAccel, P3Predicted,'ko');
%     title("Validation: Ankle"); xlabel(yLab); ylabel(xLab);
%     legend(["P"+num2str(NCV)+" Actual"],["P"+num2str(NCV)+" Predicted"],'Location','northwest');
    
    P3AnkleFitLm = fitlm(OrigForce,P3Predicted);
    xAxisForceFit = linspace(min(OrigForce),max(OrigForce));
    yAxisForceFit = P3AnkleFitLm.Coefficients.Estimate(1) + P3AnkleFitLm.Coefficients.Estimate(2) .* xAxisForceFit;
    
%     figure(7); clf;
%     hold on
%     plot(OrigForce, P3Predicted,'ko');
%     plot(xAxisForceFit, yAxisForceFit,'m-');
%     title("Validation: Ankle"); xlabel("Actual: " + xLab); ylabel("Predicted: " + xLab);
%     legend(["P4 Predicted"+newline+...
%         "R^2 = " + num2str(round(P3AnkleFitLm.Rsquared.Ordinary,2))],'Location','northwest');
    
%Determine RMSE of predicted Data
PredictionRMSE = 

    writecell({["NCV("+NCV+")_P"+num2str(NCV)+"Ankle"],...
        [ForceVar{1}(7:end)+" - "+AccelVar{1}(7:end)],[P3AnkleFitLm.RMSE],...
        [thisNCV.RMSE]},...
        'RegressionDataCrossVal.csv','WriteMode','append')
        
end








