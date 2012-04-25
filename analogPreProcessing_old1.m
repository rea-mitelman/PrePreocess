function analogPreProcessing(home_dir,day_path,fstr,channels,TH_mode,mode)


%directories and files issues
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('*********************************************************');
disp(['pre-processing analog spikes of file ' fstr ':']);
parent_dir = sprintf('%s\\%s',home_dir,day_path);
status = mkdir(parent_dir,'msf');
if ~status, disp(['problem creating directory: ' num2str(status)]), end
fbufES = sprintf('%s\\%s\\msf\\E%sS_%s',home_dir,day_path,fstr(2:end-7),fstr(end-6:end-4));
if ~status, disp(['problem creating directory: ' num2str(status)]), end
status = mkdir(parent_dir,'param_sp');
th_buf = sprintf('%s\\param_sp\\TH',parent_dir);
fbuf = sprintf('%s\\%s\\%s',home_dir,day_path, fstr);
rep=findstr(fbuf,'wvf');
fbuf2=[fbuf(1:rep-1) 'bhv' fbuf(rep+3:end)];
disp('     loading file...')
load(fbuf);
%load(fbuf2);
%pause
if mode==1    
    tmp=Unit11;
    for i=1:length(STIM)
        Unit11(STIM(i):STIM(i)+99)=0;
    end
end
chanstr='Unit';
%detection threshold
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch TH_mode
    case 0 %auto from existing file
        load(th_buf)
    case 1 %manual set of threshold and save(overwrite existing)
        
        for j=channels
            datastr{j} = sprintf('%s%d%s',chanstr,j,'1');
        end
        eval(['TH = extractor(' datastr{1} ',' datastr{2}  ',[],[],' datastr{1} '_KHz,channels, th_buf);']);
        TH=TH(channels);
        save(th_buf,'TH');
end
clear datastr;
%extraction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if TH_mode==1
    ask=questdlg('Do you want to extract spikes and to save MSF for current file? (warning - it may take a long time)','Proceed to Extract','Yes','No','No');
    if strcmp(ask,'No')
         return
    end
end

MAT = [];
for j = channels
    %datastr = sprintf('%s%d%s',chanstr,j,'1');
    datastr = sprintf('%s%d',chanstr,j);
    retstr = ['0' int2str(j)]; 
    if exist(datastr)
        temp=eval(datastr);
        disp('          spikes...')
        eval(['[TDATA_MCP_' retstr ' TIME_MCP_' retstr '] = extract(temp, ' num2str(TH(j)) ',' datastr '_KHz);']);
        datastring=datastr;
        indx=j;
        eval(['FsKHz(j) = ' datastr '_KHz;']);
        if eval(['~isempty(TIME_MCP_' retstr ')'])
            eval(['MAT = [MAT; [repmat(j,length(TIME_MCP_' retstr '),1) TIME_MCP_' retstr ' TDATA_MCP_' retstr ''']];']);
        end
    %eval(['clear ' datastr '*']);
    end
end

%%saving in MSF format
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if length(unique(FsKHz))~=1, disp('different Fs for different channels! ! !'), end
Fs = FsKHz(indx)*1000; %changed because it had to fit to the case when there is only channel 2
%Fs = FsKHz(1)*1000;
M = sortrows(MAT,2);
chan = M(:,1);
time = M(:,2);
tdata = M(:,3:66)';
SizeElec = 1;
startData = 0;
%endData = analogueBlockLength/1000;
%datastr1=sprintf('%s%d%s',chanstr,1,'1');datastr2=sprintf('%s%d%s',chanstr,1,'1_KHz');
%datastr1=sprintf('%s%d',chanstr,1);datastr2=sprintf('%s%d%s',chanstr,1,'_KHz');
datastr1=datastring;datastr2=sprintf('%s%s',datastring,'_KHz');
endData=length(eval(datastr1))/(1000*eval(datastr2));
samplingInterval = 1/Fs;
save(fbufES,'chan','time','tdata','SizeElec','startData','endData','samplingInterval')
clear TDATA_MCP*; clear TIME_MCP*; clear Fs;
disp('     saved extracted matlab spikes file (MSF).');