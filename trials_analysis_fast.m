%%
clear
close all
addpath 'F:\Andrew\Documents\MATLAB\Thesis'


saveit = [];
%Turn on figures during run?
PlotIndividualTrials = true;
PlotPowerSpectrum = false;
PlotMaxForces = false;
PlotAllFromThisPosition = false;
PlotRegressions = false;
PlotEntireRelevantField = false;

numberOfFilters = 1;

%Accelerometer info struct:
EmiliaPositionNames = ["Thigh","Shank","AnkleLat","AnkleMed","Heel"];
PositionNames = ["Thigh","Shank","AnkleLat"];
People = ["Emilia","Kym","Lauren","Brad"];
Mass = [63.2291,72.6537,73.9738,82.0994];

%{LEFT_LEG, RIGHT_LEG}
Locations.Emilia = {[1,3,9,7,5],[15,14,13,6,10]};
Locations.Kym = {[5,14,9],[7,15,13]};
Locations.Lauren = {[5,14,9],[7,15,13]};
Locations.Brad = {[5,14,9],[7,15,13]};

%Struct with the above information. Call AccInfo(1) for left leg; AccInfo(2) for right leg
PlacementInfo = struct(People(1),Locations.Emilia,People(2),Locations.Kym,People(3),Locations.Lauren,People(4),Locations.Brad);

%------------------------------------%
%--------------LOAD DATA-------------%
%------------------------------------%
PersonData = struct;

for i=1:4
    PersonData.Person(i) = struct;
end

for i=1:4
    PersonData.Person(i).Thigh = struct;
    PersonData.Person(i).Shank = struct;
    PersonData.Person(i).Ankle = struct;
end

MasterSave.Person1.Thigh = struct;
MasterSave.Person2.Thigh = struct;
MasterSave.Person3.Thigh = struct;
MasterSave.Person4.Thigh = struct;

MasterSave.Person1.Shank = struct;
MasterSave.Person2.Shank = struct;
MasterSave.Person3.Shank = struct;
MasterSave.Person4.Shank = struct;

MasterSave.Person1.Ankle = struct;
MasterSave.Person2.Ankle = struct;
MasterSave.Person3.Ankle = struct;
MasterSave.Person4.Ankle = struct;

MasterPosSave.Thigh = struct;
MasterPosSave.Shank = struct;
MasterPosSave.Ankle = struct;

MasterSaveNames = [];

Summary{1,4} = [];

ActualData = struct;

