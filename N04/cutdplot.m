clc
clear all
close all



%     fileExcel=['S',num2str(responden),'.xlsx'];
for session=1:8
    fileExcel=strcat('S',num2str(session),'.xlsx')
    % fileExcel=['S4.xlsx'];
    fileEdf=['ICA.edf'];
    [header,data] = edfread(fileEdf);
    
    [num, txt, raw] = xlsread(fileExcel,1);
    
    startTimeAll=num(:,6);
    stopTimeAll=num(:,7);
    sall=num(:,9);
    resp=num(:,1);
    counterSlow=0;
    counterFast=0;
    for kata = 1:60
        statAll= sall(kata);
        if statAll == 1
            startTime = floor(startTimeAll(kata) * 100);
            stopTime = ceil(stopTimeAll(kata) * 100);
            dataPotong = data(:, startTime:stopTime);
            %                 save(['dataPotong_', num2str(kata)], 'dataPotong');
            dataPlt=dataPotong;
            dataOlah=dataPlt(1:16,:);                                                      % cuma mau load 16 channel dari 23 channel yg ada
            jmlChannel=size(dataOlah,1);                                                % menampung jumlah channel yg akan di proses
            
            for k = 1:jmlChannel
                dataN=dataPlt(k,:);                                                        % ambil data tiap channel
                power_timedomain = sum(abs(dataN).^2)/length(dataN);                    % menghitung Energi dari sinyal EEG
                pow(k) = 10*log10(power_timedomain/2);
            end
            
            [Norm_pow] = Normalization(pow);                                            % proses normalisasi nilai power, disini di set dari 0-1
            if resp (kata)<0.5
                filename=strcat('N04_',fileExcel(1:2),'_W',num2str(kata),'_F.png');
                counterFast=counterFast+1;
            elseif resp (kata)>=0.5
                filename=strcat('N04_',fileExcel(1:2),'_W',num2str(kata),'_S.png');
                counterSlow=counterSlow+1;
            end
            %
            figure(1)
            topoplot(Norm_pow, 'eloc16.loc','colormap',flipud(hot), 'electrodes','ptslabels');     % memanggil fungsi topoplot
            caxis([min(Norm_pow) max(Norm_pow)])
            
            saveas(gcf,filename);
            disp(['Data pada iterasi ke-', num2str(kata), ' telah disimpan.']);
        else
        end
    end
    disp(['Jumlah Data Fast', num2str(counterFast)]);
    disp(['Jumlah Data Slow', num2str(counterSlow)]);
end
    
