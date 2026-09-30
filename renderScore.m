function [y, info] = renderScore(score, tempo, timeSig, mode, fs)
%RENDERSCORE  Bien "ban nhac ky hieu" thanh tin hieu am thanh
%   [y, info] = renderScore(score, tempo, timeSig, mode, fs)
%     score   : mang struct, moi phan tu co 2 truong
%               .note : ten not ('C4', 'F#3', ...) hoac 'R' = dau lang
%               .type : 'tron', 'trang', 'den', 'mocdon', 'mockep'
%     tempo   : so phach / phut (BPM), not den = 1 phach
%     timeSig : so phach moi o nhip: 2 (nhip 2/4), 3 (nhip 3/4), 4 (nhip 4/4)
%     mode    : 'legato' (lien tieng) hoac 'staccato' (ngat tieng)
%     fs      : tan so lay mau (mac dinh 44100 Hz)
%
%   y    : tin hieu am thanh (vector cot), da chuan hoa ve [-0.9, 0.9]
%   info : thong tin kiem tra o nhip (tong so phach, so o nhip, canh bao...)

    if nargin < 5, fs = 44100; end
    assert(ismember(timeSig, [2 3 4]), 'Nhip chi duoc la 2, 3 hoac 4 (2/4, 3/4, 4/4)');
    assert(any(strcmpi(mode, {'legato', 'staccato'})), 'mode phai la ''legato'' hoac ''staccato''');
    assert(tempo > 0, 'Tempo phai > 0');
    assert(~isempty(score), 'Ban nhac dang rong');

    beatSec = 60 / tempo;              % thoi gian 1 phach (giay)
    K = numel(score);

    % --- So phach, vi tri bat dau, o nhip cua tung not (dung chung voi giao dien) ---
    info = scoreTiming(score, timeSig);
    beats      = info.beats;
    startBeat  = info.startBeat;
    totalBeats = info.totalBeats;
    info.durationSec = totalBeats * beatSec;

    % --- Canh bao o nhip ---
    if ~info.lastMeasureFull
        warning('renderScore:incomplete', ...
                'O nhip cuoi chi co %.2f / %d phach (chua du).', info.lastMeasureBeats, timeSig);
    end
    if ~isempty(info.crossBarline)
        warning('renderScore:cross', ...
                'Not so %s vat qua vach nhip.', mat2str(info.crossBarline'));
    end

    % --- Thong so legato / staccato ---
    overlapT = 0.03;                   % legato: 2 not chong len nhau 30 ms (crossfade)
    tailT    = 0.2;                    % du phong cuoi bai

    y = zeros(round((totalBeats * beatSec + tailT) * fs), 1);

    % --- Tong hop tung not roi cong vao dung vi tri (overlap-add) ---
    for k = 1:K
        if strcmpi(score(k).note, 'R')
            continue;                  % dau lang: de nguyen cac mau = 0
        end

        f0  = noteFreq(score(k).note);
        dur = beats(k) * beatSec;      % truong do theo ly thuyet (giay)

        % Not ke tiep co cung cao do khong? (vi du C4 C4)
        nextSame = k < K && strcmpi(score(k+1).note, score(k).note);

        if strcmpi(mode, 'legato') && nextSame
            % Legato nhung 2 not giong nhau dung lien: nguoi choi that van phai
            % "danh lai" not sau -> ngat 40 ms truoc not sau, neu khong 2 not se dinh lam 1
            soundDur = dur - 0.04;
            aT = overlapT;
            rT = 0.03;
        elseif strcmpi(mode, 'legato')
            soundDur = dur + overlapT; % keo dai sang not sau 1 chut
            aT = overlapT;             % not sau fade-in ...
            rT = overlapT;             % ... dung luc not truoc fade-out
        else
            soundDur = 0.5 * dur;      % chi vang nua truong do, nua con lai im lang
            aT = 0.005;
            rT = 0.03;
        end

        vel = beatAccent(startBeat(k), timeSig);
        x   = synthNote(f0, soundDur, fs, vel, aT, rT);

        i0 = round(startBeat(k) * beatSec * fs) + 1;
        i1 = i0 + numel(x) - 1;
        y(i0:i1) = y(i0:i1) + x;
    end

    % --- Chuan hoa 1 lan cho ca bai (giu tuong quan manh/nhe giua cac not) ---
    peak = max(abs(y));
    if peak > 0
        y = 0.9 * y / peak;
    end
end


function v = beatAccent(startBeat, timeSig)
%BEATACCENT  Do manh cua not theo vi tri phach trong o nhip
%   Phach 1 cua moi o nhip: manh nhat
%   Nhip 4/4 them phach 3: manh vua
%   Con lai (ke ca not bat dau giua phach): nhe

    pos = mod(startBeat, timeSig);
    if abs(pos) < 1e-9
        v = 1.0;
    elseif timeSig == 4 && abs(pos - 2) < 1e-9
        v = 0.85;
    else
        v = 0.75;
    end
end

