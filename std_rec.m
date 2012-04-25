function sd=std_rec(x)

if min(size(x))>1
	error('this function works for vectors only')
end
n=1;
avg=x(1);
avg_sqr=x(1)^2;

for ii=1:length(x)-1
	avg=x(ii+1)/(n+1)+n/(n+1)*avg;
	avg_sqr=x(ii+1)^2/(n+1)+n/(n+1)*avg_sqr;
	n=n+1;
	
end
sd=sqrt(avg_sqr-avg^2);
