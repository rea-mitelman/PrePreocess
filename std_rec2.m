function sd=std_rec2(x)

if min(size(x))>1
	error('this function works for vectors only')
end

n=length(x{1});
avg=mean(x{1});
avg_sqr=mean(x{1}.^2);

for ii=2:length(x)
	[avg,avg_sqr,n]=update_mean(x{ii},avg,avg_sqr,n);
	
end

sd=sqrt(avg_sqr-avg^2);

function [avg,avg_sqr,n]=update_mean(new_x,avg,avg_sqr,n)
	m=length(new_x);
	avg_tmp=mean(new_x);
	avg_sqr_tmp=mean(new_x.^2);
	avg=n/(n+m)*avg + m/(n+m)*avg_tmp;
	avg_sqr=n/(n+m)*avg_sqr + m/(n+m)*avg_sqr_tmp;
	n=n+m;


