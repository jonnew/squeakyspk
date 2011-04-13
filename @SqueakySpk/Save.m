%% Block 8: Save SS object
function Save(SS,auxfid)
% Save(SS,auxfid) Save your SS object. auxfid is an optional argument
% (string) specifying the fully quallified path and file name of your SS
% object. If no extension is specified, then the file will be save as *.SS.

if nargin < 2 || isempty(auxfid)
    save([SS.name '.SS'],'SS')
else
    if ~ischar(auxfid)
        warning('your auxiliary file name is incorrectly formatted.');
        return
    end
    
    % find if there is an extension
    perloc = strfind(auxfid,'.');
        
    if isempty(perloc)
         save([auxfid '.SS'],'SS');
    else
        save([auxfid],'SS');
    end
end