home_dir = 'D:\Rea''s_Documents\Prut\Ctx-Thal\data\test\';
s.name = 'h021208';
day_path=s(1).name;
load([home_dir day_path '\info\' day_path '_param'])
n_elecs=4;
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
	