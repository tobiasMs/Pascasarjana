clc
clear all
close all

%==========================================================================
% PARAMETER PENTING UNTUK ANALISIS ERP
%==========================================================================
% Jendela waktu untuk setiap epoch (relatif terhadap stimulus)
epoch_start_time = -0.2; % dalam detik (-200 ms)
epoch_end_time   = 0.8; % dalam detik (+800 ms)

% Jendela waktu untuk baseline correction (harus sebelum stimulus, t=0)
baseline_window  = [-0.2, 0]; % dari -200 ms hingga 0 ms

% Jendela waktu untuk mengukur amplitudo N400
n400_window      = [0.35, 0.45]; % dari 350 ms hingga 450 ms

%==========================================================================

% Loop untuk setiap sesi
for session=1:8
    fileExcel=strcat('S',num2str(session),'.xlsx');
    fileEdf=['ICA.edf']; % Pastikan nama file EDF ini benar
    
    [header,data] = edfread(fileEdf);
    [num, txt, raw] = xlsread(fileExcel,1);
    
    Fs = 100; % Sampling Frequency
    
    startTimeAll=num(:,6);
    sall=num(:,9);
    resp=num(:,1);
    
    counterSlow=0;
    counterFast=0;
    
    % Loop untuk setiap kata/trial
    for kata = 1:60
        statAll = sall(kata);
        
        if statAll == 1
            %==================================================================
            % BAGIAN 1: EPOCHING & BASELINE CORRECTION
            %==================================================================
            
            % 1. Tentukan sampel stimulus (t=0)
            stimulus_onset_sample = round(startTimeAll(kata) * Fs);
            
            % 2. Tentukan sampel awal dan akhir epoch
            epoch_start_sample = stimulus_onset_sample + floor(epoch_start_time * Fs);
            epoch_end_sample   = stimulus_onset_sample + ceil(epoch_end_time * Fs);
            
            % Pastikan jendela epoch berada dalam batas data
            if epoch_start_sample < 1 || epoch_end_sample > size(data, 2)
                disp(['Peringatan: Iterasi ke-', num2str(kata), ' dilewati karena di luar batas data.']);
                continue; % Lanjut ke iterasi berikutnya
            end
            
            % 3. Potong data (Epoching) untuk 16 channel
            epoch_data = data(1:16, epoch_start_sample:epoch_end_sample);
            
            % 4. Baseline Correction
            baseline_start_idx = 1;
            baseline_end_idx = round((baseline_window(2) - baseline_window(1)) * Fs);
            
            mean_baseline = mean(epoch_data(:, baseline_start_idx:baseline_end_idx), 2);
            corrected_epoch = epoch_data - mean_baseline; % Kurangi baseline dari seluruh epoch

            % Menghitung counter
            if resp(kata) < 0.5
                counterFast=counterFast+1;
            else
                counterSlow=counterSlow+1;
            end

            %==================================================================
            % BAGIAN 2: ANALISIS & PLOTTING 2D (Topoplot Tegangan N400)
            %==================================================================
            
            % Tentukan indeks sampel untuk jendela N400
            n400_start_idx = round((n400_window(1) - epoch_start_time) * Fs);
            n400_end_idx   = round((n400_window(2) - epoch_start_time) * Fs);

            % Ambil data pada jendela N400 dan hitung rata-rata tegangannya
            n400_voltage_data = corrected_epoch(:, n400_start_idx:n400_end_idx);
            mean_n400_voltage = mean(n400_voltage_data, 2); % Rata-rata untuk setiap channel

            % Menentukan nama file
            if resp(kata) < 0.5
                filename_2D = strcat('ERP_2D_N04_',fileExcel(1:2),'_W',num2str(kata),'_F.png');
            else
                filename_2D = strcat('ERP_2D_N04_',fileExcel(1:2),'_W',num2str(kata),'_S.png');
            end

            % Buat topoplot dari rata-rata tegangan N400
            fig1 = figure('Visible', 'off');
            topoplot(mean_n400_voltage, 'eloc16.loc', 'maplimits', 'absmax', 'colormap', flipud(parula));
            title(sprintf('Topografi Tegangan N400 (rata-rata %.0f-%.0f ms)', n400_window(1)*1000, n400_window(2)*1000));
            colorbar;
            saveas(fig1, filename_2D);
            close(fig1);

            disp(['ERP 2D untuk iterasi ke-', num2str(kata), ' telah disimpan.']);

            %==================================================================
            % BAGIAN 3: ANALISIS & PLOTTING 1D (Waveform ERP)
            %==================================================================
            
            channel_to_analyze = 8; % Misal, channel Cz atau Pz yang umum untuk N400
            signal_1D = corrected_epoch(channel_to_analyze, :);
            time_axis = linspace(epoch_start_time, epoch_end_time, size(corrected_epoch, 2));

            % Menentukan nama file
            if resp(kata) < 0.5
                filename_1D = strcat('ERP_1D_N04_',fileExcel(1:2),'_W',num2str(kata),'_F.png');
            else
                filename_1D = strcat('ERP_1D_N04_',fileExcel(1:2),'_W',num2str(kata),'_S.png');
            end

            fig2 = figure('Visible', 'off', 'Position', [100, 100, 900, 600]);
            
            % Plot waveform ERP
            plot(time_axis, signal_1D, 'LineWidth', 1.5);
            hold on;
            
            % Tandai area N400
            y_limits = ylim;
            patch([n400_window(1) n400_window(2) n400_window(2) n400_window(1)], [y_limits(1) y_limits(1) y_limits(2) y_limits(2)], 'r', 'FaceAlpha', 0.1, 'EdgeColor', 'none');
            
            % Tambahkan garis bantu
            line([0 0], ylim, 'Color', 'k', 'LineStyle', '--'); % Garis stimulus onset (t=0)
            line(xlim, [0 0], 'Color', 'k', 'LineStyle', '--'); % Garis nol mikrovolt
            
            hold off;
            grid on;
            xlabel('Waktu (detik)');
            ylabel('Amplitudo (\muV)');
            title(sprintf('ERP Waveform di Channel %d - Sesi %d Kata %d', channel_to_analyze, session, kata));
            legend('ERP Signal', 'Jendela N400', 'Location', 'southeast');
            
            saveas(fig2, filename_1D);
            close(fig2);
            
            disp(['ERP 1D untuk iterasi ke-', num2str(kata), ' telah disimpan.']);
        end
    end
    disp(['Jumlah Data Fast: ', num2str(counterFast)]);
    disp(['Jumlah Data Slow: ', num2str(counterSlow)]);
end
disp('PROSES ERP SELESAI.');