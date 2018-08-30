%% import data
mvcpfdata = load('Patient56_MVC_PF.txt');
mvcdfdata = load('Patient56_MVC_DF.txt');

vrdata = load('PatNo56_VR_AnklePosNeutral_DFPF_Trial8.txt');

% initialize constants
serial2NmBipolar = 125/2048*4.448*.15;
serial2NmUnipolar = 0;
percentmvc = 0.20;
%%
refchan = 2;
measchan = 1;

mvcpfmeas = mvcpfdata(:,measchan);
mvcdfmeas = mvcdfdata(:,measchan);

% rest1         0 - 5s
% mvc1          5 - 10s 
% rest2         10 - 25s
% mvc2          25 - 30s
% rest3         30 - 45s
% mvc3          45 - 50s

%split into sections --- Plantarflexion
mvcpf3 = mvcpfmeas(end-5000: end);
restpf3 = mvcpfmeas(end-20000: end - 5000);
mvcpf2 = mvcpfmeas(end - 25000: end - 20000);
restpf2 = mvcpfmeas(end - 40000: end - 25000);
mvcpf1 = mvcpfmeas(end - 45000: end - 40000);
restpf1 = mvcpfmeas(1: end - 45000);

% cut off ends of data
mvcpf3 = mvcpf3(500: end-500);
mvcpf2 = mvcpf2(500: end-500);
mvcpf1 = mvcpf1(500: end-500);
restpf3 = restpf3(500:end-500);
restpf2 = restpf2(500:end-500);
restpf1 = restpf1(500:end-500);

zero3 = mean(restpf3);
zero2 = mean(restpf2);
zero1 = mean(restpf1);
mvcpf3val = min(mvcpf3) - zero3;
mvcpf2val = min(mvcpf2) - zero2;
mvcpf1val = min(mvcpf1) - zero1;


%split into sections --- Dorsiflexion
mvcdf3 = mvcdfmeas(end-5000: end);
restdf3 = mvcdfmeas(end-20000: end - 5000);
mvcdf2 = mvcdfmeas(end - 25000: end - 20000);
restdf2 = mvcdfmeas(end - 40000: end - 25000);
mvcdf1 = mvcdfmeas(end - 45000: end - 40000);
restdf1 = mvcdfmeas(1: end - 45000);

% cut off ends of data
mvcdf3 = mvcdf3(500: end-500);
mvcdf2 = mvcdf2(500: end-500);
mvcdf1 = mvcdf1(500: end-500);
restdf3 = restdf3(500:end-500);
restdf2 = restdf2(500:end-500);
restdf1 = restdf1(500:end-500);

zero3 = mean(restdf3);
zero2 = mean(restdf2);
zero1 = mean(restdf1);
mvcdf3val = max(mvcdf3) - zero3;
mvcdf2val = max(mvcdf2) - zero2;
mvcdf1val = max(mvcdf1) - zero1;

% mvc values
mvcpfval = min([mvcpf3val, mvcpf2val, mvcpf1val])*serial2NmBipolar;
mvcdfval = max([mvcdf3val, mvcdf2val, mvcdf1val])*serial2NmBipolar;

%% Voluntary Reflex Analysis
[rows,cols] = size(vrdata);
vrtrialdata = vrdata(rows-60000:rows, 1:cols);
vrrestdata = vrdata(1:rows-60000, 1:cols);

% calculate zero
vrrestmeas = vrrestdata(:,measchan);
vrzero = mean(vrrestmeas);

% get trial data
vrtrialref = vrtrialdata(:,refchan);
vrtrialmeas = (vrtrialdata(:, measchan) - vrzero)*serial2NmBipolar;

% dorsi-plantarflexion trial
dfpfmvc = mean([abs(mvcdfval),abs(mvcpfval)]);

% PRBS signal so "filter" it
vrtrialreffiltered = zeros(size(vrtrialref));
for i = 1:length(vrtrialref)
    if vrtrialref(i) < 2048
        vrtrialreffiltered(i) = -percentmvc*dfpfmvc;
    else
        vrtrialreffiltered(i) = percentmvc*dfpfmvc;
    end
end

t = [0:length(vrtrialmeas)-1]*0.001;

figure(1)
hold on
plot(t, vrtrialmeas);
plot(t, vrtrialreffiltered);
title('PRBS - Dorsiflexion-Plantarflexion Tsw = 750ms');
xlabel('Time (s)');
ylabel('Torque (Nm)');
hold off

%%
vrmeascropped = vrtrialmeas(2500:end);
vrrefcropped = vrtrialreffiltered(2500:end);






