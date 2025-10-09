clc
clear all
close all


for responden=1:4
    fileExcel=['S',num2str(responden),'.xlsx'];
    fileEdf=['R',num2str(responden),'.edf'];
    [header,data] = edfread(fileEdf);

    for sesi=1:8
        sheet = sesi;
        [num, txt, raw] = xlsread(fileExcel,2);

        startTimeAll=num(:,6);
        stopTimeAll=num(:,7);
        for kata=1:60
            starTime=floor(startTimeAll(kata)*100);
            stopTime=ceil(stopTimeAll(kata)*100);
            dataPotong=data(:,[starTime:stopTime]);
            datFP1A1=data(1,:);
        end
    end
end
