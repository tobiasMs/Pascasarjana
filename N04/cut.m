clc
clear all
close all


for responden=1:4
%     fileExcel=['S',num2str(responden),'.xlsx'];
    fileExcel=['S8.xlsx'];
    fileEdf=['ICA.edf'];
    [header,data] = edfread(fileEdf);

    for sesi=1:8
        sheet = sesi;
        [num, txt, raw] = xlsread(fileExcel,1);

        startTimeAll=num(:,6);
        stopTimeAll=num(:,7);
        for kata=1:60
            starTime=floor(startTimeAll(1)*100);
            stopTime=ceil(stopTimeAll(60)*100);
            dataPotong=data(:,[starTime:stopTime]);
            real=dataPotong(1:16,:);
            avg=mean(real);
            data16=data(1:16,:);
        end
    end
end
