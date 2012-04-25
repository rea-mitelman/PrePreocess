%[pcoff,pcs,choppedData,aproxError]=Bestoff(data,pcvec,nelec,fold)
% get an array of data and array of vectors to project the dat on.
%   pcvec - is shifted over data and  best fit is found.
% and then the projection of the data on the pcs is returned.
%   pcoff - best offset returned (in samples)
%nelec - number of electrodes used.
%   fold - resolution of pcvec divided by resolution of data (integer).
%
%
% The best offset is chosen by minimizing the sigmaNoise/sigmaSignal over
%  all wires.
% In the above statement noise is everything that is not spanned by the pcs.
% The computation is done in energy (i.e., suming squares).
% pcvec is assumed to be normalized.
%
%Coby 6/3/97

% UPDATES
% Nov-1998  For position of best fit is related only to the spike
%           description by some of the PCs.  This number is set as a
%           parameter PCsToConsider.
%           The error is biased against picking values at the edges, by
%           a window WIN.  MA

function [pcoff,pcs,choppedData,aproxError]=Bestoff(data,pcvec,nelec,fold)
%sum fit quality across pc components

PCsToConsider=2;

noPCs = size(pcvec,2);
if noPCs < PCsToConsider
   PCsToConsider = noPCs;
end

[fit,finedata]=pcslide(data,pcvec,fold,1);		% the convolution
%                            nelec=1 means separate convolution for each wire

% dilute fit such that only first PCsToConsider are in
% Note on how FIT comes: first projection of all spikes on PC1, then
%                 projection of all spikes on PC2,...
nShifts = size(fit,1);
nProj =   size(fit,2);
nSpiks =  nProj/noPCs;
diluteProj = PCsToConsider*nSpiks;
diluteFit = zeros(nShifts,diluteProj);
diluteFit = fit(:,1:diluteProj);

fit = diluteFit;    % consider only first few PCs
fit=reshape(fit,length(fit(:))/PCsToConsider,PCsToConsider);

% sum squares across pc dimensions


fit=fit'.*fit';
if(size(fit,1)>1)
 fit=sum(fit);
end


fit=reshape(fit',length(fit(:))/size(data,2),size(data,2));

%compute energy for each offset

ofsetnorm=cumsum(finedata.*finedata);
ofsetnorm=ofsetnorm(size(pcvec,1):size(ofsetnorm),:)-...
    [zeros(1,size(data,2)); ofsetnorm(1:(size(ofsetnorm)-size(pcvec,1)),:)];

noise=(ofsetnorm-fit);
%plot([ofsetnorm(:,2) fit(:,2) ofsetnorm(:,2)-fit(:,2) err(:,2)]);
%ofsetnorm(114,2)
%fit(114,2)
%pause
% sum noise and signal across wires
if(nelec>1)
  noise = reshape(noise',nelec,length(noise(:))/nelec);
  noise=sum(noise);
  noise=reshape(noise',size(ofsetnorm,2)/nelec,size(ofsetnorm,1));
  noise=noise';
  fit=reshape(fit',nelec,length(fit(:))/nelec);
  fit=sum(fit);
  fit=reshape(fit,size(ofsetnorm,2)/nelec,size(ofsetnorm,1));
  fit=fit';

end

err=noise./fit;
%make a window of 1/priors for Shift
window = makwin(2,size(err,1));     
win = repmat(window,1,size(err,2)); 
errp = err.*win;                    

[aproxError, pcoff]=min(errp);      % chop the selected data
choppedData(size(pcvec,1),size(finedata,2))=0;% memory allocation
for i=1:nelec:size(data,2)
  choppedData(:,i:(i+nelec-1))=...
     finedata(pcoff((i+nelec-1)/nelec):(pcoff((i+nelec-1)/nelec)+...
               size(pcvec,1)-1),i:(i+nelec-1));
end
pcs=choppedData'*pcvec;
pcs=pcs';

if any(isnan(choppedData(:)))
	fprintf('\n=========================================NaN value found in "choppedData" variable. This may cause problems downstream!\n=========================================\n.')
end



