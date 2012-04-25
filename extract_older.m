% EXTRACT           extract spike times and waveforms from analogue alphamap data.
%
%           [Y T] = EXTRACT(X,TH,GRAPHICS,MODE)
%
%           input is a single vector X, sampled at Fs KHz
%
%           graphics:   0 doesn't plot (default)
%                       1/2/3/4 plots at the specified column of current fig
%           TH          4.5 std (default)
%                       scalar, in units of std (if mode is 'D2' or 'D2_only')
%                       vector of 2 elements (if mode is 'D2_a2d')
%           mode        'D2' (default)
%                       'D2_only' - returns second derivative in a2d units as Y
%                       'D2_a2d'  - uses the TH argument as is (in a2d units)
%
%           output is a matrix of waveforms (columns) and a vector of times (samples)
%
%           algorithm is Moshe's, based on a modified second derivative, 
%               without statistics update. we assume that consecutive calls
%               are made to this function for a given given channel,
%               therefore the computations are temporally local
%
%           see also PARSE.

% 3-Jul-02 ES

% revisions
% 28-sep-02 modifications
% 30-sep-02 modifications to MSF format of return values; dc removal and detrending
% 17-may-03 SB 7 -> 11

function [Y, T] = extract(x,TH,Fs,graphics,mode);

if nargin<2 | isempty(TH), TH = 4.5; end                        % standard deviations
if nargin<3 | isempty(Fs), Fs = 25; end                         % sampling rate in KHz
if nargin<4 | isempty(graphics), graphics = 0; end
if nargin<5 | isempty(mode), mode = 'D2'; end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% constants
%
K = 7;                                                          % derivative backward
L = 11;                                                         % derivative forward
S = 64;                                                         % total number of points to save
SB = 21 %possible better 21;                                                         % number of poitns to save backwards
DT = 30;                                                        % in samples - changed 30-sep-02
A2DR = 3^16 ;%; !!!!!!     max(x)*4                                               % a2d range
newspike = 0;
x=(((x+5)/10)*2^16)-2^15;   %!!!

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% extraction
%
Y = []; Tsam = [];
x2 = x(K+1:end-L) - (x(1:end-L-K) + x(1+L+K:end))/2;            % approx. x''
switch mode
    case 'D2_only'
        Y = x2; return
    case 'D2'
        mmx2 = mean(x2) + [-1 1]*TH*std(x2);                            % statistics
    case 'D2_a2d'
        mmx2 = TH;
end
pts = sortrows([parse(find(x2<mmx2(1))); parse(find(x2>mmx2(2)))]);
j = 0; spv = 0; spt = 0;
for i = 1:size(pts,1) %rows
    ptv = x2(pts(i,1):pts(i,2));                                % potential values
    sgn = unique(sign(ptv));                                    % for negative TH crossing
    spv_new = max(sgn*ptv);                                     % sometimes already clipped
    spt_new = pts(i,1)-1+min(find(ptv==sgn*spv_new));           % time of maximal value
    if spt_new > spt + DT                                       % ARP | DT
        j = j + 1;  
        newspike = 1;
    elseif spv_new > spv & j >0                                 % WTA
        newspike = 1;
    end
    if newspike                                                 % save time and waveform
        spv = spv_new; spt = spt_new; newspike = 0;
        waveform = x(spt+K-SB+1:min([spt+K+S-SB length(x)]));
        if length(waveform)==S, Y(:,j) = waveform'; Tsam(j) = spt+K; end
%         Y(j) = struct('time',spt+K...
%             ,'waveform',x(spt+K-SB+1:min([spt+K+S-SB length(x)])));
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% MSF format - time in seconds, dc removal, detrending
%
if graphics, Yraw = Y; end
T = Tsam(:)/Fs/1000;                                            % spike times in seconds
M = size(Y,1);
N = size(Y,2);
n = (M-1)/2;
dc = ones(1,M);
dc = dc/norm(dc);
m = dc*Y;
for i=1:N                                                       % dc removal
    Y(:,i) = Y(:,i) - m(i)*dc'; 
end
tr = [-(M-1)/2:(M-1)/2];
tr = tr/norm(tr);
m = tr*Y;
for i=1:N                                                       % detrend
    Y(:,i) = Y(:,i) - m(i)*tr';
end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% graphics
%
if graphics
    % constants
    MARG = 0.03;
    XLEN = 0.5;    %was .25 for 4 elec...
    YLEN = 0.3;
    YTOP = 0.7;     
    YBOT = 0.4;
    FS = 7;         
    TFS = 8;
    % axes
    switch graphics
        case 1, XY = [0 YTOP; 0 YBOT];
        case 2, XY = [0.5 YTOP; 0.5 YBOT]; %was 0,25 instead of 0.5
        case 3, XY = [0.5 YTOP; 0.5 YBOT];
        case 4, XY = [0.75 YTOP; 0.75 YBOT];
        case 5, figure
        otherwise, error('graphics should be 1-4'),
    end
    if graphics == 5
        ah1 = subplot( 2, 1, 1 );
        ah2 = subplot( 2, 1, 2 );
    else
        ah1 = axes('position',[XY(1,:)+MARG XLEN-2*MARG YLEN-2*MARG]);
        ah2 = axes('position',[XY(2,:)+MARG XLEN-2*MARG YLEN-2*MARG]);
    end
    % waveform
    subplot(ah1), plot(x), title(['channel ' num2str(graphics)],'FontSize',TFS,'Color',[0 0 1])
    for i = 1:N
        hold on
        WF = Yraw(:,i); %WF = [Y(i).waveform];
%        WFT = [Y(i).time - SB + 1:1:Y(i).time - SB + S];
        WFT = [Tsam(i) - SB + 1:1:Tsam(i) - SB + S];
        WFT = WFT(1:length(WF));
        plot(WFT,WF,'r')
    end
    set(ah1,'YLim',[-A2DR/2 A2DR/2],'XLim',[0 length(x2)]);
    set(ah1,'FontSize',FS)
    % second derivative
    subplot(ah2), plot(x2)
    title(['TH = ' num2str(TH)],'FontSize',TFS,'Color',[0 0 1])
    for i = 1:N
        hold on % just draw a line
        plot((Tsam(i) - K)*[1 1], mmx2,'r')
    end
    hold on, plot([1 length(x2)],[mmx2(2) mmx2(2)],'r')
    plot([1 length(x2)],[mmx2(1) mmx2(1)],'r'), hold off
    set(ah2,'YLim',[-A2DR/2 A2DR/2],'XLim',[0 length(x2)]);
    set(ah2,'FontSize',FS)
    
end