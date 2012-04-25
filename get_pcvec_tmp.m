function pcvec=get_pcvec_tmp(i_rec)
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
		extracts=extracts(:,ixs);
		pcvec=get_pcvec_tmp(i_rec);
	end
end
