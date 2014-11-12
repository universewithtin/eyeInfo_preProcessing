function eyeInfo = dg_read_eyeInfo(dfzFilePath)
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
% (1) an optional input of map of the channel
% ------
% Code Info:
%   creation: 2014-11-11 by ShS -> shervin.safavi@gmail.com
%   modification:
%       $ 201?

cd L:\projects\shervin\data\QNXdataFiles\H07\BFS_iViewData\Hayo_20141111_bfsnatur1.dgz

rawData = dg_read(dfzFilePath);



for i = 1:length(data.e_types)
    
    
    
    if find(data.e_types{i}==42)
        
        
        
        
        
        get pupil trace (data.ems{350}{5})
        
        get eye trace (x and y)
        
        get fix spot on time (25)
        
        calculate fixation on time (stim on(28) - 300)
        
        get stim on time (first 28)
        
        get mask on time (second 28)
        
        get mask off time (last 28)
        
        get fix off time
        
        
        
    end
    
    
    
end



averages

plot    - relative to stim on

- relative to mask on

- relative to fixation on



remove 1-2 seconds of the data after mask on



go until the end of the trials



represent each trace by the z score

find every instance when the z score changes by 1 std

detect it as an event

for both physical alternation and flash suppresion trials
    
    
    
    plot the interevent distributions.
    
    
    
    
    
    
    
    
    
    0 (polar)  70 (contrast)  0 (in which eye,0 left, 1 right)    0 (flash, 1 physical)    70 (contrast)
    
    
    
    [data.e_params{530}{6} data.e_params{531}{6} data.e_params{532}{6} data.e_params{533}{6} data.e_params{534}{6}]
end


%% draft


