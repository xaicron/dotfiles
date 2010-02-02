exec "Snippet class [% USE ".st."class".et." = Class('".st."ClassName".et."') %]<CR>".st.et
exec "Snippet url [% USE ".st."name".et." = url('".st."path".et."') %]<CR>".st.et
exec "Snippet linkto <a href=\"[% c.uri_for('".st."path".et."', "st."param".et.") %]\">".st."label".et."</a>".st.et
exec "Snippet if [% IF ".st."condition".et." -%]<CR>".st.et."<CR>[% END -%]<CR>".st.et
exec "Snippet ife [% IF ".st."condition".et." -%]<CR>".st.et."<CR>[% ELSE -%]<CR>".st.et."<CR>[% END -%]<CR>".st.et
exec "Snippet ifee [% IF ".st."condition1".et." -%]<CR>".st.et."<CR>[% ELSIF ".st."condition2".et." -%]<CR>".st.et."<CR>[% ELSE -%]<CR>".st.et."<CR>[% END -%]<CR>".st.et
exec "Snippet unless [% UNLESS ".st."condition".et." -%]<CR>".st.et."<CR>[% END -%]<CR>".st.et
exec "Snippet for [% FOR ".st."var".et." = ".st."list".et." %]<CR>".st.et."<CR>[% END -%]<CR>".st.et
exec "Snippet foreach [% FOREACH ".st."var".et." = ".st."list".et." %]<CR>".st.et."<CR>[% END -%]<CR>".st.et
exec "Snippet while [% WHILE (".st."var".et." = ".st."rs ife [% IF ".st."condition".et." -%]<CR>".st.et."<CR>[% ELSE -%]<CR>".st.et."<CR>[% END -%]<CR>".st.et
exec "Snippet ifee [% IF ".st."condition1".et." -%]<CR>".st.et."<CR>[% ELSIF ".st."condition2".et." -%]<CR>".st.et."<CR>[% ELSE -%]<CR>".st.et."<CR>[% END -%]<CR>".st.et
exec "Snippet unless [% UNLESS ".st."condition".et." -%]<CR>".st.et."<CR>[% END -%]<CR>".st.et
exec "Snippet for [%et."(".st."arg".et.") BLOCK %]<CR>".st.et."<CR>[% END %]<CR>".st.et
exec "Snippet var [% ".st."var".et." %]".st.et
exec "Snippet hvar [% ".st."var".et." | html %]".st.et
exec "Snippet hlvar [% ".st."var".et." | html | html_line_break %]".st.et
exec "Snippet null [%- FILTER null -%]<CR>".st.et."<CR>[%- END -%]<CR>".st.et
