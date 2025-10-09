clc
clear all
close all

% --- Parameters ---
% If your EDF file has different channel names, you might need to adjust this.
% Assuming 16 channels, and you can give them generic names if actual names are unknown.
numChannels = 16;
channelNames = cell(1, numChannels);
for i = 1:numChannels
    channelNames{i} = sprintf('Channel %d', i);
end

% --- Load the EDF File ---
% Make sure 'ICA.edf' is in the same directory as your MATLAB script
% or provide the full path to the file.
fileEdf = 'RESP.EDF'; 

try
    [header, data] = edfread(fileEdf);
    
    % Get sampling frequency from header
    % Fs = header.samplingrate(1); % Assuming all channels have the same sampling rate
    Fs = 100;
    % Calculate time vector
    numSamples = size(data, 2);
    time = (0:numSamples-1) / Fs; % Time in seconds
    
    % --- Plotting the Whole EEG Recording ---
    figure('Name', 'Whole EEG Recording', 'Position', [100, 100, 1200, 800]); % Adjust figure size
    
    % We will offset each channel for better visualization (stacked plot)
    offset_increment = 200; % Adjust this value based on your signal amplitude
    
    hold on;
    for i = 1:numChannels
        % Apply an offset to each channel to prevent overlap
        plot(time, data(i, :) + (i-1) * offset_increment, 'LineWidth', 0.8, 'DisplayName', channelNames{i});
    end
    hold off;
    
    % --- Customize the Plot for Journal Publication ---
    xlabel('Time (seconds)', 'FontSize', 12);
    ylabel('Amplitude (\muV) and Channel Offset', 'FontSize', 12); % Indicate offset
    title('Whole EEG Recording Across All Channels', 'FontSize', 14, 'FontWeight', 'bold');
    
    % Add a legend if specific channel names are important
    % If you have actual channel names in your header, you can use:
    % legend(header.label, 'Location', 'eastoutside');
    % For now, using generic names:
    legend(channelNames, 'Location', 'eastoutside', 'FontSize', 10);
    
    grid on;
    set(gca, 'FontSize', 10); % Set axis font size
    
    % You might want to adjust the Y-axis limits manually if the automatic limits
    % don't look good due to the offsets.
    % For example: ylim([min(data(:)) max(data(:)) + (numChannels-1)*offset_increment + 50]);
    
    disp('Whole EEG recording plot generated successfully.');
    
    % --- Save the figure (optional) ---
    saveas(gcf, 'Whole_EEG_Recording RAW.png'); % Save as PNG
    % saveas(gcf, 'Whole_EEG_Recording.fig'); % Save as MATLAB figure file
    
catch ME
    warning(['Error loading or processing EDF file: ', ME.message]);
    disp('Please ensure ''ICA.edf'' is in the correct directory and is a valid EDF file.');
end