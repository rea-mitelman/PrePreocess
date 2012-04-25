function TH_mat=get_thersh_per_subsess(home_dir,day_path,n_std,n_elects,do_art_rem,org_art_dur)
% TH_mat=get_thersh_per_subsess(home_dir,day_path,n_std,n_elects)
% returns a matrix of the threshold of each file in the folder, but the
% threshold is calculated per subsession.
% TH_mat has the following dimentions:
% (2 - lower&upper thresh) X (number of electrodes) X (number of files)

load([home_dir '\' day_path '\info\' day_path '_param']);
% SESSparam.SubSess.Files;
all_ss=cell(length(SESSparam.SubSess),1);
for i_ss=1:length(SESSparam.SubSess)
	all_ss{i_ss}=SESSparam.SubSess(i_ss).Files(1):SESSparam.SubSess(i_ss).Files(2);
end


files_in_sess=cell2mat(all_ss');

% Finding all files in the relevant directory
dir_base=[home_dir '\' day_path '\MAT\' ];
all_files=dir([dir_base '*wvf.mat']);
n_files=length(all_files);
all_files_num=zeros(n_files,1);
for f=1:n_files
	file_name=all_files(f).name;
	i_=find(file_name=='_',1,'first');
	num_str=file_name(i_-3:i_-1);
	all_files_num(f)=str2num(num_str); %#ok<*ST2NM>
end
file_base=file_name(1:i_-4);
files_outof_sess=setdiff(all_files_num,files_in_sess);
% all_sess include all sessions as given by the 'param' file, plus all the
% files that are not within a given session - each as a session of a single
% file:
% all_ss(end+1:end+length(files_outof_sess))=num2cell(files_outof_sess(:));
all_ss=[all_ss ; num2cell(files_outof_sess(:))];
unit_names=cell(n_elects,1);

for u=1:n_elects
	unit_names{u}=['Unit' num2str(u)];
end
n_sess=length(all_ss);
% TH_per_sess=zeros(n_sess,2,max(elects));
TH_mat=zeros(2,n_elects,max(all_files_num));
for i_ss=1:n_sess
	TH_per_sess=zeros(2,n_elects);
	for u=1:n_elects
		data_vec=[];
		for i_file=all_ss{i_ss}
			full_file_name=sprintf('%s%s%03.0f%s',dir_base,file_base,i_file,'_wvf.mat');
			if do_art_rem
				stim_times=get_stim_times(full_file_name);
			else
				stim_times=[];
			end
			if any(strcmp(who('-file',full_file_name),unit_names{u}))
				load(full_file_name,unit_names{u},[unit_names{u} '_KHz'])
				if do_art_rem
					str2eval=['remove_stim_artifact(' unit_names{u} ' , ' unit_names{u} '_KHz , stim_times,org_art_dur);' ];
				else 
					str2eval = unit_names{u};
				end
				data_vec=eval(str2eval);
				if ~exist('n','var')
					n=length(data_vec);
					avg=mean(data_vec);
					avg_sqr=mean(data_vec.^2);
				else
					 [avg,avg_sqr,n]=update_mean(data_vec,avg,avg_sqr,n);
				end
			else
				data_vec=NaN;
				avg=NaN;avg_sqr=NaN;n=NaN;
				break
			end
		end
		std_data=sqrt(avg_sqr-avg^2);
		% 		try
		% 			std_data=std(data_vec);
		% 		catch exception
		% 			if any(strcmp(exception.identifier,{'MATLAB:nomem','MATLAB:pmaxsize'}))
		% 				std_data=std_mem(data_vec);%if there's a memory problem, use the std_mem function, which handles large vecotrs with a loop
		% 			else
		% 				rethrow(exception)
		% 			end
		% 		end
		% 		TH_per_sess(:,u) = mean(data_vec) + [-1 1]' * (n_std*std_data);
		this_TH=avg + [-1 1]' * (n_std*std_data);
		if sign(prod(this_TH))==1
			fprintf('Both upper and lower thersholds have the same sign.\nThis suggests the data is artificial\n')
		else
			TH_per_sess(:,u) = this_TH;
		end
		clear n avg avg_sqr

	end
	
	for i_file=all_ss{i_ss}
		TH_mat(:,:,i_file)=TH_per_sess;
	end	
end


function stim_times=get_stim_times(full_file_name)
i_=find(full_file_name=='_',1,'last');
bhv_file_name=full_file_name;
bhv_file_name(i_+1:i_+3)='bhv';
load (bhv_file_name)
if exist('AMstim','var') %old format
	disp('Stimulation variable: AMstim (older format, AM-systems stimulator)');
	stim_times=AMstim; %#ok<*NASGU>
elseif exist('AMstim_on','var') %new format
	disp('Stimulation variable: AMstim_on (newer format, AM-systems stimulator)');
	stim_times=AMstim_on;
elseif exist('StimTime','var') %new format
	disp('Stimulation variable: StimTime (old format, Alpha-Omega stimulator)');
	stim_times=StimTime;
	
else %stim file was not created, use empty
	disp('No stimulations variable was found, make sure this file does not contain stimuli');
	stim_times=[];
end

function [avg,avg_sqr,n]=update_mean(new_x,avg,avg_sqr,n)
	m=length(new_x);
	avg_tmp=mean(new_x);
	avg_sqr_tmp=mean(new_x.^2);
	avg=n/(n+m)*avg + m/(n+m)*avg_tmp;
	avg_sqr=n/(n+m)*avg_sqr + m/(n+m)*avg_sqr_tmp;
	n=n+m;
