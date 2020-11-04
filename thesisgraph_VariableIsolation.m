
if PlotIndividualTrials
    
    WaveformOrIntegration = 0;
    
    switch WaveformOrIntegration
        case 1
                run('plot_graphs.m')
        case 2
            
            %-------------------------------------------------------%
            %-----------------------Events--------------------------%
            %-------------------------------------------------------%
            
            figure(1);
            clf;
            
            %Force
            subplot(2,1,1)
            hold on;
            yyaxis left
            plot(TrialData.Time,TrialData.ForceM,'b');
            plot(TrialData.Time,TrialData.ForceX,'b');
            plot(TrialData.Time,TrialData.ForceY,'b');
            plot(TrialData.Time,TrialData.ForceZ,'b');
            plot(FMMAXLOC/2000,TrialVars.Force_FMMAX,'bd');
            plot(FZMINLOC/2000,TrialVars.Force_FZMIN,'b*');
            plot(zone20_80./2000,TrialData.ForceZ((over20pc(1):under80pc(end))),'rd')
            ylabel('Force (N)');
            xlabel('Time (s)');
            
            yyaxis right
            ylabel('dF_Z/dt (N)');
            plot(TrialData.Time,[TrialData.ForceZRate;TrialData.ForceZRate(end)],'r')
            plot(VILRLoc/2000,TrialVars.Force_FVILR,'r*');
            
            title('Waveform Events')
            legend("F_M","F_X","F_Y","F_Z","MMAX","ZMIN",...
                "F_Z Loading Zone","dF_Z/dt","VILR")
            hold off
            
            %Acceleration
            subplot(2,1,2)
            hold on;
            plot(TrialData.Time,TrialData.AccelM,'r');
            plot(TrialData.Time,TrialData.AccelX,'b');
            plot(TrialData.Time,TrialData.AccelY,'k');
            plot(TrialData.Time,TrialData.AccelZ,'g');
            plot(MMINLOC/2000,TrialData.AccelM(MMINLOC),'r*');
            plot(XMINLOC/2000,TrialData.AccelX(XMINLOC),'b*');
            plot(YMINLOC/2000,TrialData.AccelY(YMINLOC),'k*');
            plot(ZMINLOC/2000,TrialData.AccelZ(ZMINLOC),'g*');
            plot(MMAXLOC/2000,TrialData.AccelM(MMAXLOC),'rd');
            plot(XMAXLOC/2000,TrialData.AccelX(XMAXLOC),'bd');
            plot(YMAXLOC/2000,TrialData.AccelY(YMAXLOC),'kd');
            plot(ZMAXLOC/2000,TrialData.AccelZ(ZMAXLOC),'gd');
            
            ylabel('Acceleration (g)');
            xlabel('Time (s)');
            legend("A_M","A_X","A_Y","A_Z",...
                "MMIN",...
                "XMIN",...
                "YMIN",...
                "ZMIN",...
                "MMAX",...
                "XMAX",...
                "YMAX",...
                "ZMAX");
            
            sgtitle("Participant " + Person + ": Two-Foot Land, " + Legs.thisLegLetter + " Foot, " + PositionNames(Position))
%             sgtitle("Participant " + Person + ": " + Trial.Name + ", " + Legs.thisLegLetter + " Foot, " + PositionNames(Position))
            hold off
        case 3
            
            %-------------------------------------------------------%
            %---------------------Integration-----------------------%
            %-------------------------------------------------------%
            
            figure(2)
            clf(2)
            
            subplot(1,2,1)
            hold on
            plot(TrialData.Time,TrialData.ForceM,'r');
            plot(TrialData.Time,TrialData.ForceZ,'b');
            set(area(TrialData.Time,TrialData.ForceM),'FaceColor',[1,0.3,0.4]);
            set(area(TrialData.Time,TrialData.ForceZ),'FaceColor',[0,0.4,0.9]);
            ylabel('Force (N)');
            xlabel('Time (s)');
            title('Force')
            legend("Force M","Force Z")
            hold off
            
            subplot(1,2,2)
            hold on;
            plot(TrialData.Time,TrialData.AccelM,'r');
            plot(TrialData.Time,TrialData.AccelX,'b');
            set(area(TrialData.Time,TrialData.AccelM),'FaceColor',[1,0.3,0.4]);
            set(area(TrialData.Time,TrialData.AccelX),'FaceColor',[0,0.4,0.9]);
            ylabel('Acceleration (g)');
            xlabel('Time (s)');
            legend("Accel M","Accel X")
            title('Acceleration')
            sgtitle("Person " + Person + ": " + Trial.Name + ", " + Legs.thisLegLetter + " Foot, " + PositionNames(Position))
            hold off
            ""
    end
end

if Person == 1 && Position == 1
    "Wait Here"; %Breakpoint
end







