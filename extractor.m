% EXTRACTOR         UI for spike extraction (A*.mat->E*.mat).
%
%                   input is up to four analogue channels sampled
%                   at FsKHz KHz.
%                   output is user determined vector of thresholds in std.
%
%                   see also EXTRACT.

% 28-sep-02 ES
% 30-sep-02 modifications (MSF format)
% 01-oct-02 bug in TH margins fixed
% 27-aug-03 UI more permissible of errors
% 01-sep-03 3 beeps

function TH = extractor(X1,X2,X3,X4,FsKHz,names,th_buf)

if nargin<5 | isempty(FsKHz), FsKHz = 25; end
if nargin<6 | isempty(names), names = 1:4; end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% constants
%
FS = 2^12;                      % frame size (samples)
if exist([th_buf '.mat'])
    load(th_buf);
else
    TH = ones(4,1)*4.5;% default TH (std)
end
sp = 1;                         % first sample
YLIM = [-10000 10000];          % for waveform plots
XLIM = [0 64];                  % "
tstr = sprintf('MCP %d-%d',names(1),names(end));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% initialization
%
clc
if nargin>=1, 
    disp('initializing channel 1...')
    LX1 = length(X1); 
    X1d2 = extract(X1,TH(1),FsKHz,[],'D2_only');
    X1d2_mean = mean(X1d2);
    X1d2_std = std(X1d2);
    clear X1d2;
else LX1 = 0; end
if nargin>=2, 
    disp('initializing channel 2...')
    LX2 = length(X2); 
    X2d2 = extract(X2,TH(1),FsKHz,[],'D2_only');
    X2d2_mean = mean(X2d2);
    X2d2_std = std(X2d2);
    clear X2d2;
else LX2 = 0; end
if nargin>=3, 
    disp('initializing channel 3...')
    LX3 = length(X3); 
    X3d2 = extract(X3,TH(1),[],FsKHz,'D2_only');
    X3d2_mean = mean(X3d2);
    X3d2_std = std(X3d2);
    clear X3d2;
else LX3 = 0; end
if nargin>=4, 
    disp('initializing channel 4...')
    LX4 = length(X4); 
    X4d2 = extract(X4,TH(1),[],FsKHz,'D2_only');
    X4d2_mean = mean(X4d2);
    X4d2_std = std(X4d2);
    clear X4d2;
else LX4 = 0; end
disp('initialization done.')
for i=1:4,
	n=num2str(i);
	f=eval(['X' n]);
	if length(f)>0
		X=f;
	end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% menu
