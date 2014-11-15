function [eyeInfo, experimentInfo] = dg_read_eyeInfo(dfzFilePath)
% eyeInfo = dg_read_eyeInfo(dfzFilePath)
%
%
% EXAMPLE:
%
%
% ------
% Input:
% 1     dfzFilePath: string
%       e.g.
%       '\projects\shervin\data\QNXdataFiles\H07\BFS_iViewData\Hayo_20141111_bfsnatur1.dgz'
%
%
% Output:
% 1     eyeInfo: strucure
%
%
% ------
% see also DG_READ
% ------
% potential improvments:
% (1) file name stored in the strucure is 'dfzFilePath' which should be
% fixed somehow
% (2) should I add sampling rate somewhere
% (3) is the field of info properly chosen?
% e.g. X/YcoordinateTimeSeries?
% ------
% Code Info:
%   creation: 2014-11-11 by ShS -> shervin.safavi@gmail.com
%   modification:
%       $ 201?

%% 
preStimFicationPeriod = 300;
%%
rawData = dg_read(dfzFilePath);
n.MixedTrials = numel(rawData.ems); 
% mixed trials refer to combination of correct and faild trials


correctTrialCounter = 0;
phyA_trialCounter = 0;
bfs_trialCounter = 0;

for iMixTr = 1 : n.MixedTrials
    tmp_logicalIndex = (rawData.e_types{iMixTr} == 42);
    if sum(tmp_logicalIndex) > 0
        % if we had code number 42 (reward) means it was a correct trial as the
        % subject got the reward
        correctTrialCounter = correctTrialCounter + 1;
        correctTrialsIndices(correctTrialCounter) = iMixTr;
        %% extract eye info
        % time series
        eyeInfo.XcoordinateTimeSeries{correctTrialCounter} = rawData.ems{iMixTr}{2}; % X
        eyeInfo.YcoordinateTimeSeries{correctTrialCounter} = rawData.ems{iMixTr}{3}; % Y
        eyeInfo.pupilSizeTimeSeries{correctTrialCounter} = rawData.ems{iMixTr}{5}; % PD
        
        % times
%         eyeInfo.times.spotON(correctTrialCounter) = ...
%             rawData.e_times{iMixTr}(rawData.e_types{iMixTr} == 25);
        tmp_patternOnIndex = find(rawData.e_types{iMixTr} == 28);
        eyeInfo.times.stimON(correctTrialCounter) = rawData.e_times{iMixTr}(tmp_patternOnIndex(1));
        eyeInfo.times.maskON(correctTrialCounter) = rawData.e_times{iMixTr}(tmp_patternOnIndex(2));
        eyeInfo.times.maskOFF(correctTrialCounter) = rawData.e_times{iMixTr}(tmp_patternOnIndex(3));
%         eyeInfo.times.stimON{correctTrialCounter} = ...
%             rawData.e_times{iMixTr}(rawData.e_types{iMixTr} == 28);
%     eyeInfo.times.spotON{correctTrialCounter} = ...
%             eyeInfo.times.stimON - preStimFicationPeriod;  

        % condition
        if  rawData.e_params{iMixTr}{6}(4)
            phyA_trialCounter = phyA_trialCounter + 1;
            experimentInfo.condition.physicalAlternation(phyA_trialCounter) = correctTrialCounter;
        else
            bfs_trialCounter = bfs_trialCounter + 1;
            experimentInfo.condition.bfs(bfs_trialCounter) = correctTrialCounter;
        end
    end
end

experimentInfo.n.Trials = correctTrialCounter;
experimentInfo.n.physicalAlternation = phyA_trialCounter;
experimentInfo.n.bfs = bfs_trialCounter;

%%
%  iMixTr = 183
% [rawData.e_times{iMixTr} rawData.e_types{iMixTr} rawData.e_subtypes{iMixTr}]
%         tmp_patternOnIndex = find(rawData.e_types{iMixTr} == 28);
%         eyeInfo.times.stimON = rawData.e_times{iMixTr}(tmp_patternOnIndex(1));
%         eyeInfo.times.maskON = rawData.e_times{iMixTr}(tmp_patternOnIndex(2));
%         eyeInfo.times.maskOFF = rawData.e_times{iMixTr}(tmp_patternOnIndex(3));
%         eyeInfo.times.maskOFF - eyeInfo.times.maskON
%% algorithm 
% for i = 1:length(data.e_types)

%     if find(data.e_types{i}==42)        
%         
%         get mask on time (second 28)
%         
%         get mask off time (last 28)
%         
%         get fix off time
%         
%         
%         
%     end
%     
%     
%     
% end
% 
% 
% 
% averages
% 
% plot    - relative to stim on
% 
% - relative to mask on
% 
% - relative to fixation on
% 
% 
% 
% remove 1-2 seconds of the data after mask on
% 
% 
% 
% go until the end of the trials
% 
% 
% 
% represent each trace by the z score
% 
% find every instance when the z score changes by 1 std
% 
% detect it as an event
% 
% for both physical alternation and flash suppresion trials
%     
%     
%     
%     plot the interevent distributions.
%     
%     
%     
%     
%     
%     
%     
%     
%     
%     0 (polar)  70 (contrast)  0 (in which eye,0 left, 1 right)    0 (flash, 1 physical)    70 (contrast)
%     
%     
%     
%     [data.e_params{530}{6} data.e_params{531}{6} data.e_params{532}{6} data.e_params{533}{6} data.e_params{534}{6}]
% end
% 

%% draft



