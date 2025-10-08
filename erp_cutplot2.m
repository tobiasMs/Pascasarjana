clc
clear all
close all

%==========================================================================
% PARAMETER PENTING UNTUK ANALISIS
%==========================================================================
% Jendela waktu untuk setiap epoch (relatif terhadap stimulus)
epoch_start_time = -0.2; % dalam detik (-200 ms)
epoch_end_time   = 0.8; % dalam detik (+800 ms)

% Jendela waktu untuk baseline correction
baseline_window  = [-0.2, 0]; % dari -200 ms hingga 0 ms

% Jendela waktu untuk mengukur amplitudo N400 (untuk plot 2D)
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
            % BAGIAN 1: EPOCHING & BASELINE CORRECTION (Sama seperti Skrip ERP)
            %==================================================================
            stimulus_onset_sample = round(startTimeAll(kata) * Fs);
            epoch_start_sample = stimulus_onset_sample + floor(epoch_start_time * Fs);
            epoch_end_sample   = stimulus_onset_sample + ceil(epoch_end_time * Fs);
            
            if epoch_start_sample < 1 || epoch_end_sample > size(data, 2)
                disp(['Peringatan: Iterasi ke-', num2str(kata), ' dilewati karena di luar batas data.']);
                continue;
            end
            
            epoch_data = data(1:16, epoch_start_sample:epoch_end_sample);
            
            baseline_start_idx = 1;
            baseline_end_idx = round((baseline_window(2) - baseline_window(1)) * Fs);
            
            mean_baseline = mean(epoch_data(:, baseline_start_idx:baseline_end_idx), 2);
            corrected_epoch = epoch_data - mean_baseline;

            if resp(kata) < 0.5
                counterFast=counterFast+1;
            else
                counterSlow=counterSlow+1;
            end

            %==================================================================
            % BAGIAN 2: ANALISIS 2D (Topoplot Tegangan N400 - Tidak Berubah)
            %==================================================================
            n400_start_idx = round((n400_window(1) - epoch_start_time) * Fs);
            n400_end_idx   = round((n400_window(2) - epoch_start_time) * Fs);
            n400_voltage_data = corrected_epoch(:, n400_start_idx:n400_end_idx);
            mean_n400_voltage = mean(n400_voltage_data, 2);

            if resp(kata) < 0.5
                filename_2D = strcat('ERP_2D_N04_',fileExcel(1:2),'_W',num2str(kata),'_F.png');
            else
                filename_2D = strcat('ERP_2D_N04_',fileExcel(1:2),'_W',num2str(kata),'_S.png');
            end

            fig1 = figure('Visible', 'off');
            topoplot(mean_n400_voltage, 'eloc16.loc', 'maplimits', 'absmax', 'colormap', flipud(parula));
            title(sprintf('Topografi Tegangan N400 (%.0f-%.0f ms)', n400_window(1)*1000, n400_window(2)*1000));
            colorbar;
            saveas(fig1, filename_2D);
            close(fig1);
            disp(['ERP 2D untuk iterasi ke-', num2str(kata), ' telah disimpan.']);

            %==================================================================
            % BAGIAN 3: ANALISIS 1D (Time-Frequency Waveform) - KODE BARU
            %==================================================================
            
            channel_to_analyze = 8; % Channel yang akan dianalisis
            signal_1D_epoch = corrected_epoch(channel_to_analyze, :);

            % Cek panjang sinyal sebelum filtering
            if length(signal_1D_epoch) > 24
                
                % Definisikan rentang frekuensi
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
                
                % Terapkan filter pada sinyal epoch
                signal_delta = filtfilt(b_delta, a_delta, signal_1D_epoch);
                signal_theta = filtfilt(b_theta, a_theta, signal_1D_epoch);
                signal_alpha = filtfilt(b_alpha, a_alpha, signal_1D_epoch);
                signal_beta  = filtfilt(b_beta,  a_beta,  signal_1D_epoch);
                signal_gamma = filtfilt(b_gamma, a_gamma, signal_1D_epoch);
                
                % Buat sumbu waktu yang sesuai dengan epoch
                time_axis = linspace(epoch_start_time, epoch_end_time, length(signal_1D_epoch));
                
                % Membuat dan menyimpan plot 1D dalam subplot
                fig2 = figure('Visible', 'off', 'Position', [100, 100, 900, 1200]);

                subplot(5,1,1); plot(time_axis, signal_delta); title('Delta (0.5-4 Hz)'); ylabel('Amplitudo (\muV)'); grid on; line([0 0], ylim, 'Color', 'k', 'LineStyle', '--');
                subplot(5,1,2); plot(time_axis, signal_theta); title('Theta (4-8 Hz)'); ylabel('Amplitudo (\muV)'); grid on; line([0 0], ylim, 'Color', 'k', 'LineStyle', '--');
                subplot(5,1,3); plot(time_axis, signal_alpha); title('Alpha (8-13 Hz)'); ylabel('Amplitudo (\muV)'); grid on; line([0 0], ylim, 'Color', 'k', 'LineStyle', '--');
                subplot(5,1,4); plot(time_axis, signal_beta); title('Beta (13-30 Hz)'); ylabel('Amplitudo (\muV)'); grid on; line([0 0], ylim, 'Color', 'k', 'LineStyle', '--');
                subplot(5,1,5); plot(time_axis, signal_gamma); title('Gamma (30-49 Hz)'); ylabel('Amplitudo (\muV)'); xlabel('Waktu (detik)'); grid on; line([0 0], ylim, 'Color', 'k', 'LineStyle', '--');
                
                sgtitle(sprintf('Analisis Frekuensi ERP di Channel %d - Sesi %d Kata %d', channel_to_analyze, session, kata));
                
                if resp(kata) < 0.5
                    filename_1D = strcat('TF_1D_N04_',fileExcel(1:2),'_W',num2str(kata),'_F.png');
                else
                    filename_1D = strcat('TF_1D_N04_',fileExcel(1:2),'_W',num2str(kata),'_S.png');
                end
                
                saveas(fig2, filename_1D);
                close(fig2);
                
                disp(['Time-Frequency 1D untuk iterasi ke-', num2str(kata), ' telah disimpan.']);
            else
                disp(['Peringatan: Iterasi ke-', num2str(kata), ' dilewati untuk plot 1D karena data epoch terlalu pendek.']);
            end
        end
    end
    disp(['Jumlah Data Fast: ', num2str(counterFast)]);
    disp(['Jumlah Data Slow: ', num2str(counterSlow)]);
end
disp('PROSES TIME-FREQUENCY SELESAI.');