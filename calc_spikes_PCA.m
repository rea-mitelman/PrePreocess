function calc_spikes_PCA(flist,NSubSess,file_nums,n_elec)
fprintf('Calculating PCs using PCA on Sub-session: #%2.0f (files: %2.0f:%2.0f), Electrode #%1.0f\n',NSubSess,file_nums,n_elec);
global extracts
files_vec=randperm(length(flist)); %if there's not enough memory, we take randomly
count=0;
for ifile=files_vec
	count=count+1;
	if exist(flist(ifile).fnm)
		load(flist(ifile).fnm,'upsamp_spk_shapes','samplingInterval','fold')
		try
			extracts = [extracts upsamp_spk_shapes];
			if any(isnan(upsamp_spk_shapes(:)))
				fprintf('NaN values found in file %s\n',flist(ifile).fnm)
			end
		catch err
			if any(strcmp(err.identifier,{'MATLAB:pmaxsize','MATLAB:nomem'}))
				fprintf('Due to the huge number of spikes, only randomly chosen %1.0f files (out of %1.0f) were used to caculate PCs\n'...
					,count,length(flist))
				break
			else
				rethrow(err);
			end
			
		end
			
	end
end


no_NaN_cols=~isnan(extracts(1,:));
if sum(~no_NaN_cols)>0
		fprintf('\nWarning:\n==========\nNaN values in the spikes matrix - Removed to prevent problems \n')
		extracts=extracts(:,no_NaN_cols);
end
pcvec=get_pcvec(0); %#ok<NASGU>
for i=1:length(flist)
	pos=findstr(flist(i).fnm,'pcs');
	f2save=[flist(i).fnm(1:pos-1) 'pcv' flist(i).fnm(pos+3:end)];
	save(f2save, 'pcvec')
end

function pcvec=get_pcvec(i_rec)
global extracts

try 
	[~,~,pcvec]=svds(extracts',3);
	if i_rec>0
		fprintf('SVD succeeded with 1/%1.0f of the spikes\n',2^i_rec);
	end
catch exception
	i_rec=i_rec+1;
	if any(strcmp(exception.identifier,{'MATLAB:nomem','MATLAB:pmaxsize'}))
		if i_rec==1;
			disp('There was a memory problem, trying SVD using subset of the spikes')
		end
		l=size(extracts,2);
		ixs=randperm(l);
		ixs=ixs(1:round(l/2));
		extracts = extracts(:,ixs);
		pcvec=get_pcvec(i_rec);
	else
		rethrow(exception)
	end
end
