clear all, close all, clc
load('ES2_emg')
t = ES2_emg.time;
muscle1 = ES2_emg.signals(:,1);
muscle2 = ES2_emg.signals(:,2);
muscle3 = ES2_emg.signals(:,3);
muscle4 = ES2_emg.signals(:,4);
fs = 1000;

% Function to process and smooth EMG signals with thresholding for peaks and optional rectification
function scaled_signal = process_and_smooth_emg(raw_signal, fs, apply_threshold, apply_abs)
    % 1. Bandpass Filtering (30-450 Hz)
    bpFilt = designfilt('bandpassiir', 'FilterOrder', 4, ...
                        'HalfPowerFrequency1', 30, 'HalfPowerFrequency2', 450, ...
                        'SampleRate', fs);
    filtered_signal = filtfilt(bpFilt, raw_signal); % Apply zero-phase filtering

    % 2. Rectification (Absolute Value)
    if apply_abs
        rectified_signal = abs(filtered_signal);
    else
        rectified_signal = filtered_signal;
    end
    
    % 3. Smoothing with a Moving Average Filter
    windowSize = round(2.5 * fs); % Example window size of 0.1 seconds
    smooth_signal = movmean(rectified_signal, windowSize);

    % 4. Scaling to [0, 0.1] Range
    min_val = min(smooth_signal);
    max_val = max(smooth_signal);
    
    % Avoid division by zero if the signal is constant
    if max_val - min_val == 0
        scaled_signal = smooth_signal * 0; % Set to zero if no variability
    else
        % Normalize to [0, 1]
        normalized_signal = (smooth_signal - min_val) / (max_val - min_val);
        
        % Scale to [0, 0.1]
        scaled_signal = 0.1 * normalized_signal;
    end
    
    % 5. Optional Thresholding to Keep Only Peak Values
    if apply_threshold
        threshold = 0.76 * max(scaled_signal); % Set threshold at 80% of max
        scaled_signal(scaled_signal < threshold) = 0; % Set values below threshold to zero
    end
end

% Process each muscle signal
scaled_muscle1 = process_and_smooth_emg(muscle1, fs, true, true); % Apply thresholding and rectification for muscle 1
scaled_muscle2 = process_and_smooth_emg(muscle2, fs, true, true); % Apply thresholding and rectification for muscle 2
scaled_muscle3 = process_and_smooth_emg(muscle3, fs, true, true); % Apply thresholding and rectification for muscle 3
scaled_muscle4 = process_and_smooth_emg(muscle4, fs, true, true); % Apply thresholding and rectification for muscle 4

% Plot the processed and smoothed signals
figure;
subplot(4, 1, 1);
plot(t, scaled_muscle1);
title('Smoothed Muscle 1 Signal (Scaled to [0, 0.1])');
xlabel('Time (s)');
ylabel('Amplitude');
ylim([0 0.1]);

subplot(4, 1, 2);
plot(t, scaled_muscle2);
title('Smoothed Muscle 2 Signal (Scaled to [0, 0.1])');
xlabel('Time (s)');
ylabel('Amplitude');
ylim([0 0.1]);

subplot(4, 1, 3);
plot(t, scaled_muscle3);
title('Smoothed Muscle 3 Signal with Peak Retention');
xlabel('Time (s)');
ylabel('Amplitude');
ylim([0 0.1]);

subplot(4, 1, 4);
plot(t, scaled_muscle4);
title('Smoothed Muscle 4 Signal with Peak Retention');
xlabel('Time (s)');
ylabel('Amplitude');
ylim([0 0.1]);

sgtitle('Processed and Smoothed EMG Signals for 4 Muscles');


theta = deg2rad(45);
R = [cos(theta) -sin(theta) 0;
     sin(theta)  cos(theta) 0;
         0            0     1];