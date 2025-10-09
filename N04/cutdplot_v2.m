clc
clear all
close all

% Loop untuk setiap sesi
for session=1:8
    fileExcel=strcat('S',num2str(session),'.xlsx');
    fileEdf=['ICA.edf']; % Pastikan nama file EDF ini benar
    
    % Baca data EEG dan file Excel
    [header,data] = edfread(fileEdf);
    [num, txt, raw] = xlsread(fileExcel,1);
    
    % AMBIL SAMPLING FREQUENCY (Fs) DARI HEADER
    % Penting! Cek struktur 'header' Anda. Mungkin namanya 'header.Fs' atau
    % 'header.samplerate(1)' atau 'header.frequency(1)'. Sesuaikan jika perlu.
    % Fs = header.samplerate(100);
    Fs = 100;
    
    % Ekstrak informasi dari Excel
    startTimeAll=num(:,6);
    stopTimeAll=num(:,7);
    sall=num(:,9);
    resp=num(:,1);
    
    counterSlow=0;
    counterFast=0;
    
    % Loop untuk setiap kata/trial
    for kata = 1:60
        statAll = sall(kata);
        
        if statAll == 1
            %==================================================================
            % BAGIAN 1: PROSES PEMOTONGAN SINYAL (Kode Anda yang sudah ada)
            %==================================================================
            startTime = floor(startTimeAll(kata) * Fs); % Dikalikan Fs
            stopTime = ceil(stopTimeAll(kata) * Fs);   % Dikalikan Fs
            
            % Pastikan stopTime tidak melebihi panjang data
            if stopTime > size(data, 2)
                stopTime = size(data, 2);
            end

            dataPotong = data(:, startTime:stopTime);
            dataOlah=dataPotong(1:16,:); % Ambil 16 channel pertama
            jmlChannel=size(dataOlah,1);
            
            %==================================================================
            % BAGIAN 2: ANALISIS & PLOTTING 2D (Kode Anda yang sudah ada)
            %==================================================================
            pow = zeros(1, jmlChannel);
            for k = 1:jmlChannel
                dataN = dataOlah(k,:);
                power_timedomain = sum(abs(dataN).^2)/length(dataN);
                pow(k) = 10*log10(power_timedomain/2);
            end
            
            [Norm_pow] = Normalization(pow);
            
            % Menentukan nama file berdasarkan respons
            if resp(kata) < 0.5
                filename_2D = strcat('2D_N04_',fileExcel(1:2),'_W',num2str(kata),'_F.png');
                counterFast=counterFast+1;
            else
                filename_2D = strcat('2D_N04_',fileExcel(1:2),'_W',num2str(kata),'_S.png');
                counterSlow=counterSlow+1;
            end
            
            % Membuat dan menyimpan topoplot
            fig1 = figure('Visible', 'off'); % Buat figure tanpa menampilkannya
            topoplot(Norm_pow, 'eloc16.loc','colormap',flipud(hot), 'electrodes','ptslabels');
            title(sprintf('2D Non ERP - Session %d Word %d', session, kata))
            caxis([min(Norm_pow) max(Norm_pow)]);
            cb = colorbar;
            ylabel(cb, 'Normalization Power (Low to High)');
            saveas(fig1, filename_2D);
            close(fig1); % Tutup figure setelah disimpan
            
            disp(['Gambar 2D untuk iterasi ke-', num2str(kata), ' telah disimpan.']);
            
            %==================================================================
            % BAGIAN 3: ANALISIS & PLOTTING 1D (KODE BARU)
            %==================================================================
            
            % Pilih satu channel untuk dianalisis sinyal 1D-nya. Misal channel 1.
            % Anda bisa mengubah angka ini (misal: 3 untuk channel ke-3).
            channel_to_analyze = 1; 
            signal_1D = dataOlah(channel_to_analyze, :);
            
            % ### PERBAIKAN BARU: CEK PANJANG SINYAL ###
            % Filter membutuhkan data yang lebih panjang dari 3 * (orde filter), 
            % error menunjukkan butuh lebih dari 24 sampel.
            if length(signal_1D) > 24
                
                % Definisikan rentang frekuensi yang VALID untuk Fs = 100 Hz
                delta_band = [0.5 4];
                theta_band = [4 8];
                alpha_band = [8 13];
                beta_band  = [13 30];
                gamma_band = [30 49]; 
                
                % Buat filter untuk setiap band
                [b_delta, a_delta] = butter(4, delta_band/(Fs/2), 'bandpass');
                [b_theta, a_theta] = butter(4, theta_band/(Fs/2), 'bandpass');
                [b_alpha, a_alpha] = butter(4, alpha_band/(Fs/2), 'bandpass');
                [b_beta,  a_beta]  = butter(4, beta_band/(Fs/2),  'bandpass');
                [b_gamma, a_gamma] = butter(4, gamma_band/(Fs/2), 'bandpass');
                
                % Terapkan filter
                signal_delta = filtfilt(b_delta, a_delta, signal_1D);
                signal_theta = filtfilt(b_theta, a_theta, signal_1D);
                signal_alpha = filtfilt(b_alpha, a_alpha, signal_1D);
                signal_beta  = filtfilt(b_beta,  a_beta,  signal_1D);
                signal_gamma = filtfilt(b_gamma, a_gamma, signal_1D);
                
                time_axis = (0:length(signal_1D)-1) / Fs;
                
                % Membuat dan menyimpan plot 1D dalam subplot
                fig2 = figure('Visible', 'off', 'Position', [100, 100, 900, 1200]);
                
                subplot(5,1,1); plot(time_axis, signal_delta); title('Delta (0.5-4 Hz)'); ylabel('Amplitude (\muV)'); grid on;
                subplot(5,1,2); plot(time_axis, signal_theta); title('Theta (4-8 Hz)'); ylabel('Amplitude (\muV)'); grid on;
                subplot(5,1,3); plot(time_axis, signal_alpha); title('Alpha (8-13 Hz)'); ylabel('Amplitude (\muV)'); grid on;
                subplot(5,1,4); plot(time_axis, signal_beta); title('Beta (13-30 Hz)'); ylabel('Amplitude (\muV)'); grid on;
                subplot(5,1,5); plot(time_axis, signal_gamma); title('Gamma (30-49 Hz)'); ylabel('Amplitude (\muV)'); xlabel('Time (s)'); grid on;
                
                sgtitle(strcat('EEG Signal Analysis - Session: ', num2str(session), ', Word: ', num2str(kata)));
                
                if resp(kata) < 0.5
                    filename_1D = strcat('1D_N04_',fileExcel(1:2),'_W',num2str(kata),'_F.png');
                else
                    filename_1D = strcat('1D_N04_',fileExcel(1:2),'_W',num2str(kata),'_S.png');
                end
                
                saveas(fig2, filename_1D);
                close(fig2);
                
                disp(['Gambar 1D untuk iterasi ke-', num2str(kata), ' telah disimpan.']);
            
            else
                % Jika data terlalu pendek, beri peringatan dan lewati proses 1D
                disp(['Peringatan: Iterasi ke-', num2str(kata), ' dilewati untuk plot 1D karena data terlalu pendek (', num2str(length(signal_1D)), ' sampel).']);
            end
        end
    end
    disp(['Jumlah Data Fast: ', num2str(counterFast)]);
    disp(['Jumlah Data Slow: ', num2str(counterSlow)]);
end

disp('PROSES SELESAI.');

% Jangan lupa untuk membuat fungsi Normalization.m jika belum ada
% function [output] = Normalization(input)
%     minVal = min(input);
%     maxVal = max(input);
%     output = (input - minVal) / (maxVal - minVal);
% end