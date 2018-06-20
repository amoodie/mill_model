function [gs] = load_grainsize(filepath)
    %load_grainsize will load a table for the grain size distribution
    %
    % right now this function is really stupid (i.e., the table format must
    % be specific), but I would like to make it more robust to variable
    % table formats. That is why I even bothered to stick it into its own
    % function here.
    %
    
    % TODO:
    %   - read first line and if strings then assume header
    %   - if no header try to guess which is class and which is percent
    %   - after assuming which is which, calculate the midpoint of each dist
    
    table = readtable(filepath);
    
    gs = table;

end