% PARSE         parse a vector to sets of points, each of consecutive values.
%
%               PAIRS = PARSE(VEC)
%
%               VEC         vector of integers
%               PAIRS       n by 2 matrix of ranges
%
%               example (1) - sorted array:
%               >> pairs = parse( [ 6 : 10 15 : 20 25 ] )
%               pairs =
%                    6    10
%                   15    20
%                   25    25
%
%               example (2) - identical samples
%               >> pairs = parse( [ ones( 1, 10 ) 1 : 20 ] )
%               pairs =
%                    1    20
%
%               example (3) - non-sorted array
%               >> pairs = parse( [ 5 : 10 3 : 4 ] )
%               pairs =
%                    5    10
%                    3     4
%               >> 

% 12-feb-03 MEX file implementation

% revisiosn
% 16-nov-03 logical checks; help examples

function pairs = parse(vec);

if isempty(vec), pairs = []; return, end
if ~isnumeric( vec ) | issparse( vec ) | ~any(size(vec)==1)
    error('input must be a numeric full vector')
end

vec = vec(:).';
[st et] = parsec(vec);
pairs = [st et];

return