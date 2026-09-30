function y = synthNote(f0, soundDur, fs, velocity, attackT, releaseT)
%SYNTHNOTE  Tong hop tin hieu cua MOT not nhac
%   y = synthNote(f0, soundDur, fs, velocity, attackT, releaseT)
%     f0       : tan so co ban (Hz)
%     soundDur : thoi gian not vang (giay)
%     fs       : tan so lay mau (Hz)
%     velocity : do manh cua not (0..1), dung de nhan phach manh/yeu
%     attackT  : thoi gian attack (giay)
%     releaseT : thoi gian release (giay)
%
%   Cac buoc:
%     1) Cong hoa am: k*f0 voi bien do giam dan, BO QUA hoa am nao >= fs/2 (Nyquist)
%     2) Nhan bao hinh ADSR (thoi gian tuyet doi, khong theo % do dai not)
%     3) KHONG chuan hoa tung not -> chuan hoa 1 lan cho ca bai o renderScore

    N = round(soundDur * fs);          % so mau cua not
    t = (0:N-1)' / fs;                 % truc thoi gian (vector cot)

    % --- 1) Tong hop hoa am, co kiem tra Nyquist ---
    harmAmp = [1 0.5 0.25 0.125];      % bien do hoa am bac 1, 2, 3, 4
    y = zeros(N, 1);
    for k = 1:numel(harmAmp)
        fk = k * f0;
        if fk >= fs/2
            break;   % hoa am nay (va moi hoa am cao hon) se bi aliasing -> bo qua
        end
        y = y + harmAmp(k) * sin(2*pi*fk*t);
    end

    % --- 2) Bao hinh ADSR ---
    decayT = 0.05;                     % 50 ms
    sustainLevel = 0.7;
    env = adsrEnvelope(N, fs, attackT, decayT, sustainLevel, releaseT);

    y = velocity * (y .* env);
end


function env = adsrEnvelope(N, fs, aT, dT, sLevel, rT)
%ADSRENVELOPE  Bao hinh Attack - Decay - Sustain - Release dai dung N mau
%   Neu not qua ngan (ngan hon A + D + R), co gian 3 doan theo ty le

    nA = round(aT * fs);
    nD = round(dT * fs);
    nR = round(rT * fs);

    if nA + nD + nR > N
        scale = N / (nA + nD + nR);
        nA = floor(nA * scale);
        nD = floor(nD * scale);
        nR = floor(nR * scale);
    end
    nS = N - nA - nD - nR;             % phan con lai la sustain (luon >= 0)

    env = [ linspace(0, 1, nA)';            % Attack : 0 -> 1
            linspace(1, sLevel, nD)';       % Decay  : 1 -> sustain
            sLevel * ones(nS, 1);           % Sustain: giu nguyen
            linspace(sLevel, 0, nR)' ];     % Release: sustain -> 0
end
