% test_step1.m  --  Kiem tra BUOC 1: bo may tao nhac (chua co giao dien)
% Chay file nay trong MATLAB (de chung thu muc voi cac file .m khac)
clear; clc; close all;
fs = 44100;

%% 1) Kiem tra cac ham co ban
fprintf('--- Kiem tra ham co ban ---\n');
fprintf('A4  = %.2f Hz (dung: 440.00)\n', noteFreq('A4'));
fprintf('C4  = %.2f Hz (dung: 261.63)\n', noteFreq('C4'));
fprintf('C#4 = %.2f Hz, Db4 = %.2f Hz (phai bang nhau)\n', noteFreq('C#4'), noteFreq('Db4'));
fprintf('Not den o tempo 70 = %.4f giay (dung: 0.8571)\n', noteBeats('den') * 60/70);

%% 2) Bai 1: "Twinkle Twinkle Little Star" - nhip 4/4, tempo 100
data = { 'C4','den';  'C4','den';  'G4','den';  'G4','den';   ... % o nhip 1
         'A4','den';  'A4','den';  'G4','trang';              ... % o nhip 2
         'F4','den';  'F4','den';  'E4','den';  'E4','den';   ... % o nhip 3
         'D4','den';  'D4','den';  'C4','trang' };                % o nhip 4
score1 = struct('note', data(:,1), 'type', data(:,2));

[yLeg, info1] = renderScore(score1, 100, 4, 'legato',   fs);
[ySta, ~]     = renderScore(score1, 100, 4, 'staccato', fs);

fprintf('\n--- Bai 1 (4/4) ---\n');
fprintf('Tong so phach: %g | So o nhip: %d | Thoi luong: %.2f s\n', ...
        info1.totalBeats, info1.nMeasures, info1.durationSec);

audiowrite('bai1_legato.wav',   yLeg, fs);
audiowrite('bai1_staccato.wav', ySta, fs);

%% 3) Bai 2: nhip 3/4, tempo 70, co dau lang
data = { 'C4','trang';  'E4','den';        ... % o nhip 1: 2 + 1 = 3 phach
         'G4','den';    'R','den'; 'G4','den'; ... % o nhip 2 (co 1 phach lang)
         'A4','mocdon'; 'G4','mocdon'; 'F4','mocdon'; 'E4','mocdon'; 'D4','den'; ... % o nhip 3
         'C4','trang';  'R','den' };             % o nhip 4
score2 = struct('note', data(:,1), 'type', data(:,2));

[y2, info2] = renderScore(score2, 70, 3, 'legato', fs);
fprintf('\n--- Bai 2 (3/4) ---\n');
fprintf('Tong so phach: %g | So o nhip: %d | Thoi luong: %.2f s\n', ...
        info2.totalBeats, info2.nMeasures, info2.durationSec);
audiowrite('bai2_nhip34.wav', y2, fs);

%% 4) Ve dang song de so sanh legato va staccato
t1 = (0:numel(yLeg)-1) / fs;
t2 = (0:numel(ySta)-1) / fs;
figure('Name', 'Buoc 1 - Legato vs Staccato');
subplot(2,1,1); plot(t1, yLeg); grid on;
title('Bai 1 - Legato'); xlabel('Thoi gian (s)'); ylabel('Bien do');
subplot(2,1,2); plot(t2, ySta); grid on;
title('Bai 1 - Staccato'); xlabel('Thoi gian (s)'); ylabel('Bien do');

%% 5) Nghe thu (bo dau % o dong ban muon nghe)
% sound(yLeg, fs);
% sound(ySta, fs);
% sound(y2, fs);
