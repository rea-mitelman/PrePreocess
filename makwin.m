%function window = makwin(strt,len)
%
%  makes a window that starts from strt, goes to  1 over
%  quarter length, stays at 1 for half length and goes back
%  to strt over  quarter length.
%  This is a callback from Bestoff.m
%
% strt - initial , end values of the window;
% len   - length of window, should be > 3
% window - a column vector with the shape of the window

% MA oct-1998
function window = makwin(strt,len)
ln=floor(len);
l1=floor(ln/4);
if l1<1
   l1=1;
end

dl = (strt-1)/l1;
wind = [strt:-dl:1];
wind = [wind ones(1,ln-2*l1-2)];
wind = [wind 1:dl:strt];

if size(wind,2)>ln   % truncate
   wind = wind(1:ln);
end
while size(wind,2)<ln   % appned ones at middle
   l2 = floor(size(wind,2)/2);
   wind = [wind(1:l2) 1 wind(l2+1:size(wind,2))];
end

window=wind';
