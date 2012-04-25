% TPPREP            automated version of NL_Tpprep.

% 07-sep-03 ES

function [quitProg] = Tpprep(inname,outname,pcvec,wchan,nelectrodes,upsamp_Fs)

% project data on principal components.
%
%   name1 - input file that holds the raw data as produced by hbf2mat.
%   name2 - output file that holds the pc projections, and the offsets.
%   name2dir - output directory that holds the pc projections, and the offsets. 
%   pcvec - holds the pcs themselves.
%   wchan - array of channels that we are interested in.
%         If the size of this array is bigger than one it means either 
%         that we have a multi electrode setup and the channels are 
%         properly interleaved in the raw data, or data was sorted and 
%         channels are sorter output.
%   nelectrodes - tells us which of the above two Options is correct by telling
%         how many electrodes we had.
%  upsamp_Fs - the sampling frequency of PCs in KHz, i.e. the destination Fs for
%  the upsampling procedure. This changes "fold" which was fixed,
%  regardless of the original Fs.

% Canceled:
% %   fold - a number that tells the ratio between the pcs resolution and the
% %         data resolution.

%save results in name2. contain pcs (the matrix of the components
% and offset (the index of the first overlaping sample
% in the unfolded pulse(i.e. high resolution).
% Checked for exist statements (MATLAB6 compatability YBS 1/7/01)

quitProg = 0;

channels=length(wchan);
startData=[];
endData=[];
try
    load(inname);
catch
    errstr{1} = ['Could not load MSF file ' inname ];
    errstr{2} = ['Projection Aborted'];
    errordlg(errstr,'ALPHASORT Pre Processor');  
    quitProg = 2;
    return
end    
fold=upsamp_Fs*samplingInterval*1000;

% Update progress bar and Check if the cancel button was clicked.
THISPOS = 5/100;                
%%set(handles.progress_patch,'xdata',[0 0 THISPOS THISPOS])   
%%NL_quit_pp_scr;
if quitProg     return;   end


if exist('chan')==0
    return
end
%chan=chan+1;%!!!!!
% take only spikes that are relevant to channels.
relevant=find(any((chan*ones(1,channels+1)==ones(length(chan),1)*[-100 wchan])'));
% the -100 is added to ensure matrix and not vector operation.
chan=chan(relevant);
time=time(relevant);
if exist('template')==1 
    template=template(relevant);
end   
tdata=tdata(:,relevant);
numSpikes=length(relevant);
% skip if none found (MA Feb-1998)
if numSpikes==0
    return
end

%multiply pcvec nelc times and normalize
norma=cumsum(pcvec.*pcvec);
norma=norma(size(norma,1),:); % norm of each colon
norma=sqrt(norma);
norma=ones(size(pcvec,1),1)*norma;

pcvec=pcvec./norma;
pcoff=zeros(size(tdata,2)/nelectrodes,1);
pcs=zeros(size(pcvec,2),size(tdata,2));
upsamp_spk_shapes=zeros(size(pcvec,1),size(tdata,2));
quota=floor(300/nelectrodes); % to avoid large memory bulks we do quota spikes at a time
index=1:quota:(size(tdata,2)/nelectrodes+1);
if(index(length(index))<size(tdata,2)/nelectrodes+1)
    index(length(index)+1)=size(tdata,2)/nelectrodes+1;
end

% It is inside this loop that the program spends the most time- and thus the progress bar is upadted here.
% This stage is approximately 90 percent long ( of this function).
CANCEL_INC = 100; % we check the cancel button every 100 lines.
PROGRESS_INC = ceil(length(index)/90);
for i=1:length(index)-1;
    
  % Check if the cancel button was clicked.
    if ~rem(i,CANCEL_INC)
%%        NL_quit_pp_scr;
        if quitProg  return;  end
    end
    
    % Check if the cancel button was clicked.
    if ~rem(i,PROGRESS_INC)
        % Update the progress bar - this is approximately 5 precent.
        THISPOS = (5 + (i/length(index))*90)/100;                
%%        set(handles.progress_patch,'xdata',[0 0 THISPOS THISPOS])   
%%        drawnow
    end
    
    
    
    startT=index(i);   %Limits in tetrode spikes
    endT=index(i+1)-1;
    startS=startT*nelectrodes-nelectrodes+1; % Limits in spikes
    endS=endT*nelectrodes;
    [pcoff(startT:endT),pcs(:,startS:endS),upsamp_spk_shapes(:,startS:endS),aproxError(startT:endT)]=Bestoff(tdata(:,startS:endS),pcvec,nelectrodes,fold);% find offsets and pcs
end;
%rearange pcoff
aproxError=aproxError';
pcoff=pcoff(:);
pcoff=pcoff(:,ones(1,nelectrodes));
pcoff=pcoff';
pcoff=pcoff(:);

nchan=nelectrodes; % this is how it is called in tetplot

dv = sort( max(tdata,[],1) );
k = max( floor(length(dv)*0.95),1 );
maxScale = dv(k);
dv = sort( min(tdata,[],1) );
k = max( floor(length(dv)*0.05),1 );
minScale = dv(k);
axScale = [minScale maxScale];


try 
    if (exist('Trig')==1) & ~isempty(Trig) % Trig is array of inhibits input
        relevant=find(any((Trig(:,1)*ones(1,channels+1)==ones(length(Trig(:,1)),1)*[-100 wchan])'));
        Trig = Trig(relevant,:);
        if exist('template')==1
            save ( outname,'chan','time','template','pcs','tdata','axScale','pcoff','fold','pcvec','wchan'...
                ,'Trig','nchan','samplingInterval','aproxError','endData','startData','upsamp_spk_shapes') ;
        else
            save ( outname,'chan','time','pcs','tdata','axScale','pcoff','fold','pcvec','wchan'...
                ,'Trig','nchan','samplingInterval','aproxError','endData','startData','upsamp_spk_shapes') ;
        end               
    else    
        if exist('template')==1
            save ( outname,'chan','time','template','pcs','tdata','axScale','pcoff','fold','pcvec','wchan'...
                ,'nchan','samplingInterval','aproxError','endData','startData','upsamp_spk_shapes') ;
        else
            save ( outname,'chan','time','pcs','tdata','axScale','pcoff','fold','pcvec','wchan'...
                ,'nchan','samplingInterval','aproxError','endData','startData','upsamp_spk_shapes') ;
        end
    end
catch    
    quitProg = 2;
    errstr{1} = 'Could not save to disk file ' ;
    errstr{2} = [outname] ;
    errstr{3} = 'A possible cause may be that the disk is full' ;
    errstr{4} = 'If this is the case, clear disk space, and restart pre processing' ;                
    errordlg(errstr,'ALPHASORT Pre Processor')    
end


THISPOS = 1;                
%%set(handles.progress_patch,'xdata',[0 0 THISPOS THISPOS])   
%%drawnow

