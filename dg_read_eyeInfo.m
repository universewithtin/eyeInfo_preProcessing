function [eyeInfo, experimentInfo] = dg_read_eyeInfo(dgzFilePath)
% [eyeInfo, experimentInfo] = dg_read_eyeInfo(dgzFilePath)
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
% (2)*  you can either pass 'poi' or 'conditions'
% (2a)  poi:
% (2b)  conditions:
%
% Output:
% 1     eyeInfo: strucure
% 2     experimentInfo: strucure
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
% (4) add length of all trials in the output
% (5a) ask POI from the user (as an optional input) to assign condition labels to tials (see 'labeling the trials')
% (5b) ask the conditions matrix  from the user (as an optional input) ...
% (5c) ask the text/short name for all conditions (as an optional input)
% for more informative visualization
% (6) check all the trials get a label i.e. is there any of the
% experimentInfo.trialLabel which is NaN. if this is the case send warning
% and the trial number to user
% (7) if trials does have some period (e.g. BFS repeaded each 8 trial). you
% need to check if they are repeated in each block. To check it fo through
% each block (e.g. 8 by 8 trials) and see 'unique' of the block is equal
% the number of trials needs to be in that trial or not. if this is the case send warning
% and the trial number(s) to user
% ------
% Code Info:
%   creation: 2014-11-11 by ShS (shervin.safavi@gmail.com)
%   modification:
%       $ 2014-11-29 add fixation time in the output structure
%       $ 2014-12-20 add stim info  in the output structure
%       $ 2015-02-27 add a condtion label (e.g. out of 8 for our common BFS) according the
%       order of stimulation, BR/BFS etc
%       $ 2015-04-30 add differnet case according to 'QNXcodeName', this
%       information extracted automatically from the DGZ file
%       $ 2015-04-30 generating condition explnation within the code

%% read the raw data
rawData = dg_read(dgzFilePath);
% this location of DGZ file information about QNX code has beend encoded;
% at least for the QNX codes that used so far
QNXcodeName = rawData.e_pre{1}{2};

