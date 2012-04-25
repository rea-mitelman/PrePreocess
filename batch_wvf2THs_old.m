function batch_wvf2THs(home_dir)

s=dir(home_dir);
for i=1:size(s,1)
    bool(i)=isdir(s(i).name);
end
s1=s(find(~bool));
for j=1:size(s1,1)
    str=sprintf('%s%s%s', num2str(j), ')  ', s(j).name);
    disp(str);
end
j=input('Enter array of number you like to process \nArray should be enclosed in square brackets and separated by spaces:  ');
s=s(j);

%setting thresholds
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
q=questdlg('Do you want to manually set thresholds to selected sessions?','Set thresholds','Yes','Abort','Skip','Yes');
if strcmp(q,'Yes')
%     flag=0;
    for j=1:size(s,1)
        day_path=s(j).name;
        disp(day_path);
        d=dir([home_dir '\' day_path '\' '*wvf.mat']);
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
            analogPreProcessing(home_dir,day_path,d(list(i)).name,1:3,1);
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
        disp(day_path);
        d=dir([home_dir '\' day_path '\' '*wvf.mat']);
        for k=1:size(d,1)
            analogPreProcessing(home_dir, day_path, d(k).name, 1:2, 0); %!! :2
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
        call_Tpscript(home_dir,day_path,day_path);
    end
else
    return
end
