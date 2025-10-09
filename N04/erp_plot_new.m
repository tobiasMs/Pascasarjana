clc
clear all
close all
%==========================================================================
% PARAMETER PENTING UNTUK ANALISIS ERP
%==========================================================================
epoch_start_time = -0.2; % dalam detik (-200 ms)
epoch_end_time   = 0.8; % dalam detik (+800 ms)
baseline_window  = [-0.2, 0]; % dari -200 ms hingga 0 ms
n400_window      = [0.35, 0.45]; % dari 350 ms hingga 450 ms
%==========================================================================
for session=1:8
    fileExcel=strcat('S',num2str(session),'.xlsx');
    fileEdf=['ICA.edf'];
    
    [header,data] = edfread(fileEdf);
    [num, txt, raw] = xlsread(fileExcel,1);
    
    Fs = 100;
    
    startTimeAll=num(:,6);
    sall=num(:,9);
    resp=num(:,1);
    
    counterSlow=0;
    counterFast=0;
    
    for kata = 1:60
        statAll = sall(kata);
        
        if statAll == 1
            %==================================================================
            % BAGIAN 1: EPOCHING & BASELINE CORRECTION (Tidak Berubah)
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
            % BAGIAN 2: ANALISIS & PLOTTING 2D (Topoplot POWER N400) - DIPERBARUI
            %==================================================================
            
            %%% --- PERUBAHAN DIMULAI DI SINI --- %%%
            
            % Tentukan indeks sampel untuk jendela N400
            n400_start_idx = round((n400_window(1) - epoch_start_time) * Fs);
            n400_end_idx   = round((n400_window(2) - epoch_start_time) * Fs);
            
            % Ambil data pada jendela N400 yang sudah di-baseline correct
            n400_data_segment = corrected_epoch(:, n400_start_idx:n400_end_idx);
            
            % Hitung POWER dari segmen data N400 (sama seperti metode Non-ERP)
            jmlChannel=size(n400_data_segment,1);
            pow = zeros(1, jmlChannel);
            for k = 1:jmlChannel
                dataN = n400_data_segment(k,:);
                power_timedomain = sum(abs(dataN).^2)/length(dataN);
                pow(k) = 10*log10(power_timedomain/2);
            end
            
            % Pastikan fungsi Normalization.m ada di folder Anda
            [Norm_pow] = Normalization(pow);
            
            % Menentukan nama file
            if resp(kata) < 0.5
                filename_2D = strcat('ERP_2D_Power_N04_',fileExcel(1:2),'_W',num2str(kata),'_F.png');
            else
                filename_2D = strcat('ERP_2D_Power_N04_',fileExcel(1:2),'_W',num2str(kata),'_S.png');
            end

            % Buat topoplot dari POWER N400
            fig1 = figure('Visible', 'off');
            topoplot(Norm_pow, 'eloc16.loc', 'colormap', flipud(parula), 'electrodes', 'ptslabels');
            title(sprintf('ERP N400 (%.0f-%.0f ms) Session %d Word %d', n400_window(1)*1000, n400_window(2)*1000, session, kata));
            caxis([min(Norm_pow) max(Norm_pow)]); % Atur limit warna
            cb = colorbar;
            ylabel(cb, 'Normalization Power (Low to High)'); % Beri label colorbar
            
            saveas(fig1, filename_2D);
            close(fig1);
            
            disp(['ERP 2D (Power) untuk iterasi ke-', num2str(kata), ' telah disimpan.']);
            
            %%% --- PERUBAHAN SELESAI --- %%%

            %==================================================================
            % BAGIAN 3: ANALISIS & PLOTTING 1D (Waveform ERP - Tidak Berubah)
            %==================================================================
            channel_to_analyze = 1;
            signal_1D = corrected_epoch(channel_to_analyze, :);
            time_axis = linspace(epoch_start_time, epoch_end_time, size(corrected_epoch, 2));

            if resp(kata) < 0.5
                filename_1D = strcat('ERP_1D_N04_',fileExcel(1:2),'_W',num2str(kata),'_F.png');
            else
                filename_1D = strcat('ERP_1D_N04_',fileExcel(1:2),'_W',num2str(kata),'_S.png');
            end

            fig2 = figure('Visible', 'off', 'Position', [100, 100, 900, 600]);
            plot(time_axis, signal_1D, 'LineWidth', 1.5);
            hold on;
            y_limits = ylim;
            patch([n400_window(1) n400_window(2) n400_window(2) n400_window(1)], [y_limits(1) y_limits(1) y_limits(2) y_limits(2)], 'r', 'FaceAlpha', 0.1, 'EdgeColor', 'none');
            line([0 0], ylim, 'Color', 'k', 'LineStyle', '--');
            line(xlim, [0 0], 'Color', 'k', 'LineStyle', '--');
            hold off;
            grid on;
            xlabel('Time (s)');
            ylabel('Amplitude (\muV)');
            title(sprintf('ERP Waveform Channel %d - Session %d Word %d', channel_to_analyze, session, kata));
            legend('ERP Signal', 'N400 Window', 'Location', 'southeast');
            
            saveas(fig2, filename_1D);
            close(fig2);
            
            disp(['ERP 1D untuk iterasi ke-', num2str(kata), ' telah disimpan.']);
        end
    end
    disp(['Jumlah Data Fast: ', num2str(counterFast)]);
    disp(['Jumlah Data Slow: ', num2str(counterSlow)]);
end
disp('PROSES ERP SELESAI.');

% Jangan lupa untuk membuat fungsi Normalization.m jika belum ada
% function [output] = Normalization(input)
%     minVal = min(input);
%     maxVal = max(input);
%     if (maxVal - minVal == 0)
%         output = zeros(size(input));
%     else
%         output = (input - minVal) / (maxVal - minVal);
%     end
% end