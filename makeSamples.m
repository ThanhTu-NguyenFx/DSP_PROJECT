% makeSamples.m  --  Tao 3 ban nhac mau (moi loai nhip 1 bai) de mo bang nut "Mo ban nhac"
% Chay 1 lan trong thu muc do an: se tao ra 3 file .mat

%% Nhip 2/4 - "Kia con buom vang" (giai dieu dan gian Frere Jacques)
d = { 'C4','den'; 'D4','den';   'E4','den'; 'C4','den';        ... % o 1-2
      'C4','den'; 'D4','den';   'E4','den'; 'C4','den';        ... % o 3-4
      'E4','den'; 'F4','den';   'G4','trang';                  ... % o 5-6
      'E4','den'; 'F4','den';   'G4','trang';                  ... % o 7-8
      'G4','mocdon'; 'A4','mocdon'; 'G4','mocdon'; 'F4','mocdon'; 'E4','den'; 'C4','den'; ... % o 9-10
      'G4','mocdon'; 'A4','mocdon'; 'G4','mocdon'; 'F4','mocdon'; 'E4','den'; 'C4','den'; ... % o 11-12
      'C4','den'; 'G3','den';   'C4','trang';                  ... % o 13-14
      'C4','den'; 'G3','den';   'C4','trang' };                    % o 15-16
S.score = struct('note', d(:,1), 'type', d(:,2))';
S.tempo = 110;  S.timeSig = 2;  S.playMode = 'staccato';
save('mau_24_kia_con_buom_vang.mat', '-struct', 'S');

%% Nhip 3/4 - "Happy Birthday" (giai dieu da thuoc public domain)
d = { 'R','trang';  'G4','mocdon'; 'G4','mocdon';              ... % o 1 (lang 2 phach + 2 not lay da)
      'A4','den';   'G4','den';    'C5','den';                 ... % o 2
      'B4','trang'; 'G4','mocdon'; 'G4','mocdon';              ... % o 3
      'A4','den';   'G4','den';    'D5','den';                 ... % o 4
      'C5','trang'; 'G4','mocdon'; 'G4','mocdon';              ... % o 5
      'G5','den';   'E5','den';    'C5','den';                 ... % o 6
      'B4','den';   'A4','den';    'F5','mocdon'; 'F5','mocdon'; ... % o 7
      'E5','den';   'C5','den';    'D5','den';                 ... % o 8
      'C5','trang'; 'R','den' };                                   % o 9
S.score = struct('note', d(:,1), 'type', d(:,2))';
S.tempo = 100;  S.timeSig = 3;  S.playMode = 'legato';
save('mau_34_happy_birthday.mat', '-struct', 'S');

%% Nhip 4/4 - "Twinkle Twinkle Little Star"
d = { 'C4','den'; 'C4','den'; 'G4','den'; 'G4','den';          ... % o 1
      'A4','den'; 'A4','den'; 'G4','trang';                    ... % o 2
      'F4','den'; 'F4','den'; 'E4','den'; 'E4','den';          ... % o 3
      'D4','den'; 'D4','den'; 'C4','trang';                    ... % o 4
      'G4','den'; 'G4','den'; 'F4','den'; 'F4','den';          ... % o 5
      'E4','den'; 'E4','den'; 'D4','trang';                    ... % o 6
      'G4','den'; 'G4','den'; 'F4','den'; 'F4','den';          ... % o 7
      'E4','den'; 'E4','den'; 'D4','trang';                    ... % o 8
      'C4','den'; 'C4','den'; 'G4','den'; 'G4','den';          ... % o 9
      'A4','den'; 'A4','den'; 'G4','trang';                    ... % o 10
      'F4','den'; 'F4','den'; 'E4','den'; 'E4','den';          ... % o 11
      'D4','den'; 'D4','den'; 'C4','trang' };                      % o 12
S.score = struct('note', d(:,1), 'type', d(:,2))';
S.tempo = 100;  S.timeSig = 4;  S.playMode = 'legato';
save('mau_44_twinkle.mat', '-struct', 'S');

disp('Da tao 3 file mau: mau_24_kia_con_buom_vang.mat, mau_34_happy_birthday.mat, mau_44_twinkle.mat');
