% CALL_TPSCRIPT         automated version of ALPHSORT projection taylored for prehension.
%
% call                  CALL_TPSCRIPT
%
% does                  1. load PCVEC3.MAT from MATLAB path ( ASORT/general_funcs)
%                       2. make a list of all MSF files in home_dir\day_path\MSF
%                       3. create mpf directory in home_dir\day_path
%                       4. load wchan from home_dir ( 16 electrodes )
%                       5. call TPSCRIPT
%
% workspace             works in current path ( MYSP )

% 07-sep-03 ES

% revisions
% 09-sep-03 MY_MD call altered

% variables
% handles 
% pcvec             load('pcvec.mat')       % D:\prhnsn\ASORT_4_0_23\general_funcs
% inFiles           cell array of strings
% outDir            string
% wchan             file

function call_Tpscript(home_dir,day_path,store_dir,mode,files)

%global home_dir
%global day_path
%global store_dir
%global monkey
%if isempty( home_dir ) | isempty( day_path ) | isempty( store_dir ) | isempty( monkey )
 %   error('run MYSP first')
 %end

% load pc definitions
pcstr = 'Pcvec3.mat'; %%% changed the name of PC source to fit new spinal PCs
%pcstr='spinal_PCs_itt10.mat';
if ~exist( pcstr, 'file' )
    error( 'missing PC definitions' )
end
load( pcstr )                                       % pcvec

% build inFiles ( cell array of strings )
inDir = sprintf( '%s\\%s\\msf\\', home_dir, day_path );
if ~exist( inDir, 'file' )
    error( 'missing source directory' )
end
%dstr = dateT2N( day_path, 'text' );
%dstr = dstr( 1 : 4 );
d = dir([inDir '*S_wvf*']);
if mode==1
    d=d(files);
end
j = 0;
inFiles = {};
for i = 1 : length( d )
    if ~d( i ).isdir && strcmp( d(i).name( [ 1 12 17:20 ] ), 'ES.mat' ) %& strcmp( d(i).name(2:5), dstr ) %was d(5)
        j = j + 1;
        inFiles{ j } = sprintf( '%s\\%s', inDir, d(i).name );
    end
end
if isempty( inFiles )
    error( 'missing source files' )
end

% create outDir ( string )
parentDir = [home_dir '\' day_path];
mkdir(parentDir, 'mpf' );
outDir=[parentDir '\'];
%outDir = [ outDir '\' ];
if ~exist( outDir, 'file' )
    error( 'missing target directory' )
end

% load wchan ( no extension, assumed to be in home_dir )
wstr = sprintf( '%s\\wchan', home_dir );
if exist( wstr, 'file' )
	load (wstr)                                            % wchan
elseif exist('wchan','file')
	load wchan
	fprintf(['\n========================================\nThe "wchan" file of the requested'...
		' data\nwas not found, useing defauld one. \nThe channels definitions might be incorrect'...
		'\n========================================\n\n'])
else
	error( 'missing wchan' )
end


% run the modified projection script
[quitProg,OK] = Tpscript(pcvec,inFiles,outDir,wchan);

return