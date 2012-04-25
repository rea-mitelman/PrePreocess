%function [result,finedata]=pcslide(data,pcs,fold,elec)
%
% compute the scalar product at different offsets of the pcs
% over the data.
%
%   elec - is number of electrodes.
%   result - is given in the higher resolution.
%   finedata - is the data interpolated to the higher resulution.
%   pcs - are inverted in time so now we need convolution. 
%         zero filling is done.
%
%Every elec colons make one spike in the data and one pc component
%in the pcs.
%time (y) resolution of the pcs is fold time bigger than the data.
% Each colon of results is the sum of elec colons so we have one
% result for a spike (for all electrodes).

%Algorithm:
% fft of both is done. data is zero filled to fill for missing resolution.
% For each pc component fft is multiplied and summed accross all electrodes
%of each spike.
% invfft is done and the proper part of the convolution is going to result.
% Coby 4/97
% MA   2/98 a minor correction

function [result,finedata]=pcslide(data,pcs,fold,elec)
pclen=size(pcs,1);
pcnum=size(pcs,2)/elec;
datalen=size(data,1);
fftlen=datalen*fold;
invpc=pcs(pclen:-1:1,:);
invpc=[zeros(fftlen-size(pcs,1),size(pcs,2));invpc]; % zero padding
pcfft=fft(invpc);


datafft1=fft(data);

if(rem(datalen,2)==0)

 datafft=zeros(size(datafft1,1)*fold,size(datafft1,2)); % datafft-->datfft1 ??
 datafft(1:datalen/2,:)=datafft1(1:datalen/2,:)*fold;
 datafft(datalen*fold-datalen/2+1:datalen*fold,:)=datafft1(datalen/2+1:datalen,:)*fold;

else
 if(fold>1)
 datafft=zeros(size(datafft,1)*fold,size(datafft1,2));
 datafft(1:floor(datalen/2),:)=datafft1(1:floor(datalen/2),:)*fold;
 datafft(datalen*fold-floor(datalen/2)+1:datalen*fold)=datafft1(floor(datalen/2)+2:datalen,:)*fold;
 datafft(floor(datalen/2)+1,:)=datafft1(floor(datalen/2)+1,:)/2*fold;
 datafft(datalen*fold-floor(datalen/2),:)=datafft1(floor(datalen/2)+1,:)/2*fold;

 else
  datafft=datafft1;
 end
end

%   if(datalen ~= 64)
% 	  datalen
%   end
global n_samp_flag
if isempty(n_samp_flag)
	n_samp_flag=true;
	disp(['spike candidates are vectors of ' num2str(datalen) ' samples']);
end

if (nargout>1)

  finedata=real(ifft(datafft));

end

% multiply dimensions of datafft
colindex=1:size(data,2)*pcnum;
colindex=rem(colindex-1, size(data,2))+1;
datafft=datafft(:,colindex);

%               multiply dimensions of pcfft
colindex=1:pcnum*size(data,2);
colindex=floor((colindex-1)/size(data,2))*elec+rem(colindex-1,elec)+1;

pcfft=pcfft(:,colindex);

%convolve
resfft=datafft.*pcfft;
% sum accross electrodes
if(elec>1)

  resfft=resfft';
  resfft=reshape(resfft,elec,length(resfft(:))/elec);
  resfft=sum(resfft);
  resfft=reshape(resfft,length(resfft(:))/fftlen,fftlen);
  resfft=resfft';
end


result=real(ifft(resfft));


result=[result(fftlen,:);result(1:(fftlen-pclen),:)];% last row is zero offset

















