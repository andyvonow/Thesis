% %%
% fc = 20; %cutoff Hz
% fs = 2000; %sampling Hz
% Wn = fc/(fs/2);%normalised cutoff Hz
% [num,den] = butter(4,Wn); %4th order butterworth filter
% Filter20AX = filtfilt(num,den,TrialData.RawAccelX); %Filter AccelM
% 
% figure(4)
% clf
% hold on
% 
% yyaxis left
% plot(TrialData.Time,TrialData.ForceM,'b');
% plot(TrialData.Time,TrialData.RawForceM,'k--');
% % plot(TrialData.Time(LocalMaxesF),TrialData.ForceM(LocalMaxesF),'kd');
% ylabel('Force (N)')
% 
% yyaxis right
% plot(TrialData.Time,TrialData.AccelX,'r');
% plot(TrialData.Time,TrialData.RawAccelX,'k--');
% plot(TrialData.Time,Filter20AX,'m--');
% 
% % plot(TrialData.Time(LocalMaxesA),TrialData.AccelX(LocalMaxesA),'ko');
% ylabel('Acceleration (g)')
% 
% xlabel('Time (s)')
% legend("|Force|","Local Max","Acceleration X","Local Max")
% sgtitle("Run, Left Ankle")
% %%
% fc = 20; %cutoff Hz
% fs = 2000; %sampling Hz
% Wn = fc/(fs/2);%normalised cutoff Hz
% [num,den] = butter(4,Wn); %4th order butterworth filter
% Filter20AX = filtfilt(num,den,TrialData.RawAccelX); %Filter AccelM
% 
% figure(4)
% clf
% hold on
% 
% plot(TrialData.Time,TrialData.RawAccelX,'b');
% plot(TrialData.Time,TrialData.AccelX,'r--');
% plot(TrialData.Time,Filter20AX,'k--');
% 
% ylabel('Acceleration (g)')
% xlabel('Time (s)')
% 
% legend("Raw A_X","50 Hz Filtered","20 Hz Filtered")
% sgtitle("Participant 1, Two-Foot Land, Left Ankle")
% %%
% figure(3)
% clf
% hold on
% 
% plot(TrialData.Time,TrialData.ForceM,'b');
% plot(TrialData.Time(LocalMaxesF),TrialData.ForceM(LocalMaxesF),'kd');
% ylabel('Force (N)')
% xlabel('Time (s)')
% legend("|Force|","Local Max")
% sgtitle("Run, Left Ankle")

%%
% figure(5)
% subplot(2,1,1); pspectrum(TrialData.ForceM,TrialData.Time); legend("|Force|");
% subplot(2,1,2); pspectrum(TrialData.AccelX,TrialData.Time); legend("Acceleration X");

%%
%Use filtfilt rather than filter to reverse time shift
% fc = 100; %cutoff Hz
% fs = 2000; %sampling Hz
% Wn = fc/(fs/2);%normalised cutoff Hz
% [num,den] = butter(4,Wn); %4th order butterworth filter
FilterFM = filtfilt(num,den,TrialData.ForceM); %Filter ForceM

% fc = 50; %cutoff Hz
% fs = 2000; %sampling Hz
% Wn = fc/(fs/2);%normalised cutoff Hz
% [num,den] = butter(4,Wn); %4th order butterworth filter
FilterAX = filtfilt(num,den,TrialData.RawAccelX); %Filter AccelM

% figure(6)
% clf
% subplot(2,1,1); 
% hold on
% pspectrum(TrialData.ForceM,TrialData.Time);
% pspectrum(FilterFM,TrialData.Time); 
% legend("|Force|","|Force| (LowPass Cut-Off 100Hz)");
% 
% subplot(2,1,2); 
% hold on
% pspectrum(TrialData.AccelX,TrialData.Time);
% pspectrum(FilterAX,TrialData.Time); 
% legend("Acceleration X","Acceleration X (LowPass Cut-Off 50Hz)");

%%
% figure(7)
% clf
% hold on
% 
% yyaxis left
% plot(TrialData.Time,TrialData.ForceM,'b');
% %plot(TrialData.Time(LocalMaxesF),TrialData.ForceM(LocalMaxesF),'kd');
% plot(TrialData.Time,FilterFM,'k--');
% ylabel('Force (N)')
% 
% yyaxis right
% plot(TrialData.Time,TrialData.AccelX,'r');
% %plot(TrialData.Time(LocalMaxesA),TrialData.AccelX(LocalMaxesA),'ko');
% plot(TrialData.Time,FilterAX,'k--');
% ylabel('Acceleration (g)')
% 
% xlabel('Time (s)')
% legend("|Force|","Filtered |Force|","Acceleration X","Filtered AccX")
% sgtitle("Run, Left Ankle")

%%
MaxForceNoFi = max(TrialData.ForceM)
MaxForceFilt = max(FilterFM)
MaxAccelNoFi = max(abs(TrialData.RawAccelX))
MaxAccelFilt = max(abs(FilterAX))

saveit = [saveit;[...
(MaxForceFilt-MaxForceNoFi)/MaxForceNoFi*100,...
(MaxAccelFilt-MaxAccelNoFi)/MaxAccelNoFi*100]];

"";

