%% load the datasets
dataPath = 'L:/projects/shervin/data/QNXdataFiles/H07/BFS_iViewData/Anton_20141227_bfsgrad_deg_UpDown_NKLspeed.dgz';
[eyeInfo, experimentInfo] = dg_read_eyeInfo(dataPath);

for iTr = 1 : experimentInfo.n.Trials
    fixON = round(eyeInfo.times.fixStart(iTr)/5);
    maskOFF = round(eyeInfo.times.maskOFF(iTr)/5);
    tmpPD = eyeInfo.pupilSizeTimeSeries{iTr}(fixON : maskOFF);
    tmpECX = eyeInfo.XcoordinateTimeSeries{iTr}(fixON : maskOFF);
    tmpECY = eyeInfo.YcoordinateTimeSeries{iTr}(fixON : maskOFF);
    
    PDlength(iTr) = numel(tmpPD);
    ECXlength(iTr) = numel(tmpECX);
    ECXlength(iTr) = numel(tmpECY);
    
    rawPDlength(iTr) = numel(eyeInfo.pupilSizeTimeSeries{iTr});
    rawECXlength(iTr) = numel(eyeInfo.XcoordinateTimeSeries{iTr});
    rawECYlength(iTr) = numel(eyeInfo.YcoordinateTimeSeries{iTr});
end


plot(rawECXlength*5, rawECYlength*5, '.')

rawECYlength(rawECYlength ~= rawPDlength) - rawPDlength(rawECYlength ~= rawPDlength)

