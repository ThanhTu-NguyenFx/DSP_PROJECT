function musicApp
%MUSICAPP  Giao dien May tao nhac - Do an DSP
%   Buoc 3: nhap ban nhac + phat / dung / xuat .wav + ve dang song + luu / mo ban nhac
%
%   Chay: go  musicApp  trong Command Window
%
%   Cach dung:
%     1) Chon QUANG TAM (1..6) va TRUONG DO (tron, trang, den, moc don, moc kep)
%        -> 2 lua chon nay duoc GIU NGUYEN cho moi not bam sau, den khi ban doi
%     2) Bam TEN NOT (C, C#, ..., B) hoac LANG de them vao ban nhac
%     3) Chon tempo, nhip, legato/staccato o khung Thiet lap
%     4) Bam PHAT de nghe, XUAT .WAV de luu file am thanh

    % ================= Du lieu dung chung giua cac callback =================
    fs     = 44100;                            % tan so lay mau
    score  = struct('note', {}, 'type', {});   % ban nhac (ban dau rong)
    selRow = [];                               % dong dang chon trong bang
    player = [];                               % doi tuong audioplayer
    cursor = [];                               % vach do chay theo nhac tren do thi

    typeCodes  = {'tron', 'trang', 'den', 'mocdon', 'mockep'};
    typeLabels = {'Tròn', 'Trắng', 'Đen', 'Móc đơn', 'Móc kép'};
    noteNames  = {'C','C#','D','D#','E','F','F#','G','G#','A','A#','B'};

    % ============================ Cua so chinh ==============================
    fig = uifigure('Name', 'Máy tạo nhạc - Đồ án DSP', ...
                   'Position', [80 50 1100 720], ...
                   'CloseRequestFcn', @(~,~) onClose());
    main = uigridlayout(fig, [1 2]);
    main.ColumnWidth = {500, '1x'};

    % ============================== COT TRAI ================================
    left = uigridlayout(main, [6 1]);
    left.RowHeight = {70, 70, 120, 30, 110, '1x'};
    left.Padding = [0 0 0 0];

    % ---- (1) Quang tam: 6 nut, chi 1 nut duoc chon tai 1 thoi diem ----
    octGroup = uibuttongroup(left, 'Title', 'Quãng tám', ...
                             'SelectionChangedFcn', @(~,~) updatePreview());
    octGroup.Layout.Row = 1;
    octBtn = gobjects(1, 6);
    for k = 1:6
        octBtn(k) = uitogglebutton(octGroup, 'Text', num2str(k), ...
                                   'Position', [10 + (k-1)*78, 10, 70, 30]);
    end
    octGroup.SelectedObject = octBtn(4);          % mac dinh quang 4

    % ---- (2) Truong do: 5 nut ----
    durGroup = uibuttongroup(left, 'Title', 'Trường độ', ...
                             'SelectionChangedFcn', @(~,~) updatePreview());
    durGroup.Layout.Row = 2;
    durBtn = gobjects(1, 5);
    for k = 1:5
        durBtn(k) = uitogglebutton(durGroup, 'Text', typeLabels{k}, ...
                                   'Tag', typeCodes{k}, ...
                                   'Position', [10 + (k-1)*94, 10, 88, 30]);
    end
    durGroup.SelectedObject = durBtn(3);          % mac dinh not den

    % ---- (3) Ten not: 12 nut + nut Lang ----
    notePanel = uipanel(left, 'Title', 'Tên nốt (bấm để thêm vào bản nhạc)');
    notePanel.Layout.Row = 3;
    ng = uigridlayout(notePanel, [2 7]);
    for k = 1:12
        b = uibutton(ng, 'Text', noteNames{k}, 'FontSize', 14, 'FontWeight', 'bold', ...
                     'ButtonPushedFcn', @(~,~) addNote(noteNames{k}));
        if any(noteNames{k} == '#')               % not thang: to toi nhu phim den
            b.BackgroundColor = [0.25 0.25 0.25];
            b.FontColor = [1 1 1];
        end
    end
    uibutton(ng, 'Text', 'Lặng', 'FontSize', 14, ...
             'BackgroundColor', [0.85 0.92 1], ...
             'ButtonPushedFcn', @(~,~) addNote('R'));

    % ---- (4) Dong xem truoc ----
    previewLbl = uilabel(left, 'FontSize', 14, 'FontWeight', 'bold', ...
                         'FontColor', [0 0.35 0.7]);
    previewLbl.Layout.Row = 4;

    % ---- (5) Thiet lap: tempo, nhip, legato/staccato ----
    setPanel = uipanel(left, 'Title', 'Thiết lập bản nhạc');
    setPanel.Layout.Row = 5;
    sg = uigridlayout(setPanel, [2 4]);
    sg.ColumnWidth = {80, 90, 70, '1x'};

    uilabel(sg, 'Text', 'Tempo (BPM):');
    tempoSp = uispinner(sg, 'Limits', [30 240], 'Step', 1, 'Value', 70, ...
                        'ValueChangedFcn', @(~,~) refresh());
    uilabel(sg, 'Text', 'Nhịp:');
    sigDD = uidropdown(sg, 'Items', {'2/4', '3/4', '4/4'}, 'ItemsData', [2 3 4], ...
                       'Value', 4, 'ValueChangedFcn', @(~,~) refresh());
    uilabel(sg, 'Text', 'Kiểu nối:');
    modeSw = uiswitch(sg, 'slider', 'Items', {'Legato', 'Staccato'}, 'Value', 'Legato');
    modeSw.Layout.Column = [2 3];

    % ---- (6) Phat nhac va luu ----
    playPanel = uipanel(left, 'Title', 'Phát nhạc và lưu');
    playPanel.Layout.Row = 6;
    pg = uigridlayout(playPanel, [3 3]);
    pg.RowHeight = {40, 35, '1x'};
    uibutton(pg, 'Text', 'Phát', 'FontSize', 15, 'FontWeight', 'bold', ...
             'BackgroundColor', [0.80 0.95 0.80], ...
             'ButtonPushedFcn', @(~,~) playAudio());
    uibutton(pg, 'Text', 'Dừng', 'FontSize', 15, 'FontWeight', 'bold', ...
             'BackgroundColor', [1 0.85 0.85], ...
             'ButtonPushedFcn', @(~,~) stopAudio());
    uibutton(pg, 'Text', 'Xuất .wav', 'FontSize', 15, ...
             'ButtonPushedFcn', @(~,~) exportWav());
    uibutton(pg, 'Text', 'Lưu bản nhạc', 'ButtonPushedFcn', @(~,~) saveScore());
    uibutton(pg, 'Text', 'Mở bản nhạc',  'ButtonPushedFcn', @(~,~) loadScore());
    uibutton(pg, 'Text', 'Gửi ra Workspace', 'ButtonPushedFcn', @(~,~) sendToWorkspace());

    % ============================== COT PHAI ================================
    right = uigridlayout(main, [4 1]);
    right.RowHeight = {'1x', 35, 75, 230};
    right.Padding = [0 0 0 0];

    tbl = uitable(right, ...
        'ColumnName', {'STT', 'Nốt', 'Trường độ', 'Ô nhịp', 'Bắt đầu ở phách'}, ...
        'RowName', {}, ...
        'ColumnWidth', {45, 70, 90, 70, 'auto'}, ...
        'CellSelectionCallback', @onSelect);

    eg = uigridlayout(right, [1 3]);
    eg.Padding = [0 0 0 0];
    uibutton(eg, 'Text', 'Xoá nốt cuối', 'ButtonPushedFcn', @(~,~) undoLast());
    uibutton(eg, 'Text', 'Xoá nốt đang chọn', 'ButtonPushedFcn', @(~,~) deleteSelected());
    uibutton(eg, 'Text', 'Xoá hết', 'FontColor', [0.7 0 0], ...
             'ButtonPushedFcn', @(~,~) clearAll());

    statusBox = uitextarea(right, 'Editable', 'off', 'FontSize', 13);

    ax = uiaxes(right);
    title(ax, 'Dạng sóng (bấm Phát để vẽ)');
    xlabel(ax, 'Thời gian (s)');
    ylabel(ax, 'Biên độ');
    grid(ax, 'on');

    % Hien thi trang thai ban dau
    updatePreview();
    refresh();

    % ======================= CALLBACKS: NHAP BAN NHAC =======================

    function updatePreview()
        % Dong "Sap them: ..." de biet truoc not sap bam se o quang nao, truong do nao
        previewLbl.Text = sprintf('Sắp thêm:  quãng %s  -  nốt %s', ...
            octGroup.SelectedObject.Text, durGroup.SelectedObject.Text);
    end

    function addNote(name)
        type = durGroup.SelectedObject.Tag;
        if strcmp(name, 'R')
            full = 'R';                                 % dau lang khong can quang tam
        else
            full = [name octGroup.SelectedObject.Text]; % vi du 'C#' + '4' = 'C#4'
        end
        score(end+1) = struct('note', full, 'type', type);
        selRow = [];
        refresh();
        scroll(tbl, 'bottom');                          % tu cuon xuong not vua them
    end

    function undoLast()
        if ~isempty(score)
            score(end) = [];
            selRow = [];
            refresh();
        end
    end

    function onSelect(~, event)
        if isempty(event.Indices)
            selRow = [];
        else
            selRow = event.Indices(1, 1);
        end
    end

    function deleteSelected()
        if isempty(selRow) || selRow > numel(score)
            uialert(fig, 'Hãy bấm chọn một dòng trong bảng trước.', 'Chưa chọn nốt', ...
                    'Icon', 'info');
            return;
        end
        score(selRow) = [];
        selRow = [];
        refresh();
    end

    function clearAll()
        if isempty(score), return; end
        choice = uiconfirm(fig, 'Xoá toàn bộ bản nhạc?', 'Xác nhận', ...
                           'Options', {'Xoá', 'Huỷ'}, 'DefaultOption', 2, 'CancelOption', 2);
        if strcmp(choice, 'Xoá')
            score = struct('note', {}, 'type', {});
            selRow = [];
            refresh();
        end
    end

    function refresh()
        % Cap nhat bang + dong trang thai moi khi ban nhac hoac thiet lap thay doi
        timeSig = sigDD.Value;
        K = numel(score);
        T = scoreTiming(score, timeSig);

        % ---- Bang danh sach not ----
        data = cell(K, 5);
        for k = 1:K
            if strcmp(score(k).note, 'R')
                noteTxt = 'Lặng';
            else
                noteTxt = score(k).note;
            end
            data{k, 1} = k;
            data{k, 2} = noteTxt;
            data{k, 3} = typeLabels{strcmp(typeCodes, score(k).type)};
            data{k, 4} = T.measure(k);
            data{k, 5} = num2str(T.beatInMeasure(k));
        end
        tbl.Data = data;

        % ---- To mau: o nhip chan to xam nhat, not vat vach nhip to do ----
        removeStyle(tbl);
        evenRows = find(mod(T.measure, 2) == 0);
        if ~isempty(evenRows)
            addStyle(tbl, uistyle('BackgroundColor', [0.93 0.93 0.93]), 'row', evenRows(:)');
        end
        if ~isempty(T.crossBarline)
            addStyle(tbl, uistyle('BackgroundColor', [1 0.8 0.8]), 'row', T.crossBarline(:)');
        end

        % ---- Dong trang thai ----
        if K == 0
            statusBox.Value = {'Bản nhạc đang trống. Hãy bấm tên nốt để bắt đầu.'};
            return;
        end
        durSec = T.totalBeats * 60 / tempoSp.Value;
        lines = {sprintf('Tổng: %d nốt  |  %g phách  |  %d ô nhịp (%d/4)  |  Thời lượng: %.2f giây', ...
                         K, T.totalBeats, T.nMeasures, timeSig, durSec)};
        if ~T.lastMeasureFull
            lines{end+1} = sprintf('Cảnh báo: ô nhịp cuối mới có %g / %d phách.', ...
                                   T.lastMeasureBeats, timeSig);
        end
        if ~isempty(T.crossBarline)
            lines{end+1} = sprintf('Cảnh báo: nốt số %s vắt qua vạch nhịp (tô đỏ trong bảng).', ...
                                   strjoin(arrayfun(@num2str, T.crossBarline(:)', ...
                                                    'UniformOutput', false), ', '));
        end
        if numel(lines) == 1
            lines{end+1} = 'Bản nhạc khớp với nhịp đã chọn.';
        end
        statusBox.Value = lines;
    end

    % ===================== CALLBACKS: PHAT / XUAT FILE ======================

    function [y, ok] = renderCurrent()
        % Bien ban nhac thanh am thanh theo thiet lap hien tai, roi ve dang song
        y = [];
        ok = false;
        if isempty(score)
            uialert(fig, 'Bản nhạc đang trống.', 'Chưa có nốt', 'Icon', 'info');
            return;
        end
        oldWarn = warning;                           % tat canh bao o Command Window
        warning('off', 'renderScore:incomplete');    % (giao dien da hien canh bao roi)
        warning('off', 'renderScore:cross');
        try
            y = renderScore(score, tempoSp.Value, sigDD.Value, lower(modeSw.Value), fs);
            ok = true;
        catch err
            uialert(fig, err.message, 'Lỗi khi tạo nhạc');
        end
        warning(oldWarn);
        if ok
            plotWave(y);
        end
    end

    function plotWave(y)
        % Ve dang song + vach chia o nhip + vach do chay theo nhac
        t = (0:numel(y)-1) / fs;
        hold(ax, 'off');
        plot(ax, t, y, 'Color', [0 0.45 0.74]);
        hold(ax, 'on');

        beatSec = 60 / tempoSp.Value;
        timeSig = sigDD.Value;
        T = scoreTiming(score, timeSig);
        for m = 1:T.nMeasures
            xline(ax, (m-1) * timeSig * beatSec, ':', num2str(m), ...
                  'Color', [0.4 0.4 0.4], 'LabelVerticalAlignment', 'bottom');
        end
        cursor = xline(ax, 0, 'r', 'LineWidth', 1.5, 'Visible', 'off');
        hold(ax, 'off');

        xlim(ax, [0 t(end)]);
        ylim(ax, [-1 1]);
        title(ax, sprintf('Dạng sóng  -  %d/4, tempo %d, %s', ...
                          timeSig, tempoSp.Value, modeSw.Value));
    end

    function playAudio()
        stopAudio();                                 % dang phat bai cu thi dung truoc
        [y, ok] = renderCurrent();
        if ~ok, return; end
        player = audioplayer(y, fs);
        player.TimerPeriod = 0.05;                   % cap nhat vach do moi 50 ms
        player.TimerFcn = @(~,~) moveCursor();
        player.StopFcn  = @(~,~) hideCursor();
        cursor.Visible = 'on';
        play(player);
    end

    function stopAudio()
        if ~isempty(player) && isvalid(player)
            player.TimerFcn = '';                    % go callback truoc khi dung
            player.StopFcn  = '';                    % de khong anh huong lan phat sau
            stop(player);
        end
        hideCursor();
    end

    function moveCursor()
        if ~isempty(cursor) && isvalid(cursor) && ~isempty(player) && isvalid(player)
            cursor.Value = player.CurrentSample / fs;
        end
    end

    function hideCursor()
        if ~isempty(cursor) && isvalid(cursor)
            cursor.Visible = 'off';
        end
    end

    function exportWav()
        [y, ok] = renderCurrent();
        if ~ok, return; end
        [f, p] = uiputfile('*.wav', 'Lưu file âm thanh', 'bannhac.wav');
        figure(fig);                                 % dua cua so app len lai
        if isequal(f, 0), return; end
        audiowrite(fullfile(p, f), y, fs);
        uialert(fig, ['Đã lưu file: ' fullfile(p, f)], 'Xong', 'Icon', 'success');
    end

    % ===================== CALLBACKS: LUU / MO BAN NHAC =====================

    function saveScore()
        if isempty(score)
            uialert(fig, 'Bản nhạc đang trống.', 'Chưa có nốt', 'Icon', 'info');
            return;
        end
        [f, p] = uiputfile('*.mat', 'Lưu bản nhạc', 'bannhac.mat');
        figure(fig);
        if isequal(f, 0), return; end
        S.score    = score;
        S.tempo    = tempoSp.Value;
        S.timeSig  = sigDD.Value;
        S.playMode = lower(modeSw.Value);
        save(fullfile(p, f), '-struct', 'S');
        uialert(fig, ['Đã lưu bản nhạc: ' fullfile(p, f)], 'Xong', 'Icon', 'success');
    end

    function loadScore()
        [f, p] = uigetfile('*.mat', 'Mở bản nhạc');
        figure(fig);
        if isequal(f, 0), return; end
        S = load(fullfile(p, f));
        try
            assert(isfield(S, 'score') && isstruct(S.score) && ...
                   all(isfield(S.score, {'note', 'type'})), ...
                   'File không chứa bản nhạc hợp lệ (thiếu biến score).');
            for k = 1:numel(S.score)             % kiem tra tung not truoc khi nhan
                noteBeats(S.score(k).type);
                if ~strcmp(S.score(k).note, 'R')
                    noteFreq(S.score(k).note);
                end
            end
        catch err
            uialert(fig, err.message, 'Không mở được file');
            return;
        end
        stopAudio();
        score = S.score(:)';
        if isfield(S, 'tempo'),   tempoSp.Value = S.tempo;   end
        if isfield(S, 'timeSig'), sigDD.Value   = S.timeSig; end
        if isfield(S, 'playMode')
            if strcmpi(S.playMode, 'staccato')
                modeSw.Value = 'Staccato';
            else
                modeSw.Value = 'Legato';
            end
        end
        selRow = [];
        refresh();
    end

    function sendToWorkspace()
        % Dua ban nhac ra Workspace de thu nghiem bang lenh
        if isempty(score)
            uialert(fig, 'Bản nhạc đang trống.', 'Chưa có nốt', 'Icon', 'info');
            return;
        end
        assignin('base', 'score',    score);
        assignin('base', 'tempo',    tempoSp.Value);
        assignin('base', 'timeSig',  sigDD.Value);
        assignin('base', 'playMode', lower(modeSw.Value));
        uialert(fig, 'Đã gửi 4 biến ra Workspace: score, tempo, timeSig, playMode.', ...
                'Đã gửi', 'Icon', 'success');
    end

    function onClose()
        stopAudio();
        delete(fig);
    end
end
