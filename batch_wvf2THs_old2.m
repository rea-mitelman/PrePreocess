function batch_wvf2THs(home_dir,directory,files,mode)
n_elecs=4;
switch nargin
    case 1
        s=dir(home_dir);
        for i=1:size(s,1)
            bool(i)=isdir(s(i).name);
        end
        s=s(find(~bool));
        for j=1:size(s,1)
            str=sprintf('%s%s%s', num2str(j), ')  ', s(j).name);
            disp(str);
        end
        j=input('Enter array of number you like to process \nArray should be enclosed in square brackets and separated by spaces:  ');
        s=s(j);
        mode=0;
    case 4
        for i=1:length(directory)
            s(i).name=directory;
        end
end
%setting thresholds
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
q=questdlg('Do you want to manually set thresholds to selected sessions?','Set thresholds','Yes','Abort','Skip','Yes');
if strcmp(q,'Yes')
    %     flag=0;
    for j=1:size(s,1)
        day_path=s(j).name;
        if iscell(day_path)
            day_path=cell2mat(day_path);
        end
        disp(day_path);
        d=dir([home_dir '\' day_path '\' '*wvf.mat']);
        if nargin==4
            d=d(files);
        end
        list=round(size(d,1)*[0.2 0.4 0.6]);
        list=unique(list);
        %         range=1:size(d,1);
        %         if flag==0
        %             current_range=range;
        %         end
        %         bytes=0;
        %         for i=current_range
        %             if d(i).bytes>bytes
        %                 bytes=d(i).bytes;
        %                 longestFile=i;
        %             end
        %         end
        for i=1:length(list)
			analogPreProcessing(home_dir,day_path,d(list(i)).name,1:n_elecs,1);
        end
        %         ok=questdlg('Was the selected file a good representative?  (high S/N may not be good)','Verify Representative','Yes','No','Yes');
        %         if strcmp(ok,'No')
        %             flag=1;
        %             j=j-1;
        %             index=find(current_range==longestFile);
        %             current_range=current_range([1:index-1 index+1:length(current_range)]);
        %         else
        %             flag=0;
        %         end
    end
elseif strcmp(q,'Abort')
    return
end

%Proceeding to generate MSF files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
q=questdlg('Do you want to generate MSF files to the entire sessions with the thresholds selected?','Proceed to MSF','Yes','Abort','Skip','Yes');
if strcmp(q,'Yes')
    for j=1:size(s,1)
        day_path=s(j).name;
        if iscell(day_path)
            day_path=cell2mat(day_path);
        end
        disp(day_path);
		% 		d=dir([home_dir '\' day_path '\' '*wvf.mat']);
		d=dir([home_dir '\' day_path '\MAT\' '*wvf.mat']);
        if nargin==4
            d=d(files);
        end
        for k=1:size(d,1)
            %analogPreProcessing(home_dir,day_path,d(k).name,1:2,0,mode);
            %analogPreProcessing(home_dir,day_path,d(k).name,1:1,0,mode);
            analogPreProcessing(home_dir,day_path,d(k).name,1:n_elecs,0,mode);
        end
    end
elseif strcmp(q,'Abort')
    return
end


%Procced to MPF
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
q=questdlg('Do you want to generate MPF files to the entire sessions from the MSF file created?','Proceed to MPF','Yes','No','Yes');
if strcmp(q,'Yes')
    for j=1:size(s,1)
        day_path=s(j).name;
        if iscell(day_path)
            day_path=cell2mat(day_path);
        end
        if nargin==4
            call_Tpscript(home_dir,day_path,day_path,mode,files);
        else
            call_Tpscript(home_dir,day_path,day_path,0);
        end
    end
else
    %return
end


%Create unique Principle componenets to each subsession
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for j=1:size(s,1)
    day_path=s(j).name;
    if iscell(day_path)
        day_path=cell2mat(day_path);
    end
    load([home_dir day_path '\info\' day_path '_param']);%!!!.mat
    
    for k=1:length(SESSparam.SubSess)        
% 		disp('if SESSparam.SubSess(k).Files(2)-SESSparam.SubSess(k).Files(1)>2 OR >4???'); keyboard
        if SESSparam.SubSess(k).Files(2)-SESSparam.SubSess(k).Files(1)>0
            for chn=1:n_elecs
                flist=[];
                curPath=sprintf('%s%s\\elc_%02d\\',home_dir,day_path,chn);
                if exist(curPath) && ~isempty(dir([curPath 'E*']))
                    for l=SESSparam.SubSess(k).Files(1):SESSparam.SubSess(k).Files(2)
                        flist(l-SESSparam.SubSess(k).Files(1)+1).fnm=sprintf('%s%s\\elc_%02d\\E%s%03d%s%02d.mat',home_dir,day_path,chn,day_path(2:end),l,'__wvfpcsT',chn);
					end
					h=TemplatePreproc(flist,k,SESSparam.SubSess(k).Files,chn);
                    uiwait(h)
                end
            end
        end
    end
end

%Redo MPFs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
q=questdlg('Do you want to generate MPF files to the entire sessions from the MSF file created?','Proceed to MPF','Yes','No','Yes');
if strcmp(q,'Yes')
    for j=1:size(s,1)
        day_path=s(j).name;
        if iscell(day_path)
            day_path=cell2mat(day_path);
        end
        if nargin==4
            call_Tpscript(home_dir,day_path,day_path,mode,files);
        else
            call_Tpscript(home_dir,day_path,day_path,0);
        end
    end
else
    return
end
