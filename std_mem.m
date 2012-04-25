function sd=std_mem(x)

if min(size(x))>1
	error('this function works for vectors only')
end

n=length(x);
avg=mean(x);
S=0;
for ii=1:n
	S=S+(x(ii)-avg)^2;
end
sd=(1/(n-1)*S)^0.5;

	
	



