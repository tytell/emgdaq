%% Initial parameters

%input recording parameters
inputrate = 5000;       % Hz
inputdur = 2;           % sec

%stimulus parameters
stimfreq = 20;      %Hz
pulsedur = 0.001;   %sec
stimdur = 1;        %sec
stimdelay = 0.5;    %sec. Initial delay before stimulus starts

%camera parameters
fps = 50;           %frames per second
exposure = 0.01;    %exposure time in sec

%data file
datafilename = 'test001.mat';

%% Set up analog input
sin = daq.createSession('ni');
ch = sin.addAnalogInputChannel('Dev1', 0, 'Voltage');
ch.Name = 'test1';
%add more channels here
ch = sin.addAnalogInputChannel('Dev1', 5, 'Voltage');
ch.Name = 'stim';
ch = sin.addAnalogInputChannel('Dev1', 6, 'Voltage');
ch.Name = 'expcmd';

sin.Rate = inputrate;
sin.DurationInSeconds = inputdur;

%% Set up stimulus counter output
sout = daq.createSession('ni');
sout.DurationInSeconds = stimdur + stimdelay;

pulseduty = pulsedur * stimfreq;

ch = sout.addCounterOutputChannel('Dev1', 0, 'PulseGeneration');
ch.Frequency = stimfreq;
ch.DutyCycle = pulseduty;
ch.InitialDelay = stimdelay;

%% And camera exposure counter output
scam = daq.createSession('ni');
scam.DurationInSeconds = inputdur;
camduty = exposure * fps;

ch = scam.addCounterOutputChannel('Dev1', 1, 'PulseGeneration');
ch.Frequency = fps;
ch.DutyCycle = camduty;
ch.InitialDelay = 0.2;      % brief delay so that we can record exposure times

%% Set listener to display data while we're running
lh = set_daq_display(sin);

%% Start everything
scam.startBackground;
sout.startBackground;
[data,t] = sin.startForeground;
delete(lh);

%% Save data
save_data_and_script(mfilename('fullpath'),datafilename);

