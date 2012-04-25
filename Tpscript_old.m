% TPSCRIPT            automated version of NL_Tpscript.

% 07-sep-03 ES

function [quitProg,OK] = Tpscript(pcvec,inFiles,outDir,wchan);


% Run tpprep for all files in cell array inFiles (which reside in FilePath)
% Save them in outDir
% pcvec - the PCs vector
% wchan - A matrix :the channel structure of the data 
% handles are the handles of the calling function, which is the callback of the 
% start button of the main pre processing UI.


% This used to be tpscript which was originally written by Moshe Abeles and Coby Metzger, and then also 
% Others from AO, but i have thoroughly revised it on september/2001 YBS


% TO DO:
% Take care of Channames for alphamap files - see code in tpprep

OK = 0;
[FilePath,tmp1,tmp2] = fileparts(inFiles{1});


quitProg = 0;
overwrite_mode = 'overwrite';

% Number of channels (be it electrodes, tetrodes, or whatever)
Nelecs  = length(find(wchan(:,1)>=0));
if ~Nelecs
    errordlg(['Can not start Projecion - wchan variable from: ' FilePath ' contains no relevant data '],'ALPHASORT Pre Processor');            
    return
end



% Number of input (MSF) files
if iscell(inFiles)
    Nfiles = length(inFiles);  
else
    disp('List of input files to NL_TPSCIPT must be a cell array');
    return
end

% Go over all electrodes
for En = 1:Nelecs
    % Get the wires for this electrode/tetrode, etc ..
    thisElec=wchan(En,:);
    thisElec=thisElec(thisElec>=0);
    % Make a string of the channel number - if several channels are involved, this is a composite
    % string
    S = sprintf('%02d',thisElec);
    % Derive the appropriate output directory name
    MPFdirs{En} = [outDir 'elc_' S];
    %check if such a directory exists
    Exs = (exist(MPFdirs{En}) == 7); 
    % and if it does not, create it
    if ~Exs
        eval(['!mkdir ' MPFdirs{En}]);
    end
end

% Make list of all output file name (i.e. MPF files)
for Fn = 1:length(inFiles)
    [P,N,E] = fileparts(inFiles{Fn});
    % These names are passed to tpprep as they contain the full path
    full_inFiles{Fn} = [FilePath filesep N];
    for En = 1:Nelecs
        % Now create the actual MPF file names - their names should correspond to the names
        % of the subdirectories in which they will be saved.
        thisElec=wchan(En,:);
        thisElec=thisElec(thisElec>=0);
        MPFfiles{Fn,En} = [MPFdirs{En} filesep make_outputname(N,thisElec)];
    end
end


% Check which files exist already:
% Run over all electrodes:
for En = 1:length(MPFdirs)
    
    % Make a directory of pre existing files in this directory
    isFlist = dir(MPFdirs{En});
    % Convert list to a cell array which is a legal format for the string
    isFlist = dir_to_cell(isFlist,[],1);            
    % Remove the extension from the files in the current directory
    for i = 1:length(isFlist)
        [PATH,NAME,EXT] = FILEPARTS(isFlist{i});
        isFlist{i} = [NAME];
    end
    % We must have this check - otherwise the ismember check below will not make sense
    if isempty(isFlist)
        isFlist{1} = '';
    end
    
    % a list of files to be created
    for Fn = 1:Nfiles
        [PATH,willFile,EXT] = FILEPARTS(MPFfiles{Fn,En});
        % Check which of the files in the list to be created already exist in this directory
        ExistFlags(Fn,En) = ismember(upper(willFile),upper(isFlist));    
    end
    
    
end % Of checking file existence

% If at least one file already exists - then  prompt the user
if ~isempty(find(ExistFlags))    
    overwrite_mode = prompt_existing_files(ExistFlags,MPFdirs);
end
if strcmp(overwrite_mode,'quit') return; end;

% Check if any of the names exist - 
% If they exist give the user two options - overwrite or skip.
% Then, use this as a flag for processing later on. 

% loop over all Electrodes and all files, and do tpprep for each
% and apply Tpprep to each of it

