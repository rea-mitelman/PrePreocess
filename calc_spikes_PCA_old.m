function calc_spikes_PCA(flist,NSubSess,file_nums,n_elec)
fprintf('Calculating PCs using PCA on Sub-session: #%2.0f (files: %2.0f:%2.0f), Electrode #%1.0f\n',NSubSess,file_nums,n_elec);
extracts_cell=cell(1,length(flist));
for ifile=1:length(flist)
	if exist(flist(ifile).fnm)
		load(flist(ifile).fnm,'upsamp_spk_shapes','samplingInterval','fold')
		extracts_cell{ifile} = upsamp_spk_shapes;
	end
end
global extracts
extracts=cell2mat(extracts_cell);
clear extracts_cell
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
	end
end
