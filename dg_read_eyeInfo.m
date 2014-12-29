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
%   creation: 2014-11-11 by ShS (shervin.safavi@gmail.com) and Vishal Kapoor 
%   modification:
%       $ 2014-11-29 add fixation time in the output structure 
%       $ 2014-12-20 add stim info  in the output structure 

%% 
preStimFixationPeriod = 300; % in ms
%%
rawData = dg_read(dfzFilePath);
n.MixedTrials = numel(rawData.ems); 
% mixed trials refer to combination of correct/successful and faild trials

correctTrialCounter = 0;
pa_trialCounter = 0;
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
        eyeInfo.times.fixStart(correctTrialCounter) = rawData.e_times{iMixTr}(tmp_patternOnIndex(1)) - preStimFixationPeriod;
        eyeInfo.times.stimON(correctTrialCounter) = rawData.e_times{iMixTr}(tmp_patternOnIndex(1));
        eyeInfo.times.maskON(correctTrialCounter) = rawData.e_times{iMixTr}(tmp_patternOnIndex(2));
        eyeInfo.times.maskOFF(correctTrialCounter) = rawData.e_times{iMixTr}(tmp_patternOnIndex(3));
%         eyeInfo.times.stimON{correctTrialCounter} = ...
%             rawData.e_times{iMixTr}(rawData.e_types{iMixTr} == 28);
%     eyeInfo.times.spotON{correctTrialCounter} = ...
%             eyeInfo.times.stimON - preStimFicationPeriod;  

        % stim type (e.g. orientation of grating)
        experimentInfo.stimInfo(iMixTr) = rawData.e_params{iMixTr}{6}(1);
                
        % condition
        if  rawData.e_params{iMixTr}{6}(4)
            pa_trialCounter = pa_trialCounter + 1;
            experimentInfo.condition.physicalAlternation(pa_trialCounter) = correctTrialCounter;
        else
            bfs_trialCounter = bfs_trialCounter + 1;
            experimentInfo.condition.bfs(bfs_trialCounter) = correctTrialCounter;
        end
    end
end

experimentInfo.n.Trials = correctTrialCounter;
experimentInfo.n.physicalAlternation = pa_trialCounter;
experimentInfo.n.bfs = bfs_trialCounter;

%%
%  iMixTr = 183
% [rawData.e_times{iMixTr} rawData.e_types{iMixTr} rawData.e_subtypes{iMixTr}]
%         tmp_patternOnIndex = find(rawData.e_types{iMixTr} == 28);
%         eyeInfo.times.stimON = rawData.e_times{iMixTr}(tmp_patternOnIndex(1));
%         eyeInfo.times.maskON = rawData.e_times{iMixTr}(tmp_patternOnIndex(2));
%         eyeInfo.times.maskOFF = rawData.e_times{iMixTr}(tmp_patternOnIndex(3));
%         eyeInfo.times.maskOFF - eyeInfo.times.maskON