%
MEN0 = sprintf('Frame size is %d\n',FS);
MEN1 = sprintf('At each iteration, select one of the following and hit Enter\n');
SEP = sprintf('*******************************************************************************\n');
MEN2 = sprintf('Number (1-4) => modify TH of that channel\n');
MEN3 = sprintf('''b''          => go back one frame\n');
MEN4 = sprintf('''e''          => extract (and save TH) \n');
MEN5 = sprintf('''q''          => quit (and save TH) without extraction\n');
MEN6 = sprintf('Enter        => next frame\n');
disp([SEP MEN0 MEN1 SEP MEN2 MEN3 MEN4 MEN5 MEN6 SEP])
beep, pause( 0.5 ), beep, pause( 0.5 ), beep, pause( 0.5 )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% UI
%
f1 = figure(1); clf(f1);
set(f1,'Position',[1 29 1024 672],'Name',tstr);
while sp < length(X) %!!!1
    clf
    figure(1)
    ep = min([(sp + FS - 1) length(X)]); %!!!1
  
    if ep<=LX1, 
        X1mm = X1d2_mean + [-1 1]*TH(1)*X1d2_std;
        extract(X1(sp:ep),X1mm,FsKHz,1,'D2_a2d');
    end
    if ep<=LX2, 
        X2mm = X2d2_mean + [-1 1]*TH(2)*X2d2_std;
        extract(X2(sp:ep),X2mm,FsKHz,2,'D2_a2d');
    end
    if ep<=LX3, 
        X3mm = X3d2_mean + [-1 1]*TH(3)*X3d2_std;
        extract(X3(sp:ep),X3mm,FsKHz,3,'D2_a2d');
    end
    if ep<=LX4, 
        X4mm = X4d2_mean + [-1 1]*TH(4)*X4d2_std;
        extract(X4(sp:ep),X4mm,FsKHz,4,'D2_a2d');
    end
    ui = input([sprintf('Samples %d-%d          ',sp,ep)],'s');
    switch lower(ui)
        case {'q','e'}
            break
        case 'k'
            keyboard
        case 'b'
            sp = sp - 2*FS;
            if sp < 1 - FS, sp = 1; end
        otherwise
            elec = str2num(ui);
            if elec,
                if elec<1 | elec>nargin, 
                    disp(['        channel number should be 1-' num2str(nargin)])
                else
                    TH(elec) = extract_UI(TH(elec),elec);
                    sp = sp - FS;
                end
            end
    end
    sp = sp + FS;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%


%%here I chose to end the program because I only wanted to get the new
%%thresholds, the following code I added therefore displays the new
%%thresholds and ends the function:



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(sprintf('\n'))
disp(sprintf('Final values:\n'))
disp(sprintf('Channel 1 - TH = %0.2g\n',TH(1)))
disp(sprintf('Channel 2 - TH = %0.2g\n',TH(2)))
disp(sprintf('Channel 3 - TH = %0.2g\n',TH(3)))
return


% extraction
%
Y1 = []; Y2 = []; Y3 = []; Y4 = [];
if isempty(ui) | lower(ui)~='q'
    L = sprintf('\n');
    SUM0 = sprintf('Final values:\n');
    SUM1 = sprintf('Channel 1 - TH = %0.2g\n',TH(1));
    SUM2 = sprintf('Channel 2 - TH = %0.2g\n',TH(2));
    SUM3 = sprintf('Channel 3 - TH = %0.2g\n',TH(3));
    SUM4 = sprintf('Channel 4 - TH = %0.2g\n',TH(4));
    SUM5 = 'Extract spikes? (y/n)\n';
    user = input([L SEP SUM0 SUM1 SUM2 SUM3 SUM4 SEP SUM5],'s');
    if lower(user)=='y'
        disp(['Channel 1 (TH = ' num2str(TH(1)) ')...']), 
        [Y1 T1] = extract(X1,TH(1),FsKHz,0,'D2'); 
        if LX2, 
            disp(['Channel 2 (TH = ' num2str(TH(2)) ')...']), 
            [Y2 T2] = extract(X2,TH(2),FsKHz,0,'D2'); 
        end
        if LX3, 
            disp(['Channel 3 (TH = ' num2str(TH(3)) ')...']), 
            [Y3 T3] = extract(X3,TH(3),FsKHz,0,'D2'); 
        end
        if LX4, 
            disp(['Channel 4 (TH = ' num2str(TH(4)) ')...']), 
            [Y4 T4] = extract(X4,TH(4),FsKHz,0,'D2'); 
        end
        % raster
        ui = input('plot rasters? (y/n)   ','s');
        if lower(ui)=='y'
            st = {T1, T2, T3, T4};
            figure, raster(st,[],[],'lines'); set(gca,'YTick',[1:4]), 
            xlabel('ms'), ylabel('channel')
            set(gcf,'Name',tstr); title(tstr,'FontSize',8,'Color',[0 0 1]);
        end
        % waveforms
        ui = input('plot waveforms? (y/n)   ','s');
        if lower(ui)=='y'
            figure, set(gcf,'Name',tstr);
            
            subplot(2,2,1), plot(Y1)
            title(['channel 1 waveforms; ' num2str(size(Y1,2)) ' spikes'],'FontSize',8,'Color',[0 0 1])
            set(gca,'YLim',YLIM,'XLim',XLIM,'XTickLabel',[],'YTickLabel',[])
            subplot(2,2,2), plot(Y2)
            title(['channel 2 waveforms; ' num2str(size(Y2,2)) ' spikes'],'FontSize',8,'Color',[0 0 1])
            set(gca,'YLim',YLIM,'XLim',XLIM,'XTickLabel',[],'YTickLabel',[])
            subplot(2,2,3), plot(Y3)
            title(['channel 3 waveforms; ' num2str(size(Y3,2)) ' spikes'],'FontSize',8,'Color',[0 0 1])
            set(gca,'YLim',YLIM,'XLim',XLIM,'XTickLabel',[],'YTickLabel',[])
            subplot(2,2,4), plot(Y4)
            title(['channel 4 waveforms; ' num2str(size(Y4,2)) ' spikes'],'FontSize',8,'Color',[0 0 1])
            set(gca,'YLim',YLIM,'XLim',XLIM,'XTickLabel',[],'YTickLabel',[])
        end
        input('Done; Enter to continue')
    else
        disp('quit without extracting.')
    end
end

return 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function new_TH = extract_UI(TH,elec)

max_TH = 10;
min_TH = 2;

msg = sprintf('        Enter new threshold for channel %d (TH = %0.3g std)\t',elec,TH);
new_TH = input(msg);
if new_TH > max_TH | new_TH < min_TH
    disp(['        threshold should be between ' num2str(min_TH)...
            ' and ' num2str(max_TH)])
    new_TH = extract_UI(new_TH,elec);
end

return