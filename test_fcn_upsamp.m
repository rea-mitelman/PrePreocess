% function test_fcn_upsamp(in_root)
% if nargin==0
	in_root='D:\Rea''s_Documents\Prut\Ctx-Thal\data\test_data2';
% end
if ~exist (in_root)
	error('No such folder')
end
in_MAT=[in_root '\MAT'];
out_root=[in_root '\upsamp'];
out_MAT=[out_root '\MAT'];
 
in_wvf=dir([in_MAT '\*wvf.mat']);
in_bhv=dir([in_MAT '\*bhv.mat']);
load([in_MAT '\' in_wvf(1).name],'Unit1_KHz')
if Unit1_KHz~=25
	error('looking for data sampled in 25 KHz')
end

if ~exist(out_root)
	 mkdir(out_MAT)
end
 
disp('copy bhv files as is')
disp('')
for ii=1:length(in_bhv)
	copyfile([in_MAT '\' in_bhv(ii).name] , out_MAT)
	disp(['Copying ' [in_MAT '\' in_bhv(ii).name] ' to directory: '  out_MAT])
end

disp('copy wvf files as is')
disp('')
for ii=1:length(in_wvf)
	copyfile([in_MAT '\' in_wvf(ii).name] , out_MAT)
	disp(['Copying ' [in_MAT '\' in_wvf(ii).name] ' to directory: '  out_MAT])
end

disp('upsampling channles and saveing')
for ii=1:length(in_wvf)
	disp(['Accessing file: ' in_wvf(ii).name])
	for chan=1:4
		unit_name=sprintf('Unit%1.0f',chan);
		Fs_name=[unit_name '_KHz'];
		clear(unit_name,Fs_name)
		load([out_MAT '\' in_wvf(ii).name],unit_name,Fs_name)
		Fs_eval=[Fs_name ' = 2*' Fs_name ';'];
		eval(Fs_eval);
		t=[0:length(eval(unit_name))-1];
		tt=[0:0.5:length(eval(unit_name))-0.5];
		upsamp_eval=[unit_name ' = interp1(t,' unit_name ',tt,[],' '''' 'extrap' '''' ');'];
		eval(upsamp_eval);
		save([out_MAT '\' in_wvf(ii).name],unit_name,Fs_name,'-append');
		disp(['saving ' unit_name])
	end
end