for En=1:Nelecs
    % This electrode name (contianing all channels in it)
    thisChan=wchan(En,:);
    thisChan=thisChan(thisChan>=0);
    if (~isempty(thisChan))  % convert only electrodes with data
        for Fn=1:Nfiles  
            
            % Update the status bar and text 
            MSGSTR = ['Creating MPF file ' num2str(En) ' of ' num2str(Nelecs) ' from MSF file ' num2str(Fn) ' of ' num2str(Nfiles)];
            disp( MSGSTR ) %%
            %%            set(handles.pp_status_txt,'string',MSGSTR);
            %             
            %             
            %             CUR = (En-1)*Nfiles + Fn;          
            %             set(handles.progress_patch,'xdata',[0 0 CUR/(Nfiles*Nelecs) CUR/(Nfiles*Nelecs)])
            
            % Check the cancel button
            %%           NL_quit_pp_scr; 
            if quitProg  return;   end
            
            try
                % Project this file only if we are in overwrite mode, or if the file does not exist
                if strcmp(overwrite_mode,'overwrite') | ~ExistFlags(Fn,En)
                    % If this file exists - delete it - see note on case sensitivity in HBF2MSF.m or in 
                    % newlook documentation
                    if ExistFlags(Fn,En)
                        try
                            eval(['!del ' MPFfiles{Fn,En} '.mat' ]) ;
                        catch
                        end
                    end
                    %here I added a function that loads the appropriate
                    %pcvec. The default is loaded when missing - Yuval 25/3/07
                    base=full_inFiles{Fn}; 
                    pos1=findstr(base,'msf');
                    pos2=findstr(base,'E');
                    pcname=sprintf('%selc_%02d\\%s__wvfpcvT%02d.mat',base(1:pos1-1),thisChan,base(pos2:pos2+9),thisChan);
                    try 
                        load(pcname);
                    catch
                        pcstr = 'Pcvec3.mat';
                        load(pcstr);
                    end
                   


                    % Here is where things really happen
                    %%                        [quitProg] = NL_Tpprep(handles,full_inFiles{Fn},MPFfiles{Fn,En},pcvec,thisChan,length(thisChan),4); 
                    [quitProg] = Tpprep(full_inFiles{Fn},MPFfiles{Fn,En},pcvec,thisChan,length(thisChan),4); 
                end
                if quitProg  return;   end
            catch       
                errstr{1} = 'Projecion to file' ;
                errstr{2} = [MPFfiles{Fn,En}] ;
                errstr{3} = 'Could not be completed.' ;
                errstr{4} = '';
                errstr{5} = 'Projection is resumed with subsequent files' ;                
                errordlg(errstr,'ALPHASORT Pre Processor');        
            end                                                                        
        end
    end
    % Make the list of MPF files in the current directory - this will be later used for classification
    % We do not need this list anymore.
    %NL_makefnames(MPFdirs{En});
end

OK = 1; 

return


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% An internal function which returns an MPF file name for a given MSF file name
% and the channel
function outName = make_outputname(thisName,thisElec);
if findstr(upper(thisName),'S_')
    r = max(findstr(upper(thisName),'S_'));
    rn = thisName;
    rn(r) = [];
    outName=[rn,'pcsT',sprintf('%02d',thisElec)];
elseif strcmp(upper(thisName(end)),'S')
    outName=[thisName(1:end-1),'pcsT',sprintf('%02d',thisElec)];
else
    outName=[thisName,'pcsT',sprintf('%02d',thisElec)];
end   

% An internal function that makes a list, and writes to file all MPF files in the given
% directory
function NL_makefnames(ThisDir);
fl = dir ([ThisDir  filesep '*pcs*.mat']);
nf = size(fl);
fn = fopen([ThisDir  filesep 'fnames'],'wt');
for i=1:nf(1)
    [P N E] = fileparts(fl(i).name);
    fprintf (fn , '%s\n',N);    % for win95+UNIX
    %fprintf (fn , '%s\r\n',a); % for winNT 4.0
end
fclose (fn);


% An internal function that gives the user a message about previously projected files.
function [mode] = prompt_existing_files(ExistFlags,DirNames)


SUMexist = sum(ExistFlags,1);

quest_str{1} = 'The following directories already contain MPF files: ';
quest_str{2} = '';

k = 3;
for En = 1:length(SUMexist)
    if SUMexist(En)
        quest_str{k} = [DirNames{En} '  contains ' num2str(SUMexist(En)) ' relevant files'];
        k = k + 1;
    end
end
quest_str{k+1} = '';
quest_str{k+2} = 'How do you want to treat these files ? ';
quest_str{k+3} = '';


ButtonName=questdlg(quest_str,'ASORT Pre Processor','Overwrite','Skip','Cancel','Overwrite');
if strcmp(ButtonName,'Overwrite')
    mode = 'overwrite';
elseif strcmp(ButtonName,'Skip')    
    mode = 'skip';
elseif strcmp(ButtonName,'Cancel')
    mode = 'quit';
end





