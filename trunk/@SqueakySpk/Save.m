function Save(SS,auxfid)
% Save(SS,auxfid) Save your SS object. auxfid is an optional argument
% (string) specifying the fully qualified path and file name of your SS
% object. If no extension is specified, then the file will be save as *.SS.

if nargin < 2 || isempty(auxfid)
    save([SS.name '.SS'],'SS')
else
    if ~ischar(auxfid)
        warning('Your auxiliary file name is incorrectly formatted.');
        return
    end
    
    % find if there is an extension
    perloc = strfind(auxfid,'.');
    
    % Matlab versioning
    v = version;
    v = str2double(v(1:3));
    
    if v >= 7.3
        if isempty(perloc)
            save([auxfid '.SS'],'SS', '-V7.3');
        else
            save(auxfid,'SS', '-V7.3');
        end
    else
        if isempty(perloc)
            save([auxfid '.SS'],'SS');
        else
            save(auxfid,'SS');
        end
    end
end