switch QNXcodeName
    %% bfsmultgrad
    case {'bfsmultgrad', 'Bfsmultgrad'}
        %%
        preStimFixationPeriod = str2num(rawData.e_pre{21}{2}); % in ms (this number is uaually 300ms)
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
                % *** can be removed
                experimentInfo.stimInfo(iMixTr) = rawData.e_params{iMixTr}{6}(1);
                
                % condition
                % *** can be removed
                if  rawData.e_params{iMixTr}{6}(4)
                    pa_trialCounter = pa_trialCounter + 1;
                    experimentInfo.condition.physicalAlternation(pa_trialCounter) = correctTrialCounter;
                else
                    bfs_trialCounter = bfs_trialCounter + 1;
                    experimentInfo.condition.bfs(bfs_trialCounter) = correctTrialCounter;
                end
                
                % trial info
                experimentInfo.trialInfo(correctTrialCounter, :) = rawData.e_params{iMixTr}{6}';
                experimentInfo.trialLength(correctTrialCounter, 1) = numel(rawData.ems{iMixTr}{5}); % based on PD
                
                %         % stim: what is stim (polar, grating etc)
                %         experimentInfo.trialInfo(correctTrialCounter, 1) = rawData.e_params{iMixTr}{6}(1);
                %         % eye: in which eye presented, 0 left, 1 right
                %         experimentInfo.trialInfo(correctTrialCounter, 1) = rawData.e_params{iMixTr}{6}(1);
                %         % contrast 1
                %         experimentInfo.trialInfo(correctTrialCounter, 2) = rawData.e_params{iMixTr}{6}(1);
            end
        end
        
        %% n
        experimentInfo.n.Trials = correctTrialCounter;
        experimentInfo.n.physicalAlternation = pa_trialCounter;
        experimentInfo.n.bfs = bfs_trialCounter;
        
        %% labeling the trials
        % if no specific part of e_params is specified by user as th Paramater of
        % Interest (POI), then the it automatically include all the possible conditions
        % (need to be completed later)
        
        % if user specified the POI, then it only assign the conditions accordingly
        poi = [1 3 4];
        % 1-> stim: what is stim (polar or not, orientation of grating etc)
        % 3-> eye: in which eye presented, 0 left, 1 right
        % 4-> PA/BFS: 0 BFS, 1 PA
        for iParam = 1 : numel(poi)
            param{iParam} = unique(experimentInfo.trialInfo(:, poi(iParam)));
        end
        
        % param{1} = unique(experimentInfo.trialInfo(:, poi(1)));
        % param{2} = unique(experimentInfo.trialInfo(:, poi(2)));
        % param{3} = unique(experimentInfo.trialInfo(:, poi(3)));
        
        % generating the condition
        % check if the user already pass the conditions, if not then generate them:
        conditions = (combvec(param{1}', param{2}', param{3}'))';
        % transpose it just because 'intuitively' make more sense
        experimentInfo.allConditions = conditions;
        
        
        % ~memory allocation
        experimentInfo.trialLabel = nan(experimentInfo.n.Trials, 1);
        
        for iCond = 1 : size(conditions,1)
            % here I'm finding each trial belogs to which condition.
            % this solution might sound more complicated than what you expect (e.g.
            % use find(...)), but its faster AND automated, depend on how you gonna
            % define the contion doen't need any modification
            for iPOI = 1 : numel(poi)
                tmp_condLogicalPOI(:, iPOI) = experimentInfo.trialInfo(:, poi(iPOI)) == conditions(iCond, iPOI);
            end
            % about tmp_condSatisfactionScore: it says how many of the POI [defined by iCond] is stasitified in each trial
            tmp_iCondSatisfactionScore = sum(tmp_condLogicalPOI, 2);
            % any trial which satisfy all (i.e. numel(poi)) the requirment on POIs
            % defined by condtion i  belong to that condtion
            experimentInfo.trialLabel(tmp_iCondSatisfactionScore == numel(poi)) = iCond;
        end
        
        %% generating understtanabale explanation about contions
        % *** this could have been implemetned in the previous for loop if
        % it's going to be faster. For sake of clarity I separated them
        % *** should such info asked as the input
        for iCond = 1 : size(conditions,1)
            
            %
            tmp_condExp{3} = num2str(conditions(iCond, 1));
            
            % right or left eye?
            if conditions(iCond, 2)
                tmp_condExp{2} = 'Start with Right Eye ';
            else
                tmp_condExp{2} = 'Start with Left Eye ';
            end
            
            % BFS or PA?
            if conditions(iCond, 3)
                tmp_condExp{1} = 'PA: ';
            else
                tmp_condExp{1} = 'BFS: ';
            end
            condExplnation{iCond} = cell2mat(tmp_condExp);
            
        end
        experimentInfo.condExplnation = condExplnation;
        
        
                               
    case 'bfsgrad_deg'
        % hard coded values
        % the cell of e_param which contain the stim info (for DGZ file generated by 'bfsgrad_deg')
        stimInfoCellNum = 4;      

        %% addresses in field 'e_params' for extrating the relevent tial info
        cellAdrs.stim1 = 1; % which here indicate the orientation
        cellAdrs.stim2 = 2; % which here indicate the orientation
        
        cellAdrs.contrast1 = 3; 
        cellAdrs.contrast2 = 6;
        
        cellAdrs.isRightEye = 4; % was stim presented to the right eye?
        cellAdrs.isBFS = 5; % was a BFS trial
        % maybe later one should add stuff related to speed and so on        
        
        %% parameters should be extracted from of DGZ file
        preStimFixationPeriod = str2num(rawData.e_pre{21}{2}); % in ms (this number is uaually 300ms)
        n.MixedTrials = numel(rawData.ems);
        % mixed trials refer to combination of correct/successful and faild trials
        
        %% trial counterS
        correctTrialCounter = 0;
        pa_trialCounter = 0;
        bfs_trialCounter = 0;
        
        %% run through all trials (i.e. correct/successful and faild trials)
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
                tmp_patternOnIndex = find(rawData.e_types{iMixTr} == 28);
                eyeInfo.times.fixStart(correctTrialCounter) = rawData.e_times{iMixTr}(tmp_patternOnIndex(1)) - preStimFixationPeriod;
                eyeInfo.times.stimON(correctTrialCounter) = rawData.e_times{iMixTr}(tmp_patternOnIndex(1));
                eyeInfo.times.maskON(correctTrialCounter) = rawData.e_times{iMixTr}(tmp_patternOnIndex(2));
                eyeInfo.times.maskOFF(correctTrialCounter) = rawData.e_times{iMixTr}(tmp_patternOnIndex(3));
                                                
                %% extract stim info
                % as the field e_params contain stim parameters is easier to have
                % them in numerical format (which is not in the case of 'bfsgrad_deg')
                rawData.e_params{iMixTr}{stimInfoCellNum} = str2num(rawData.e_params{iMixTr}{stimInfoCellNum})';
                
                % stim type (e.g. orientation of grating)
                % *** can be removed
                experimentInfo.stimInfo(iMixTr) = rawData.e_params{iMixTr}{stimInfoCellNum}(1);
                
                %% extract condition info
                % *** can be removed
                if  rawData.e_params{iMixTr}{stimInfoCellNum}(cellAdrs.isBFS)
                    pa_trialCounter = pa_trialCounter + 1;
                    experimentInfo.condition.physicalAlternation(pa_trialCounter) = correctTrialCounter;
                else
                    bfs_trialCounter = bfs_trialCounter + 1;
                    experimentInfo.condition.bfs(bfs_trialCounter) = correctTrialCounter;
                end
                
                % trial info
                experimentInfo.trialInfo(correctTrialCounter, :) = rawData.e_params{iMixTr}{stimInfoCellNum}';
                experimentInfo.trialLength(correctTrialCounter, 1) = numel(rawData.ems{iMixTr}{5}); % based on PD
                
                %         % stim: what is stim (polar, grating etc)
                %         experimentInfo.trialInfo(correctTrialCounter, 1) = rawData.e_params{iMixTr}{6}(1);
                %         % eye: in which eye presented, 0 left, 1 right
                %         experimentInfo.trialInfo(correctTrialCounter, 1) = rawData.e_params{iMixTr}{6}(1);
                %         % contrast 1
                %         experimentInfo.trialInfo(correctTrialCounter, 2) = rawData.e_params{iMixTr}{6}(1);
            end
        end
        
        %% n
        experimentInfo.n.Trials = correctTrialCounter;
        experimentInfo.n.physicalAlternation = pa_trialCounter;
        experimentInfo.n.bfs = bfs_trialCounter;
        
        %% labeling the trials
        % if no specific part of e_params is specified by user as th Paramater of
        % Interest (POI), then the it automatically include all the possible conditions
        % (need to be completed later)
        
        % if user specified the POI, then it only assign the conditions accordingly
        poi = [1 4 5];
        % 1-> stim: what is stim (polar or not, orientation of grating etc)
        % 3-> eye: in which eye presented, 0 left, 1 right
        % 4-> PA/BFS: 0 BFS, 1 PA
        for iParam = 1 : numel(poi)
            param{iParam} = unique(experimentInfo.trialInfo(:, poi(iParam)));
        end
        
        % generating the condition
        % check if the user already pass the conditions, if not then generate them:
        conditions = (combvec(param{1}', param{2}', param{3}'))';
        % transpose the 'conditions' just because 'intuitively' make more sense
        % *** this is not the ultimate automatic solution, since you need
        % to manually indivat 1, 2, 3. Oherwise we make the argument of
        % combvec and then pass it to combvec
        % what you might can do for that is, make a function cell2sepVar which
        % convert the cell array into seperate variables
        experimentInfo.allConditions = conditions;
        
        
        % ~memory allocation
        experimentInfo.trialLabel = nan(experimentInfo.n.Trials, 1);
        
        for iCond = 1 : size(conditions,1)
            % here I'm finding each trial belogs to which condition.
            % this solution might sound more complicated than what you expect (e.g.
            % use find(...)), but its faster AND automated, depend on how you gonna
            % define the contion doen't need any modification
            for iPOI = 1 : numel(poi)
                tmp_condLogicalPOI(:, iPOI) = experimentInfo.trialInfo(:, poi(iPOI)) == conditions(iCond, iPOI);
            end
            % about tmp_condSatisfactionScore: it says how many of the POI [defined by iCond] is stasitified in each trial
            tmp_iCondSatisfactionScore = sum(tmp_condLogicalPOI, 2);
            % any trial which satisfy all (i.e. numel(poi)) the requirment on POIs
            % defined by condtion i  belong to that condtion
            experimentInfo.trialLabel(tmp_iCondSatisfactionScore == numel(poi)) = iCond;
        end
        
        %% generating understtanabale explanation about contions 
        % *** this could have been implemetned in the previous for loop if
        % it's going to be faster. For sake of clarity I separated them
        % *** should such info asked as the input
        for iCond = 1 : size(conditions,1)
            
            % 
            tmp_condExp{3} = num2str(conditions(iCond, 1));
            
            % right or left eye?
            if conditions(iCond, 2)
                tmp_condExp{2} = 'Start with Right Eye ';
            else
                tmp_condExp{2} = 'Start with Left Eye ';
            end
            
            % BFS or PA?
            if conditions(iCond, 3)
                tmp_condExp{1} = 'PA: ';
            else
                tmp_condExp{1} = 'BFS: ';
            end
            condExplnation{iCond} = cell2mat(tmp_condExp);
            
        end
        experimentInfo.condExplnation = condExplnation;
    otherwise
        disp('Probably you need to add a new case for your behavioural paradigm according the QNX code that you are using \n or you need to check what is stored in DGZ file field e_pre')
end
%%
%  iMixTr = 183
% [rawData.e_times{iMixTr} rawData.e_types{iMixTr} rawData.e_subtypes{iMixTr}]
%         tmp_patternOnIndex = find(rawData.e_types{iMixTr} == 28);
%         eyeInfo.times.stimON = rawData.e_times{iMixTr}(tmp_patternOnIndex(1));
%         eyeInfo.times.maskON = rawData.e_times{iMixTr}(tmp_patternOnIndex(2));
%         eyeInfo.times.maskOFF = rawData.e_times{iMixTr}(tmp_patternOnIndex(3));
%         eyeInfo.times.maskOFF - eyeInfo.times.maskON



