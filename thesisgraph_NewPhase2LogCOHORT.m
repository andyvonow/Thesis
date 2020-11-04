%%
close all
writematrix("Regression Analysis: R^2",'RegressionData.csv')
for pos = 1:3
    switch pos
        case 1; locat = "Thigh";
        case 2; locat = "Shank";
        case 3; locat = "Ankle";
    end
    for variable = 1:3
        switch variable
            case 1; ForceVar = "Force_FZMIN"; AccelVar = "XMAXMASS";
            case 2; ForceVar = "Force_FZMIN"; AccelVar = "XMINMASS";
            case 3; ForceVar = "Force_FZMIN"; AccelVar = "XHEIGHT";
        end
        
        
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
                        
                        
                        plotting = false;
                        
                        
                        
                        %---------------------------------------------------------------------------%
                        %---------------------------------------------------------------------------%
                        %---------------------------------------------------------------------------%
                        
                        
                        %Plot the relationship?
                        if ~contains(string(MasterFields(MasterVar)), "P") && ...
                                contains(string(MasterFields(MasterVar)), locat) && ...
                                contains(VariableNames(m),ForceVar) && contains(VariableNames(n),AccelVar) && ...
                                contains(VariableNames(n),"MASS")
                            
                            if contains(string(MasterFields(MasterVar)),"P1")
                                figureNumber = 1;
                                plotting = true;
                            elseif contains(string(MasterFields(MasterVar)),"P2")
                                figureNumber = 2;
                                plotting = true;
                            elseif contains(string(MasterFields(MasterVar)),"P3")
                                figureNumber = 3;
                                plotting = true;
                            elseif contains(string(MasterFields(MasterVar)),"P4")
                                figureNumber = 4;
                                plotting = true;
                            end
                        end
                        
                        if plotting
                            
%                             figure(1); %clf(figureNumber);
%                             subplot(2,2,figureNumber)
                            %                     figure(7)
                            %                     subplot(2,2,figureNumber)
                            
                            hold on
                            dotsColour = 'b';
                            SectionName = MasterFields(MasterVar);
                            switch SectionName{1}(2)
                                case '1'
                                    dotsColour = 'k';
                                    legendNumber = 1;
                                case '2'
                                    dotsColour = 'k';
                                    legendNumber = 2;
                                case '3'
                                    dotsColour = 'k';
                                    legendNumber = 3;
                                case '4'
                                    dotsColour = 'k';
                                    legendNumber = 4;
                            end
                            %remove the "_" from the VariableName
                            xLab = char(string(VariableNames(m)));
                            yLab = char(string(VariableNames(n)));
                            xLab = xLab(1:5)+" "+xLab(8:length(xLab))+" (N)";
                            yLab = yLab(1:3)+" "+yLab(8:length(yLab))+" (g)";
                            
                            %Linear Regression line
                            
                            
                            %Always plot Acceleration on x-axis
                            if contains(VariableNames(m),"Accel")
                                LinearRegression = fitlm(independent,dependent);
                                LinearRegressionData{m,n+1} = LinearRegression.Rsquared.Ordinary;
                                x = linspace(min(independent),max(independent));
                                y = LinearRegression.Coefficients.Estimate(1) + LinearRegression.Coefficients.Estimate(2) * x;
%                                 plot(independent,dependent,[dotsColour,'.'])
%                                 plot(x,y,[dotsColour,'--'])
%                                 xlabel(xLab); ylabel(yLab);
                            else
                                LinearRegression = fitlm(dependent,independent);
                                LinearRegressionData{m,n+1} = LinearRegression.Rsquared.Ordinary;
                                x = linspace(min(dependent),max(dependent));
                                y = LinearRegression.Coefficients.Estimate(1) + LinearRegression.Coefficients.Estimate(2) * x;
%                                 plot(dependent,independent,[dotsColour,'.'])
%                                 plot(x,y,['b','--'])
%                                 xlabel(yLab); ylabel(xLab);
                                
                                %determine log curve fit
                                
                                
                                %make model
                                fun = @(dependent)(log2(dependent + abs(min(dependent)) + 1));
                                
                                %xFit = lsqcurvefit(fun,1,dependent,independent);
                                
                                %linefit
                                Xaxis = linspace(min(dependent),max(dependent));
                                %                         plot(times,fun(times),'r-'); %normal plot with log curve
                                
                                logYaxis = fun(dependent); %log estimation
                                logfitted = fitlm(logYaxis,independent) %calculated,actual
                                logfitted.Coefficients.Estimate(1)
                                logfitted.Coefficients.Estimate(2)
