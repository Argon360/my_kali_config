function menu --description "Unified FZF Command Palette & Interactive Menu"
    set -l target (command fmenu $argv)
    if test -n "$target"
        if string match -r "^cd: " -- "$target"
            set -l dir (string replace -r "^cd: " "" -- "$target")
            builtin cd "$dir"
        else if string match -r "^exec: " -- "$target"
            set -l cmd (string replace -r "^exec: " "" -- "$target")
            eval "$cmd"
        end
    end
end
