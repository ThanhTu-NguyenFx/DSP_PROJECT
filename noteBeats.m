function beats = noteBeats(noteType)
%NOTEBEATS  So phach cua mot loai not (not den = 1 phach)
%   'tron'   : not tron     = 4 phach
%   'trang'  : not trang    = 2 phach
%   'den'    : not den      = 1 phach
%   'mocdon' : not moc don  = 1/2 phach
%   'mockep' : not moc kep  = 1/4 phach
%
%   Thoi gian thuc (giay) = so phach * (60 / tempo)
%   -> ham nay KHONG phu thuoc tempo; tempo chi ap vao o buoc cuoi (renderScore)

    switch lower(noteType)
        case 'tron',   beats = 4;
        case 'trang',  beats = 2;
        case 'den',    beats = 1;
        case 'mocdon', beats = 0.5;
        case 'mockep', beats = 0.25;
        otherwise
            error('noteBeats:badType', ...
                  'Loai not khong hop le: "%s" (dung: tron, trang, den, mocdon, mockep)', noteType);
    end
end
