function celllist = dir_to_cell(Flist,dirstring,only_files);
% Convert a struct array with a name field into a cell array, each cell
% holding a single string.

% YBS 16/8/01


celllist = [];


if ~exist('only_files')
    only_files = 0;
end


if ~isfield(Flist,'name')
    return
end

if only_files % Exclude directories from the list
    k = 1;
    for i = 1:length(Flist)
        if ~Flist(i).isdir
            celllist{k} = [dirstring Flist(i).name];
            k = k + 1;
        end
    end
else
    for i = 1:length(Flist)
        celllist{i} = [dirstring Flist(i).name];  
    end
end    
