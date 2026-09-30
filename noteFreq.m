function f = noteFreq(noteName)
%NOTEFREQ  Doi ten not nhac sang tan so (Hz) theo thang binh quan 12, A4 = 440 Hz
%   f = noteFreq('A4')   -> 440
%   f = noteFreq('C#5')  -> 554.37
%   f = noteFreq('Bb3')  -> 233.08
%
%   Cong thuc: f = 440 * 2^(n/12)
%   n = so nua cung tinh tu A4 (n = 0 la A4, n > 0 cao hon, n < 0 thap hon)

    % Tach ten not bang regular expression:
    %   ([A-G])  : chu cai ten not
    %   ([#b]?)  : dau thang (#) hoac giang (b), co the khong co
    %   (\d)     : so quang tam (1 chu so)
    tok = regexp(noteName, '^([A-G])([#b]?)(\d)$', 'tokens', 'once');
    if isempty(tok)
        error('noteFreq:badName', ...
              'Ten not khong hop le: "%s" (vi du dung: C4, C#4, Bb3)', noteName);
    end
    letter     = tok{1};
    accidental = tok{2};
    octave     = str2double(tok{3});

    % Vi tri (tinh bang nua cung) cua 7 not tu nhien trong 1 quang tam, C = 0
    letters   = 'CDEFGAB';
    semitones = [0 2 4 5 7 9 11];
    pc = semitones(letters == letter);

    if strcmp(accidental, '#'), pc = pc + 1; end
    if strcmp(accidental, 'b'), pc = pc - 1; end

    % A nam o vi tri 9 trong quang tam, nen so nua cung tu A4:
    n = (octave - 4) * 12 + (pc - 9);
    f = 440 * 2^(n/12);
end