%                                 plot(Xaxis,logfitted.Coefficients.Estimate(1) + fun(Xaxis)*logfitted.Coefficients.Estimate(2),'r-' )
%                                 legend([SectionName{1}(3:7) + " Events"],...
%                                     ["Linear Fit: R^2 = "+round(LinearRegression.Rsquared.Ordinary,2)],...
%                                     ["Log Fit: R^2 = " + round(logfitted.Rsquared.Ordinary,2)],'Location','southeast')
%                                 title(["Person " + SectionName{1}(2)]);
                                
                                LogFitXaxis = linspace(min(logYaxis),max(logYaxis));
                                %                             if SectionName{1}(2) == '1'
                                %                                 figure(figureNumber + 1); clf(figureNumber + 1);
                                %                                 hold on
                                %                                 plot(logYaxis,independent,'b.');
                                %                                 plot(LogFitXaxis,logfitted.Coefficients.Estimate(1) + ...
                                %                                     logfitted.Coefficients.Estimate(2) .* LogFitXaxis,['r','-'])
                                %
                                %                                 %                             xlabel("vGRF(MPA) = a + b * log_2("+AccelVar+"...) (N)");
                                %                                 xlabel("a + b * log_2("+AccelVar+" + abs("+AccelVar+") + 1)"+newline+"Where: Acc "+AccelVar+" (g)");
                                %                                 ylabel("Actual: "+xLab);
                                %                                 %                             ylabel("vGRF (Force Plate) (N)");
                                %
                                %                                 %                             switch legendNumber
                                %                                 %                                 case 1
                                %                                 leg1 = legend("Shank Events",["Log Fit: R^2 = " + round(logfitted.Rsquared.Ordinary,2)],'Location','southeast');
                                %                                 %                                 case 2
                                %                                 %                                     leg1 = legend([leg1.String(1),leg1.String(2),"",["Person " + SectionName{1}(2)]]);
                                %                                 %                                 case 3
                                %                                 %                                     leg1 = legend([leg1.String(1),leg1.String(2),leg1.String(3),leg1.String(4),"",["Person " + SectionName{1}(2)]]);
                                %                                 %                                 case 4
                                %                                 %                                     leg1 = legend([leg1.String(1),leg1.String(2),leg1.String(3),leg1.String(4),leg1.String(5),leg1.String(6),"",["Person " + SectionName{1}(2)]],'Location','northwest');
                                %                                 %                             end
                                %
                                %
                                %                                 title("Person "+num2str(SectionName{1}(2)));
                                %
                                %                             end
                                
                            end
                            
                            LinearConstants(str2double(SectionName{1}(2))) = LinearRegression.Coefficients.Estimate(1);
                            LinearCoeffcnts(str2double(SectionName{1}(2))) = LinearRegression.Coefficients.Estimate(2);
                            
                            LogConstants(str2double(SectionName{1}(2))) = logfitted.Coefficients.Estimate(1);
                            LogCoeffcnts(str2double(SectionName{1}(2))) = logfitted.Coefficients.Estimate(2);
                            
                            %                     st = SectionName{1}(1) + "erson " + SectionName{1}(2) ...
                            %                         + newline + ...
                            %                         "Linear: Force = " + ...
                            %                         LinearConstants(str2double(SectionName{1}(2))) + " + " + ...
                            %                         LinearCoeffcnts(str2double(SectionName{1}(2))) + ...
                            %                         " * acc" + ...
                            %                         newline + ...
                            %                         "Log: Force = "  + ...
                            %                         LogConstants(str2double(SectionName{1}(2))) + " + " + ...
                            %                         LogCoeffcnts(str2double(SectionName{1}(2))) + ...
                            %                         " * log_2(acc + abs(min(acc)) + 1)";
                            %
                            
                        end
                        
                        %---------------------------------------------------------------------------%
                        %---------------------------------------------------------------------------%
                        %---------------------------------------------------------------------------%
                        
                    else
                        LinearRegressionData{m,n+1} = '-';
                    end
                end
            end
            
            
            %
            %     VarWithoutUnderscores{NumVar,1} = {};
            %
            %     for name=1:NumVar
            %         if contains(VariableNames{name,1},"Accel_")
            %             VarWithoutUnderscores{name,1} = replace(VariableNames{name,1},"Accel_","");
            %         elseif contains(VariableNames{name,1},"Force_")
            %             VarWithoutUnderscores{name,1} = replace(VariableNames{name,1},"Force_","F_");
            %         end
            %     end
            %
            %     %Save Regression Data
            %     writematrix("",'RegressionData.csv','WriteMode','append')
            %     writecell({...
            %         string(replace(cell(MasterFields(MasterVar)),"_AllTrialStats","")),...
            %         VarWithoutUnderscores{1:19,1}},...
            %         'RegressionData.csv','WriteMode','append')
            %
            %     %Write Force lines only. (m == row)
            %     for m=1:NumVar
            %         if ~contains(string(LinearRegressionData(m,1)),"Accel")
            %             LinearRegressionData(m,1) = {[replace(string(LinearRegressionData(m,1)),"Force_","")]}; %Don't write "Force_"
            %             cell2write = LinearRegressionData(m,1:20); %only write acceleration columns
            %             writecell(cell2write,'RegressionData.csv','WriteMode','append')
            %             %writecell(LinearRegressionData(m,:),'RegressionData.csv','WriteMode','append')
            %         end
            %     end
            %
            %
            
        end
        "";
        
        %%
        %plot graphs?
        if false
            
            %----------------------------------------------------------%
            %----------------Determine Log Equations-------------------%
            %----------------------------------------------------------%
            MassArray = [Mass(CVPersons(1)),Mass(CVPersons(2)),Mass(CVPersons(3))];
            LogConsArray = [LogConstants(CVPersons(1)),LogConstants(CVPersons(2)),LogConstants(CVPersons(3))];
            LogCoefArray = [LogCoeffcnts(CVPersons(1)),LogCoeffcnts(CVPersons(2)),LogCoeffcnts(CVPersons(3))];
            
            LogConsEq = fitlm(MassArray,LogConsArray);
            LogCoefEq = fitlm(MassArray,LogCoefArray);
            
            MassLine = linspace(min(MassArray),max(MassArray));
            
            figure(8)
            subplot(1,2,1);
            plot(MassArray,LogConsArray,'bo',...
                MassLine,(LogConsEq.Coefficients.Estimate(1)+LogConsEq.Coefficients.Estimate(2)*MassLine),'r--');
            xlabel('Mass (kg)'); ylabel('a(m)'); title("Constant a(m)");
            legend("Constants",["R^2: "+num2str(LogConsEq.Rsquared.Ordinary)],'Location','southeast')
            
            subplot(1,2,2);
            plot(MassArray,LogCoefArray,'bo',...
                MassLine,(LogCoefEq.Coefficients.Estimate(1)+LogCoefEq.Coefficients.Estimate(2)*MassLine),'r--');
            xlabel('Mass (kg)'); ylabel('b(m)'); title("Coefficient b(m)");
            legend("Coefficients",["R^2: "+num2str(LogCoefEq.Rsquared.Ordinary)],'Location','southeast')
            sgtitle("Coefficient Approximation")
            
            FinalLogConsMassEq = "a(m) = " + LogConsEq.Coefficients.Estimate(1)+ " + " + LogConsEq.Coefficients.Estimate(2) + " * Mass"
            FinalLogCoefMassEq = "b(m) = " + LogCoefEq.Coefficients.Estimate(1)+ " + " + LogCoefEq.Coefficients.Estimate(2) + " * Mass"
            
            
            
            %PREDICTED RELATIONSHIPS
            prediction = @(Mass,Accel)(...
                (LogConsEq.Coefficients.Estimate(1) + LogConsEq.Coefficients.Estimate(2) .* Mass) + ...
                ((LogCoefEq.Coefficients.Estimate(1) + LogCoefEq.Coefficients.Estimate(2) .* Mass) .* ...
                log2(Accel + abs(min(Accel)) + 1)));
            
            OriginalNCVAccel = [MasterVars.("P"+num2str(NCV)+locat).("Accel_A"+AccelVar)];
            OriginalNCVForce = [MasterVars.("P"+num2str(NCV)+locat).(ForceVar)];
            
            Xaxis = linspace(min(OriginalNCVAccel),max(OriginalNCVAccel));
            
            logYaxis = fun(OriginalNCVAccel);
            OldLinFit = fitlm(OriginalNCVAccel,OriginalNCVForce);
            logfitted = fitlm(logYaxis,OriginalNCVForce);
            NewLogFit = fitlm(prediction(Mass(NCV),OriginalNCVAccel),OriginalNCVForce);
            
            
            figure(9); clf(9);
            hold on
            plot(OriginalNCVAccel, OriginalNCVForce,'k.')
            plot(Xaxis,OldLinFit.Coefficients.Estimate(1) + ...
                OldLinFit.Coefficients.Estimate(2) * Xaxis,'b--')
            plot(Xaxis,logfitted.Coefficients.Estimate(1) + ...
                fun(Xaxis)*logfitted.Coefficients.Estimate(2),'r-' )
            plot(OriginalNCVAccel,prediction(Mass(NCV),OriginalNCVAccel),'mo');
            title("Person" + NCV)
            xlabel(yLab);
            ylabel(xLab);
            legend("Original Data",...
                "Linear Fit, RMSE: " + round(OldLinFit.RMSE,2)+", R^2: "+round(OldLinFit.Rsquared.Ordinary,2),...
                "Original Log Fit, RMSE: " + round(logfitted.RMSE,2)+", R^2: "+round(logfitted.Rsquared.Ordinary,2),...
                "Predicted Fit, RMSE: " + round(NewLogFit.RMSE,2)+", R^2: "+round(NewLogFit.Rsquared.Ordinary,2),...
                'Location','southeast')
            
          ""  
        else
            %Don't plot graphs.
            
            %----------------------------------------------------------%
            %----------------Determine Log Equations-------------------%
            %----------------------------------------------------------%
            MassArray = [Mass(CVPersons(1)),Mass(CVPersons(2)),Mass(CVPersons(3))];
            LogConsArray = [LogConstants(CVPersons(1)),LogConstants(CVPersons(2)),LogConstants(CVPersons(3))];
            LogCoefArray = [LogCoeffcnts(CVPersons(1)),LogCoeffcnts(CVPersons(2)),LogCoeffcnts(CVPersons(3))];
            
            LogConsEq = fitlm(MassArray,LogConsArray);
            LogCoefEq = fitlm(MassArray,LogCoefArray);
            
            MassLine = linspace(min(MassArray),max(MassArray));
            
            %PREDICTED RELATIONSHIPS
            prediction = @(Mass,Accel)(...
                (LogConsEq.Coefficients.Estimate(1) + LogConsEq.Coefficients.Estimate(2) .* Mass) + ...
                ((LogCoefEq.Coefficients.Estimate(1) + LogCoefEq.Coefficients.Estimate(2) .* Mass) .* ...
                log2(Accel + abs(min(Accel)) + 1)));
            
            OriginalNCVAccel = [MasterVars.(locat).("Accel_A"+AccelVar)];
            OriginalNCVForce = [MasterVars.(locat).(ForceVar)];
            
            Xaxis = linspace(min(OriginalNCVAccel),max(OriginalNCVAccel));
            
            logYaxis = fun(OriginalNCVAccel);
            OldLinFit = fitlm(OriginalNCVAccel,OriginalNCVForce);
            logfitted = fitlm(logYaxis,OriginalNCVForce);
            
            Prediction1 = prediction(Mass(1),[MasterVars.("P1"+locat).("Accel_A"+AccelVar)]);
            Prediction2 = prediction(Mass(2),[MasterVars.("P2"+locat).("Accel_A"+AccelVar)]);
            Prediction3 = prediction(Mass(3),[MasterVars.("P3"+locat).("Accel_A"+AccelVar)]);
            Prediction4 = prediction(Mass(4),[MasterVars.("P4"+locat).("Accel_A"+AccelVar)]);
            
            PredictionCohort = [...
               Prediction1';...
               Prediction2';...
               Prediction3';...
               Prediction4'...
               ];
            
            NewLogFit = fitlm(PredictionCohort,OriginalNCVForce);