for Person = 1:4
    
    ThisPerson.NumberOfTrials  = 0;
    
    %Switch for file location information
    switch Person
        case 1; RowsToAnalyse = 26; FolderName = "EC 260618 9g"; %Emilia
        case 2; RowsToAnalyse = 31; FolderName = "KW 030818"; %Kym
        case 3; RowsToAnalyse = 29; FolderName = "LW 070818"; %Lauren
        case 4; RowsToAnalyse = 29; FolderName = "BS 100818"; %Brad
    end
    
    %Specify valid trials as in document
    validtrials.Person(Person).Info = trials_readvalidtrials("F:\Andrew\Documents\MATLAB\Thesis\validtrials.xlsx", People(Person), [2, RowsToAnalyse]);
    
    %Set directory for trial data
    cd("F:\OneDrive - Flinders\University\2020\MASTERS\Inherited Files\NetballWearable_EmiliaCorbo_2018\Correlation and Feasibility\Data\"+FolderName+"\CSVs")
    
    %List files in directory
    filenames = dir('**/*.csv');
    
    %Read in data from all valid trials
    for i=1:size(filenames)
        
        %Save the current file name
        %Determine whether trial is valid and locate in validtrials.Person
        Name = filenames(i).name(1:(length(filenames(i).name)-4)); %remove ".csv"
        [match,nameRow] = ismember(lower(Name),lower(validtrials.Person(Person).Info));
        
        %proceed if valid trial
        if match == true
            %tally the number of trials which are read
            ThisPerson.NumberOfTrials  = ThisPerson.NumberOfTrials  + 1;
            MasterSaveNames = [MasterSaveNames;lower(convertCharsToStrings(Name))];
            
            %IMPORT TRIAL
            ActualData(Person).Table(i).Name = Name;
            ActualData(Person).Table(i).Info = trials_import(filenames(i).name, [6, Inf]);
        end
    end
    
    Summary{Person} = [Person, ThisPerson.NumberOfTrials];
    
    %Remove all empty rows
    j = length(ActualData(Person).Table);
    for k=1:j
        if isempty(ActualData(Person).Table(j + 1 - k).Info)
            ActualData(Person).Table(j + 1 - k) = [];
        end
    end
end


%%
%---------------------------------------%
%--------------ANALYSE DATA-------------%
%---------------------------------------%
for filter = 1:1
    for Position = 1:3
        
        for Person=1:4
            PersonalTrialStats = [];
            ThisPerson.NumberOfTrials  = 0;
            ThisPerson.NumTrialsByLeg = 0;
            
            %Read in data from all valid trials
            for i=1:length(ActualData(Person).Table)
                %for i=1:size(filenames)
                
                %Save the current file name
                %Determine whether trial is valid and locate in validtrials
                Trial.Name = ActualData(Person).Table(i).Name;
                [match,nameRow] = ismember(lower(Trial.Name),lower(validtrials.Person(Person).Info));
                
                %proceed if valid trial
                if match == true
                    %tally the number of trials which are read
                    ThisPerson.NumberOfTrials  = ThisPerson.NumberOfTrials  + 1;
                    MasterSaveNames = [MasterSaveNames;lower(convertCharsToStrings(Trial.Name))];
                    
                    %LOAD TRIAL
                    Trial.AllData = ActualData(Person).Table(i).Info;
                    
                    Legs.AllUsed = split(validtrials.Person(Person).Info(nameRow,2),','); %legs used in this trial
                    Legs.NumUsed = size(Legs.AllUsed);
                    
                    ForcePlates.UsedInThisTrial = split(validtrials.Person(Person).Info(nameRow,3),','); %force plates used in this trial
                    
                    for legNumber = 1:Legs.NumUsed
                        %tally the number of trials-by-leg which are read
                        ThisPerson.NumTrialsByLeg = ThisPerson.NumTrialsByLeg + 1;
                        
                        if Legs.AllUsed(legNumber) == "L"
                            ThisLeg = 1; %Left Leg
                            Legs.thisLegLetter = "L";
                        else
                            ThisLeg = 2; %Right Leg
                            Legs.thisLegLetter = "R";
                        end
                        
                        %PLACEMENT: thigh/shank/foot etc.
                        if Person == 1; Placement = PlacementInfo(ThisLeg).Emilia(Position);
                        else; Placement = PlacementInfo(ThisLeg).Kym(Position);
                        end
                        
                        ForcePlates.AllUsedByThisLeg = str2double(split(ForcePlates.UsedInThisTrial(legNumber),'&'));
                        ForcePlates.AmountUsedByLeg = size(ForcePlates.AllUsedByThisLeg);
                        
                        %DATASHEET COLUMNS
                        ForcePlates.this = ForcePlates.AllUsedByThisLeg(1);
                        
                        %Data for Emilia is in different columns to the others
                        if Person == 1
                            ref_F = 9 * ForcePlates.this + 42;
                            ref_Acc = 3*Placement;
                        else
                            ref_F = 9 * ForcePlates.this - 6;
                            ref_Acc = 3*Placement+36;
                        end
                        
                        %MAGNITUDE
                        if ForcePlates.AmountUsedByLeg == 1
                            %Single Force Plate
                            Force.X = Trial.AllData(:,ref_F);
                            Force.Y = Trial.AllData(:,ref_F + 1);
                            Force.Z = Trial.AllData(:,ref_F + 2);
                        else
                            
                            %Multiple Force Plates
                            %Save data from first FP used by this leg:
                            Force.X1 = Trial.AllData(:,ref_F);
                            Force.Y1 = Trial.AllData(:,ref_F + 1);
                            Force.Z1 = Trial.AllData(:,ref_F + 2);
                            
                            %THEN Get force data from second FP used by this leg:
                            ForcePlates.this = ForcePlates.AllUsedByThisLeg(2);
                            
                            if Person == 1
                                ref_F = 9 * ForcePlates.this + 42;
                            else
                                ref_F = 9 * ForcePlates.this - 6;
                            end
                            
                            Force.X2 = Trial.AllData(:,ref_F);
                            Force.Y2 = Trial.AllData(:,ref_F + 1);
                            Force.Z2 = Trial.AllData(:,ref_F + 2);
                            
                            Force.X = Force.X1 + Force.X2;
                            Force.Y = Force.Y1 + Force.Y2;
                            Force.Z = Force.Z1 + Force.Z2;
                        end
                        
                        %FORCE (N)
                        Force.M = sqrt(((Force.X.^2)+(Force.Y.^2)+(Force.Z.^2)));
                        
                        %ACCELERATION (mm/s2)
                        Accel.X = Trial.AllData(:,ref_Acc);
                        Accel.Y = Trial.AllData(:,ref_Acc + 1);
                        Accel.Z = Trial.AllData(:,ref_Acc + 2);
                        Accel.M = sqrt(((Accel.X.^2)+(Accel.Y.^2)+(Accel.Z.^2)));
                        
                        %ACCELERATION (m/s2), in terms of g = 9.81ms^-1
                        Accel.X = Accel.X./1000./9.81;
                        Accel.Y = Accel.Y./1000./9.81;
                        Accel.Z = Accel.Z./1000./9.81;
                        Accel.M = Accel.M./1000./9.81;
                        
                        %DATA FOR THIS TRIAL, IN THIS POSITION, BY THIS PERSON, WITH THIS LEG, ON THIS FORCE PLATE
                        Trial.RelevantData = [Force.X,Force.Y,Force.Z,Force.M,Accel.X,Accel.Y,Accel.Z,Accel.M];
                        
                        %Remove all data with F < 40N
                        j = length(Force.M);
                        for k=1:j
                            if Force.M(j + 1 - k) < 40 % search from last value to retain continuity
                                Trial.RelevantData(j + 1 - k,:) = [];
                            end
                        end
                        
                        TrialData.RawForceX = Trial.RelevantData(:,1);
                        TrialData.RawForceY = Trial.RelevantData(:,2);
                        TrialData.RawForceZ = Trial.RelevantData(:,3);
                        TrialData.RawForceM = Trial.RelevantData(:,4);
                        
                        TrialData.RawAccelX = Trial.RelevantData(:,5);
                        TrialData.RawAccelY = Trial.RelevantData(:,6);
                        TrialData.RawAccelZ = Trial.RelevantData(:,7);
                        TrialData.RawAccelM = Trial.RelevantData(:,8);
                        
                        %Rectify Ankle Data according to global axis
                        if Position == 3
                            
                            %Don't need to rectify X-axis as it is already globally shared.
                            %Dont need to rectify Magnitude because it is already squared.
                            
                            %if Left Ankle
                            if ThisLeg == 1
                                TrialData.RawAccelY = TrialData.RawAccelZ .* -1;
                                TrialData.RawAccelZ = TrialData.RawAccelY;
                                
                                %if Right Ankle
                            elseif ThisLeg == 2
                                TrialData.RawAccelY = TrialData.RawAccelZ;
                                TrialData.RawAccelZ = TrialData.RawAccelY .* -1;
                            end
                        end
                        
                        
                        if isempty(TrialData.RawForceM)
                            "Empty: Person " + Person + ", " + Trial.Name + ", " + Legs.thisLegLetter + " Foot"
                        else
                            %Time Array: 2000Hz, so increment by 1/2000th of a second.
                            TrialData.Time = (0.0005:1/2000:(length(TrialData.RawForceM))/2000)';
                            
                            %--------------------------------------------------%
                            %-------------------FILTER DATA--------------------%
                            %--------------------------------------------------%
                            
                            %Use filtfilt rather than filter to reverse time shift
                            fs = 2000; %sampling Hz
                            
                            %FORCE
                            fc = 100; %cutoff Hz
                            Wn = fc/(fs/2); %normalised cutoff Hz
                            [num,den] = butter(4,Wn); %4th order butterworth filter
                            TrialData.ForceX = filtfilt(num,den,TrialData.RawForceX); %Filter ForceX
                            TrialData.ForceY = filtfilt(num,den,TrialData.RawForceY); %Filter ForceY
                            TrialData.ForceZ = filtfilt(num,den,TrialData.RawForceZ); %Filter ForceZ
                            TrialData.ForceM = filtfilt(num,den,TrialData.RawForceM); %Filter ForceM
                            
                            %ACCELERATION
                            if filter == 1; fc = 50; end %cutoff Hz
                            if filter == 2; fc = 20; end %cutoff Hz
                            
                            Wn = fc/(fs/2); %normalised cutoff Hz
                            [num,den] = butter(4,Wn); %4th order butterworth filter
                            TrialData.AccelX = filtfilt(num,den,TrialData.RawAccelX); %Filter AccelX
                            TrialData.AccelY = filtfilt(num,den,TrialData.RawAccelY); %Filter AccelY
                            TrialData.AccelZ = filtfilt(num,den,TrialData.RawAccelZ); %Filter AccelZ
                            TrialData.AccelM = filtfilt(num,den,TrialData.RawAccelM); %Filter AccelM
                            
                            %LOADING RATE
                            TrialData.ForceZRate = diff(TrialData.ForceZ)./(1/2000);
                            
                            %Save all data
                            %Split between postion
                            f = fieldnames(TrialData);
                            m = fieldnames(MasterPosSave);
                            p = fieldnames(MasterPosSave.(m{Position}));
                            
                            for j = 1:length(f)
                                if  isempty(p)
                                    MasterPosSave.(m{Position}).(f{j}) = TrialData.(f{j});
                                elseif ~contains(p,f{j})
                                    MasterPosSave.(m{Position}).(f{j}) = TrialData.(f{j});
                                else
                                    MasterPosSave.(m{Position}).(f{j}) = [MasterPosSave.(m{Position}).(f{j}); TrialData.(f{j})];
                                end
                            end
                            
                            %Split between person AND postion
                            f = fieldnames(TrialData);
                            m = fieldnames(MasterSave.("Person" + Person));
                            p = fieldnames(MasterSave.("Person" + Person).(m{Position}));
                            
                            for j = 1:length(f)
                                if  isempty(p)
                                    MasterSave.("Person" + Person).(m{Position}).(f{j}) = TrialData.(f{j});
                                elseif ~contains(p,f{j})
                                    MasterSave.("Person" + Person).(m{Position}).(f{j}) = TrialData.(f{j});
                                else
                                    MasterSave.("Person" + Person).(m{Position}).(f{j}) = ...
                                        [MasterSave.("Person" + Person).(m{Position}).(f{j}); TrialData.(f{j})];
                                end
                            end
                            
                            %----------------------------------------------------%
                            %COLLECT INTERESTING VARIABLES FOR REGRESSION ANALYSIS
                            %----------------------------------------------------%
                            
                            if Person == 4 && Position == 1 && ThisPerson.NumTrialsByLeg == 16
                                "";
                            end
                            
                            
                            % i.e. since cells of (1/2000)s => t = 200*1/2000s = 0.1s
                            %Samples until end of trial: X
                            [TrialVars.Accel_AXMIN,XMINLOC] = min(TrialData.AccelX);     %Accel.X Negative Peak
                            if  length(TrialData.AccelX) - XMINLOC < 200
                                SamplesX = length(TrialData.AccelX) - XMINLOC;
                            else
                                SamplesX = 200;
                            end
                            if SamplesX == 0
                                TrialVars.Accel_AXMAX=0;
                                XMAXLOC = XMINLOC;
                            else
                                [TrialVars.Accel_AXMAX,XMAXLOC] = max(TrialData.AccelX( XMINLOC+1: XMINLOC + SamplesX ));     %Accel.X Positive Peak
                            end
                            %Samples until end of trial: Y
                            [TrialVars.Accel_AYMAX,YMAXLOC] = max(TrialData.AccelY);     %Accel.Y Positive Peak
                            if  length(TrialData.AccelY) - YMAXLOC < 200;
                                SamplesY = length(TrialData.AccelY) - YMAXLOC;
                            else
                                SamplesY = 200;
                            end
                            if SamplesY == 0
                                TrialVars.Accel_AYMIN=0;
                                YMINLOC = YMAXLOC;
                            else
                                [TrialVars.Accel_AYMIN,YMINLOC] = min(TrialData.AccelY( YMAXLOC+1: YMAXLOC + SamplesY ));     %Accel.Y Negative Peak
                            end
                            %Samples until end of trial: Z
                            [TrialVars.Accel_AZMAX,ZMAXLOC] = max(TrialData.AccelZ);     %Accel.Z Positive Peak
                            if  length(TrialData.AccelZ) - ZMAXLOC < 200
                                SamplesZ = length(TrialData.AccelZ) - ZMAXLOC;
                            else
                                SamplesZ = 200;
                            end
                            if SamplesZ == 0
                                TrialVars.Accel_AZMIN=0;
                                ZMINLOC = ZMAXLOC;
                            else
                                [TrialVars.Accel_AZMIN,ZMINLOC] = min(TrialData.AccelZ( ZMAXLOC+1: ZMAXLOC + SamplesZ ));     %Accel.Z Negative Peak
                            end
                            %Samples until end of trial: M
                            [TrialVars.Accel_AMMAX,MMAXLOC] = max(TrialData.AccelM);     %Accel.M Positive Peak
                            if  length(TrialData.AccelM) - MMAXLOC < 200
                                SamplesM = length(TrialData.AccelM) - MMAXLOC;
                            else
                                SamplesM = 200;
                            end
                            if SamplesM == 0
                                TrialVars.Accel_AMMIN=0;
                                MMINLOC = MMAXLOC;
                            else
                                [TrialVars.Accel_AMMIN,MMINLOC] = min(TrialData.AccelM( MMAXLOC+1: MMAXLOC + SamplesM ));     %Accel.M Negative Peak
                            end
                            %Samples until end of trial: FORCE
                            %Force location is before acceleraiton peak
                            [TrialVars.Force_FMMAX,FMMAXLOC] = max(TrialData.ForceM(1:MMAXLOC+SamplesM));     %Force.M Positive Peak
                            [TrialVars.Force_FZMIN,FZMINLOC] = min(TrialData.ForceZ(1:ZMAXLOC+SamplesZ));     %Force.Z Negative Peak
                            
                            %ACCEL EVENT LOCATION
                            if SamplesX ~= 0; XMAXLOC = XMAXLOC + XMINLOC; end
                            if SamplesY ~= 0; YMINLOC = YMAXLOC + YMINLOC; end
                            if SamplesZ ~= 0; ZMINLOC = ZMAXLOC + ZMINLOC; end
                            if SamplesM ~= 0; MMINLOC = MMAXLOC + MMINLOC; end
                            
                            %Height Differences
                            TrialVars.Accel_AXHEIGHT = TrialVars.Accel_AXMAX - TrialVars.Accel_AXMIN;
                            TrialVars.Accel_AYHEIGHT = TrialVars.Accel_AYMAX - TrialVars.Accel_AYMIN;
                            TrialVars.Accel_AZHEIGHT = TrialVars.Accel_AZMAX - TrialVars.Accel_AZMIN;
                            TrialVars.Accel_AMHEIGHT = TrialVars.Accel_AMMAX - TrialVars.Accel_AMMIN;
                            
                            %MASS
                            TrialVars.Accel_AXMINMASS = TrialVars.Accel_AXMIN.*Mass(Person); %Mass-shifted Acceleration X MIN
                            TrialVars.Accel_AXMAXMASS = TrialVars.Accel_AXMAX.*Mass(Person); %Mass-shifted Acceleration X MAX
                            TrialVars.Accel_AYMAXMASS = TrialVars.Accel_AYMAX.*Mass(Person); %Mass-shifted Acceleration Y MAX
                            TrialVars.Accel_AZMAXMASS = TrialVars.Accel_AZMAX.*Mass(Person); %Mass-shifted Acceleration Z MAX
                            TrialVars.Accel_AMMAXMASS = TrialVars.Accel_AMMAX.*Mass(Person); %Mass-shifted Acceleration M MAX
                            
                            %INTEGRATION
                            TrialVars.Force_FZINTEG = trapz(TrialData.ForceZ); %integrate force Force.Z
                            TrialVars.Force_FMINTEG = trapz(TrialData.ForceM); %integrate force Force.M
                            TrialVars.Accel_AXINTEG = trapz(TrialData.AccelX); %integrate accel Accel.M
                            TrialVars.Accel_AMINTEG = trapz(TrialData.AccelM); %integrate accel Accel.X
                            TrialVars.Accel_AMINTEGMASS = TrialVars.Accel_AMINTEG.*Mass(Person); %Mass-shifted Integrated Acceleration M
                            TrialVars.Accel_AXINTEGMASS = TrialVars.Accel_AXINTEG.*Mass(Person); %Mass-shifted Integrated Acceleration X
                            
                            %---------LOADING RATE---------%
                            %POI
                            %"jump" trials are difficult for identifying the POI becuase there is movement prior to the jump.
                            %Analyse these accordingly.
                            if contains(lower(Trial.Name), "jump")
                                if FZMINLOC > 200
                                    startLooking =  200 ;
                                else
                                    startLooking = FZMINLOC-1 ;
                                end
                                [M,I] = max(TrialData.ForceZ(FZMINLOC-startLooking:FZMINLOC)); %find the abs min just before the abs peak
                                localMinLoc = FZMINLOC-startLooking+I;
                                validRate = find(TrialData.ForceZRate(localMinLoc:length(TrialData.ForceZRate)) < 15*Mass(Person)) + localMinLoc;
                            else
                                validRate = find(TrialData.ForceZRate < 15*Mass(Person)); %all data prior to slope reducing (increasing) by 15 bw/s
                            end
                            
                            if contains(lower(Trial.Name), "jump")
                                for k = 1:length(validRate) - 1
                                    if (validRate(k + 1) - validRate(k)) > 1
                                        if TrialData.ForceZ(validRate(k + 1)) < -100 %< Mass(Person) * -9.81 %Check first - has to exceed body weight
                                            poi = validRate(k + 1);
                                            break;
                                        end
                                    end
                                end
                            else
                                for k = 1:length(validRate) - 1
                                    if (validRate(k + 1) - validRate(k)) > 1
                                        if TrialData.ForceZ(k + 1) < -100 %< Mass(Person) * -9.81
                                            poi = k + 1;
                                            break;
                                        end
                                    end
                                end
                            end
                            
                            [M,I] = min(TrialData.ForceZ(validRate(1):poi)); %change poi to the local min just prior to the current poi
                            poi = I + validRate(1);
                            
                            %VALR Zone
                            if contains(lower(Trial.Name), "jump")
                                startLooking = localMinLoc;
                            else
                                startLooking = 1;
                            end
                            
                            under80pc = find(TrialData.ForceZ(startLooking:poi) > TrialData.ForceZ(poi)*0.8) + startLooking;
                            over20pc = find(TrialData.ForceZ(startLooking:poi) < TrialData.ForceZ(poi)*0.2) + startLooking;
                            zone20_80 = over20pc(1):under80pc(end);
                            
                            %VILR and VALR
                            [TrialVars.Force_FVILR, VILRLoc] = min(TrialData.ForceZRate(zone20_80));
                            TrialVars.Force_FVALR = mean(TrialData.ForceZRate(zone20_80));
                            VILRLoc = VILRLoc + over20pc(1) - 1;
                            
                            %LOCAL MAXES
                            MaxesF = islocalmax(TrialData.ForceM);
                            MaxesA = islocalmax((TrialData.AccelX));
                            
                            %Save all data according to person and position
                            f = fieldnames(PersonData.Person);
                            if isempty(fieldnames(PersonData.Person(Person).(f{Position})))
                                PersonData.Person(Person).(f{Position}) = TrialVars;
                            else
                                PersonData.Person(Person).(f{Position}) = [PersonData.Person(Person).(f{Position});TrialVars];
                            end
                            
                            %----------------------------------------------------%
                            %---------------------PLOT TRIALS--------------------%
                            %----------------------------------------------------%
                            if Position == 3; run('thesisgraph_VariableIsolation.m'); end
                        end
                    end
                end
            end
            if Position == 3; Summary{1,Person}(3) = ThisPerson.NumTrialsByLeg; end
        end
    end
    %%
    
%     mean(saveit(1,:))
%     mean(saveit(2,:))
    
    m = fieldnames(MasterPosSave);
    
    for i=1:3
        MasterPosSave.(m{i}).TimeAll = (0.0005:1/2000:(length(MasterPosSave.(m{i}).ForceM))/2000)';
    end
    
    %Plot Final Data
    if PlotEntireRelevantField
        figure(3); clf;
        hold on
        
        subplot(2,1,1)
        plot(MasterPosSave.TimeAll,MasterPosSave.ForceM,'b')
        legend("|Force|");
        ylabel('Force (N)'); xlabel('Time (s)');
        
        subplot(2,1,2)
        plot(MasterPosSave.TimeAll,MasterPosSave.AccelX,'r')
        legend("|Acceleration|");
        ylabel('Acceleration (g)'); xlabel('Time (s)');
        
        sgtitle("All Data")
        hold off
    end
    
    %Save Unique Activity Names
    MasterPosSave.AllTrialTypes=unique(string(MasterSaveNames),'rows');
    for z = 1:length(MasterPosSave.AllTrialTypes)
        holdit = MasterPosSave.AllTrialTypes(z);
        holdit = holdit{1};
        if holdit(length(holdit)-1) == '0'
            MasterPosSave.AllTrialTypes(z) = convertCharsToStrings(holdit(1:length(holdit)-2));
        end
    end
    
    MasterPosSave.AllTrialTypes=unique(string(MasterPosSave.AllTrialTypes),'rows');
    
    %----------------------------------------------------%
    %-------PREPARE DATA FOR REGRESSION ANALYSIS---------%
    %----------------------------------------------------%
    
    %Make Force Z Min positive values.
    for i=1:4
        for j=1:length(PersonData.Person(i).Thigh)
            PersonData.Person(i).Thigh(j).Force_FZMIN = PersonData.Person(i).Thigh(j).Force_FZMIN * -1;
        end
        for j=1:length(PersonData.Person(i).Shank)
            PersonData.Person(i).Shank(j).Force_FZMIN = PersonData.Person(i).Shank(j).Force_FZMIN * -1;
        end
        for j=1:length(PersonData.Person(i).Ankle)
            PersonData.Person(i).Ankle(j).Force_FZMIN = PersonData.Person(i).Ankle(j).Force_FZMIN * -1;
        end
    end
    
    %Make Accel X Min positive values.
    for i=1:4
        for j=1:length(PersonData.Person(i).Thigh)
            PersonData.Person(i).Thigh(j).Accel_AXMIN = PersonData.Person(i).Thigh(j).Accel_AXMIN * -1;
        end
        for j=1:length(PersonData.Person(i).Shank)
            PersonData.Person(i).Shank(j).Accel_AXMIN = PersonData.Person(i).Shank(j).Accel_AXMIN * -1;
        end
        for j=1:length(PersonData.Person(i).Ankle)
            PersonData.Person(i).Ankle(j).Accel_AXMIN = PersonData.Person(i).Ankle(j).Accel_AXMIN * -1;
        end
    end
    
    %Make Accel X MinMass positive values.
    for i=1:4
        for j=1:length(PersonData.Person(i).Thigh)
            PersonData.Person(i).Thigh(j).Accel_AXMINMASS = PersonData.Person(i).Thigh(j).Accel_AXMINMASS * -1;
        end
        for j=1:length(PersonData.Person(i).Shank)
            PersonData.Person(i).Shank(j).Accel_AXMINMASS = PersonData.Person(i).Shank(j).Accel_AXMINMASS * -1;
        end
        for j=1:length(PersonData.Person(i).Ankle)
            PersonData.Person(i).Ankle(j).Accel_AXMINMASS = PersonData.Person(i).Ankle(j).Accel_AXMINMASS * -1;
        end
    end
    
    %CONSOLIDATE DATA
    MasterVars.P1Thigh = PersonData.Person(1).Thigh;
    MasterVars.P2Thigh = PersonData.Person(2).Thigh;
    MasterVars.P3Thigh = PersonData.Person(3).Thigh;
    MasterVars.P4Thigh = PersonData.Person(4).Thigh;
    MasterVars.P1Shank = PersonData.Person(1).Shank;
    MasterVars.P2Shank = PersonData.Person(2).Shank;
    MasterVars.P3Shank = PersonData.Person(3).Shank;
    MasterVars.P4Shank = PersonData.Person(4).Shank;
    MasterVars.P1Ankle = PersonData.Person(1).Ankle;
    MasterVars.P2Ankle = PersonData.Person(2).Ankle;
    MasterVars.P3Ankle = PersonData.Person(3).Ankle;
    MasterVars.P4Ankle = PersonData.Person(4).Ankle;
    
    MasterVars.Thigh = [MasterVars.P1Thigh; MasterVars.P2Thigh; MasterVars.P3Thigh; MasterVars.P4Thigh];
    MasterVars.Shank = [MasterVars.P1Shank; MasterVars.P2Shank; MasterVars.P3Shank; MasterVars.P4Shank];
    MasterVars.Ankle = [MasterVars.P1Ankle; MasterVars.P2Ankle; MasterVars.P3Ankle; MasterVars.P4Ankle];
    
    
    
    MasterShankMass = [...
        ones(1,length(MasterVars.P1Shank))*Mass(1),...
        ones(1,length(MasterVars.P2Shank))*Mass(2),...
        ones(1,length(MasterVars.P3Shank))*Mass(3),...
        ones(1,length(MasterVars.P4Shank))*Mass(4)];
    

    
    MasterShankMassP1 = [ones(1,length(MasterVars.P1Shank))*Mass(1)];
    MasterShankMassP2 = [ones(1,length(MasterVars.P2Shank))*Mass(2)];
    MasterShankMassP3 = [ones(1,length(MasterVars.P3Shank))*Mass(3)];
    MasterShankMassP4 = [ones(1,length(MasterVars.P4Shank))*Mass(4)];
    % MasterSaveAllDataEvents = [Master.Thigh; Master.Shank; Master.Ankle];
    
    %% CONFIGURE LINEAR CROSS-VALIDATION FILES
    writematrix("",'RegressionDataColumnsP.csv')
    writematrix("",'RegressionDataColumnsC.csv')
    writematrix("",'RegressionDataCrossVal.csv')
    
    %% Configure Log Data File
    writematrix("",'RegressionDataLogError.csv')
    writecell({...
        ["Participant"],["Location"],["Force"],["Acceleration"],...
        ["Linear R^2: "],["Log R^2:"],["Linear RMSE: "],["Log RMSE: "]},...
        'RegressionDataLogError.csv','WriteMode','append');
    
    %% Configure Log Data File COHORT
    writematrix("",'RegressionDataLogErrorCOHORT.csv')
    writecell({...
        ["Location"],["Force"],["Acceleration"],...
        ["Linear R^2: "],["Log R^2:"],["Linear RMSE: "],["Log RMSE: "]},...
        'RegressionDataLogErrorCOHORT.csv','WriteMode','append');
    
 %%
    for CV = 4:4
        
        switch CV
            case 1; CVPersons = [1,2,3]; NCV = 4;
            case 2; CVPersons = [1,2,4]; NCV = 3;
            case 3; CVPersons = [1,3,4]; NCV = 2;
            case 4; CVPersons = [2,3,4]; NCV = 1;
        end
        
        %All Variables without Person 3
        %         MasterVars.ThighN3 = [MasterVars.P1Thigh; MasterVars.P2Thigh; MasterVars.P4Thigh];
        %         MasterVars.ShankN3 = [MasterVars.P1Shank; MasterVars.P2Shank; MasterVars.P4Shank];
        %         MasterVars.AnkleN3 = [MasterVars.P1Ankle; MasterVars.P2Ankle; MasterVars.P4Ankle];
        
        MasterVars.ThighN3 = [...
            MasterVars.("P"+num2str(CVPersons(1))+"Thigh");...
            MasterVars.("P"+num2str(CVPersons(2))+"Thigh"); ...
            MasterVars.("P"+num2str(CVPersons(3))+"Thigh")];
        MasterVars.ShankN3 = [...
            MasterVars.("P"+num2str(CVPersons(1))+"Shank");...
            MasterVars.("P"+num2str(CVPersons(2))+"Shank"); ...
            MasterVars.("P"+num2str(CVPersons(3))+"Shank")];
        MasterVars.AnkleN3 = [...
            MasterVars.("P"+num2str(CVPersons(1))+"Ankle");...
            MasterVars.("P"+num2str(CVPersons(2))+"Ankle"); ...
            MasterVars.("P"+num2str(CVPersons(3))+"Ankle")];
        
        MasterShankMassN3 = [...
            ones(1,length(MasterVars.("P"+num2str(CVPersons(1))+"Shank")))*Mass(CVPersons(1)),...
            ones(1,length(MasterVars.("P"+num2str(CVPersons(2))+"Shank")))*Mass(CVPersons(2)),...
            ones(1,length(MasterVars.("P"+num2str(CVPersons(3))+"Shank")))*Mass(CVPersons(3))];
        
        
        %Determine Regressions between TrialStats
        VariableNames = fieldnames(orderfields(TrialVars)); %get all variable names
        NumVar = length(VariableNames);    %count number of variables
        
        MasterFields = fieldnames(MasterVars); %get all variable names
        MasterNumVar = length(MasterFields); %count number of variables
        
        %Plot Personal max forces. Force data is the same between positions.
        if PlotMaxForces
            figure(4)
            switch Person
                case 1; subplot(2,2,1); plot(extractfield(MasterVars.P1Ankle,"Force_FMaxM"),'r.'); title("Person " + 1 + " - Force: MaxM");
                case 2; subplot(2,2,2); plot(extractfield(MasterVars.P2Ankle,"Force_FMaxM"),'c.'); title("Person " + 2 + " - Force: MaxM");
                case 3; subplot(2,2,3); plot(extractfield(MasterVars.P3Ankle,"Force_FMaxM"),'b.'); title("Person " + 3 + " - Force: MaxM");
                case 4; subplot(2,2,4); plot(extractfield(MasterVars.P4Ankle,"Force_FMaxM"),'k.'); title("Person " + 4 + " - Force: MaxM");
            end
            ylabel('Force (N)'); xlabel('Trial');
        end
        
        
        %repeat this 4 times for each cross validation
        GraphAnalysis = 8;
        switch GraphAnalysis
            case 1
                run('thesisgraph_everytrial.m')
            case 2
                run('thesisgraph_Phase1Integ.m')
            case 3
                run('thesisgraph_Phase1CrossThigh.m')
                run('thesisgraph_Phase1CrossShank.m')
                run('thesisgraph_Phase1CrossAnkle.m')
            case 4
                run('thesisgraph_NewPhase2Log.m')
            case 5
                run('thesisgraph_NewPhase2LogCOHORT.m')
                

            case 8
                run('New_NeuralNets_Variables.m')
        end
        
        
    end
    
    
    
    
end