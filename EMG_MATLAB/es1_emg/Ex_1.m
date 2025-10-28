clear all, close all, clc
%{

Question A: Why Down-Sample After Envelope Computation?
Answer: Down-sampling is done after computing the envelope because the envelope is a smoother,
lower-frequency version of the EMG signal. By down-sampling, we reduce the data size without 
losing important information since the envelope doesn’t change rapidly. This makes the data 
easier to handle and analyze.

Question B: How to Determine Timing of Muscle Activation in Relation to Movement?
Answer: To understand the timing of muscle activation relative to movement, look at the envelope 
of the EMG signal and the movement data. Find the peaks or increases in the EMG envelope and 
compare them to the changes in the movement signal. This will show when the muscle activates
(from the EMG) in response to movement changes.

%}

% 1-> Load the data file
load('ES1_emg.mat');

% 2-> Filter raw EMG data is stored in 1st colown:
emg_signal = Es1_emg.matrix(:, 1);
Fs = 2000; % Sampling frequency 

% Filter specifications
low_cutoff = 30; % Lower cutoff frequency in Hz
high_cutoff = 450; % Upper cutoff frequency in Hz
filter_order = 200; % Filter order for FIR

% Normalize cutoff frequencies
low = low_cutoff / (Fs / 2);
high = high_cutoff / (Fs / 2);

% Design the FIR band-pass filter
b = fir1(filter_order, [low high], 'bandpass');

% Apply zero-phase filtering
filtered_emg = filtfilt(b, 1, emg_signal);

% 3-> Rectify the signal
rectified_emg = abs(filtered_emg);
% Define envelope filter specifications
envelope_cutoff = 6; % Upper cutoff frequency for the envelope in Hz
normalized_cutoff = envelope_cutoff / (Fs / 2);

% Design the low-pass filter for the envelope
envelope_filter_order = 50; % Filter order for smoother envelope
envelope_b = fir1(envelope_filter_order, normalized_cutoff, 'low');

% Apply zero-phase filtering to get the envelope
emg_envelope = filtfilt(envelope_b, 1, rectified_emg);
down_factor = 10; % Define down-sampling factor
downsampled_emg = downsample(emg_envelope, down_factor);


% Plotting Raw EMG signal overlaid with the filtered signal
figure;
subplot(3, 1, 1);
plot(emg_signal, 'b'); hold on;
plot(filtered_emg, 'r');
title('Raw EMG Signal and Filtered Signal');
xlabel('Samples'); ylabel('Amplitude');
legend('Raw EMG', 'Filtered EMG');

% Plotting the Rectified EMG signal overlaid with the envelope:
subplot(3, 1, 2);
plot(rectified_emg, 'g'); hold on;
plot(emg_envelope, 'm');
title('Rectified EMG and Envelope');
xlabel('Samples'); ylabel('Amplitude');
legend('Rectified EMG', 'Envelope');

% Plotting the movement signal with the envelope
movement_signal = Es1_emg.matrix(:, 2:4);
subplot(3, 1, 3);
plot(movement_signal);
hold on;
plot(emg_envelope, 'k');
title('Movement Signal and EMG Envelope');
xlabel('Samples'); ylabel('Amplitude');
legend('Movement Signal', 'EMG Envelope');
legend()

% just ignore this :-)
% max_value = max(Es1_emg.matrix(:,4)) % Overall maximum value in the matrix
% min_value = min(Es1_emg.matrix(:,4)) % Overall minimum value in the matrix


theta = deg2rad(45);
R = [cos(theta) -sin(theta) 0;
     sin(theta)  cos(theta) 0;
         0            0     1];