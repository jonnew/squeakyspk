function clone = Copy(SS)
% COPY Make a deep copy of this SS object.
a{1} = SS.name;
a{2} = SS.fs;
a{3} = SS.recunit;
s.time = SS.time;
s.channel = SS.channel;
s.waveform = SS.waveform;
if ~isempty(SS.unit)
    s.unit = SS.unit;
end
a{4} = s;

if ~isempty(SS.st_time)
    st.time = SS.st_time;
    st.channel = SS.st_channel;
    st.type = SS.st_type;
    a{5} = st;
    clone = feval(class(SS),a{1},a{2},a{3},a{4},a{5});
else
    clone = feval(class(SS),a{1},a{2},a{3},a{4});
    
end



% Copy all non-hidden properties.
p = properties(SS);
for i = 1:length(p)
    clone.(p{i}) = SS.(p{i});
end
end
