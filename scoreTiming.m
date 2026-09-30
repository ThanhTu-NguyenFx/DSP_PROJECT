function T = scoreTiming(score, timeSig)
%SCORETIMING  Tinh vi tri phach va o nhip cua tung not trong ban nhac
%   T = scoreTiming(score, timeSig)
%     score   : mang struct (.note, .type)
%     timeSig : so phach moi o nhip (2, 3 hoac 4)
%
%   T.beats          : so phach cua tung not
%   T.startBeat      : not bat dau o phach thu may (tinh tu 0, tu dau bai)
%   T.measure        : not nam o o nhip so may (tinh tu 1)
%   T.beatInMeasure  : not bat dau o phach thu may trong o nhip (tinh tu 1)
%   T.totalBeats     : tong so phach ca bai
%   T.nMeasures      : so o nhip
%   T.lastMeasureBeats, T.lastMeasureFull : o nhip cuoi da du phach chua
%   T.crossBarline   : chi so cac not vat qua vach nhip
%
%   Ham nay KHONG phu thuoc tempo -> dung chung cho giao dien va renderScore

    K = numel(score);
    T.beats = zeros(K, 1);
    for k = 1:K
        T.beats(k) = noteBeats(score(k).type);
    end

    s = cumsum([0; T.beats]);
    T.startBeat = s(1:K);                         % dung duoc ca khi K = 0
    T.totalBeats = sum(T.beats);

    T.measure       = floor(T.startBeat / timeSig) + 1;
    T.beatInMeasure = mod(T.startBeat, timeSig) + 1;

    endBeat = T.startBeat + T.beats;
    measEnd = floor((endBeat - 1e-6) / timeSig) + 1;   % not ket thuc DUNG vach nhip van thuoc o cu
    T.crossBarline = find(measEnd > T.measure);

    T.nMeasures = ceil(T.totalBeats / timeSig - 1e-9);
    if T.nMeasures == 0
        T.lastMeasureBeats = 0;
        T.lastMeasureFull  = false;
    else
        T.lastMeasureBeats = T.totalBeats - (T.nMeasures - 1) * timeSig;
        T.lastMeasureFull  = abs(T.lastMeasureBeats - timeSig) < 1e-9;
    end
end