%             NewLogFit = fitlm(prediction(Mass(NCV),OriginalNCVAccel),OriginalNCVForce);
            
            
%             writecell({["NCV("+NCV+")_P"+num2str(NCV)+locat],...
            writecell({[locat],...
                [ForceVar{1}(8:end)],[AccelVar],...
                [OldLinFit.Rsquared.Ordinary],...
                [logfitted.Rsquared.Ordinary],...
                [NewLogFit.Rsquared.Ordinary],...
                [OldLinFit.RMSE],...
                [logfitted.RMSE],...
                [NewLogFit.RMSE]},...
                'RegressionDataLogErrorCOHORT.csv','WriteMode','append')
            
            figure(10); clf(10);
            hold on
            plot(PredictionCohort,OriginalNCVForce,'md');
            newx = linspace(min(PredictionCohort),max(PredictionCohort));
            plot(newx,NewLogFit.Coefficients.Estimate(1) + ...
                 NewLogFit.Coefficients.Estimate(2) .*newx,'g-');
            legend("F_V(m,A_X)",...
                "RMSE: "+ round(NewLogFit.RMSE,2)+", R^2: "+round(NewLogFit.Rsquared.Ordinary,2),...
                'Location','southeast')
            xlabel("F_V(m,A_X)" + newline + "_{A_{"+AccelVar+"} (g)}");
            ylabel(xLab);
                        title("Cohort Prediction")

            figure(9); clf(9);
            hold on
            plot(OriginalNCVAccel, OriginalNCVForce,'k.')
            
%             plot(Xaxis,OldLinFit.Coefficients.Estimate(1) + ...
%                 OldLinFit.Coefficients.Estimate(2) * Xaxis,'b--')
%             
%             plot(Xaxis,logfitted.Coefficients.Estimate(1) + ...
%                 fun(Xaxis)*logfitted.Coefficients.Estimate(2),'r-' )
%             
%             plot(OriginalNCVAccel,PredictionCohort,'md')
            
            plot(OriginalNCVAccel,...
                NewLogFit.Coefficients.Estimate(1) + ...
                NewLogFit.Coefficients.Estimate(2) .* PredictionCohort...
                ,'go')
            
            title("Cohort")
            xlabel("y = 858.43 + 0.18932 * F_V(m,A_X)" + newline + "_{A_{"+AccelVar+"} (g)}");
            ylabel(xLab);
            legend("Original Data",...
                "Adjusted Predicted Fit"+newline+"RMSE: "+ round(NewLogFit.RMSE,2)+", R^2: "+round(NewLogFit.Rsquared.Ordinary,2),'Location','southeast')
     
%             figure(11); clf(11);
%             hold on
%             plot(OriginalNCVAccel, OriginalNCVForce,'k.')
%             
%             plot(Xaxis,OldLinFit.Coefficients.Estimate(1) + ...
%                 OldLinFit.Coefficients.Estimate(2) * Xaxis,'b--')
%             
%             plot(Xaxis,logfitted.Coefficients.Estimate(1) + ...
%                 fun(Xaxis)*logfitted.Coefficients.Estimate(2),'r-' )
%             
%             plot(OriginalNCVAccel,PredictionCohort,'md')
%             
%             plot(OriginalNCVAccel,...
%                 NewLogFit.Coefficients.Estimate(1) + ...
%                 NewLogFit.Coefficients.Estimate(2) .* PredictionCohort...
%                 ,'go')
%             
%             title("Cohort")
%             xlabel(yLab);
%             ylabel(xLab);
%             legend("Original Data",...
%                 "Linear Fit, RMSE: " + round(OldLinFit.RMSE,2)+", R^2: "+round(OldLinFit.Rsquared.Ordinary,2),...
%                 "Original Log Fit, RMSE: " + round(logfitted.RMSE,2)+", R^2: "+round(logfitted.Rsquared.Ordinary,2),...
%                 "F_V(m,A_X), RMSE: "+ round(NewLogFit.RMSE,2)+", R^2: "+round(NewLogFit.Rsquared.Ordinary,2),'Location','southeast')
       
if NCV == 1        
    ""
end

        end
        
        
        
        
    end
    
    
    
    
    
end