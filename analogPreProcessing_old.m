function analogPreProcessing(home_dir,day_path,fstr,channels,TH_mode)


chanstr='Unit';
%directories and files issues
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('*********************************************************');
disp(['pre-processing analog spikes of file ' fstr ':']);
parent_dir = sprintf('%s\%s',home_dir,day_path);
status = mkdir(parent_dir,'msf');
if ~status, disp(['problem creating directory: ' num2str(status)]), end
fbufES = sprintf('%s\\%s\\msf\\E%sS_%s',home_dir,day_path,fstr(2:end-7),fstr(end-6:end-4));
if ~status, disp(['problem creating directory: ' num2str(status)]), end
status = mkdir(parent_dir,'param_sp');
th_buf = sprintf('%s\\param_sp\\TH',parent_dir);
fbuf = sprintf('%s\\%s\\%s',home_dir,day_path, fstr);
disp('     loading file...')
load(fbuf);
%pause

%detection threshold
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch TH_mode
    case 0 %auto from existing file
        load(th_buf)
    case 1 %manual set of threshold and save(overwrite existing)
        
        for j=channels
            datastr{j} = sprintf('%s%d%s',chanstr,j);%!!,'1'j
			%if ~exist(datastr),  %!!!!!!!!
				%datastr=['Units']; %!!!
				%end
        end
		cmnd = ['TH = extractor( [], ' datastr{2} ', ' datastr{3} ', [],' datastr{2} '_KHz' ', channels,  th_buf);'];%!!!!
        eval( cmnd ); %!!! ',' ',[],[],[],' 
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
 flgg=[]; %!!!!
 %channels=1;
MAT = [];
for j = 1:size(channels,2)
% 	while isempty(flg)
 		datastr = sprintf('%s%d',chanstr,2); %%      '' !!!!%s, '1' j
 		retstr = ['0' int2str(j)]; 
		
		if ~exist(datastr),
			datastr=['Units'];
			retstr=['00'];
			flgg=1;
			THh=TH;
			TH=[];
			TH=THh(2,1)
		end
		
		temp=eval(datastr);
		disp('          spikes...')
		eval(['[TDATA_MCP_' retstr ' TIME_MCP_' retstr '] = extract(temp, ' num2str(TH(j)) ',' datastr '_KHz);']);
		eval(['FsKHz(j) = ' datastr '_KHz;']);
		if eval(['~isempty(TIME_MCP_' retstr ')'])
			eval(['MAT = [MAT; [repmat(j,length(TIME_MCP_' retstr '),1) TIME_MCP_' retstr ' TDATA_MCP_' retstr ''']];']);
		end
		%%eval(['clear ' datastr '*']);
		%flg=1;
		%end
end

%%saving in MSF format
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if length(unique(FsKHz))~=1, disp('different Fs for different channels! ! !'), end
Fs = FsKHz(1)*1000;
if ~isempty(MAT);  %%%%!!!!!
	M = sortrows(MAT,2);
	chan = M(:,1);
	time = M(:,2);
	tdata = M(:,3:66)';
	SizeElec = 1;
	startData = 0;
	% %endData = analogueBlockLength/1000;
	if flgg,
		datastr1=['Units']; datastr2=['Units_KHz'];
	else
		datastr1=sprintf('%s%d',chanstr,2);datastr2=sprintf('%s%d%s',chanstr, 2,  '_KHz');  %%%   %s,'1'',1,
	end
	endData=length(eval(datastr1))/(1000*eval(datastr2));
	samplingInterval = 1/Fs;
	save(fbufES,'chan','time','tdata','SizeElec','startData','endData','samplingInterval')
	clear TDATA_MCP*; clear TIME_MCP*; clear Fs;
	disp('     saved extracted matlab spikes file (MSF).');
else
	disp(['  problem extracting spikes in file: ' fbuf])  
end