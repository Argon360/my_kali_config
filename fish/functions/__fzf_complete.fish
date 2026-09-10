function __fzf_complete --description "Interactive FZF tab completion for any command or option"
    set -l buffer (commandline -b)
    set -l token (commandline -ct)
    set -l cursor (commandline -C)

    # Everything up to cursor position
    set -l trimmed (string sub -s 1 -l $cursor -- "$buffer")

    # Get completions from fish engine
    set -l matches (complete --do-complete "$trimmed")

    # If no matches, fall back to default fish completion
    if test (count $matches) -eq 0
        commandline -f complete
        return
    end

    # If exactly 1 match, complete immediately
    if test (count $matches) -eq 1
        set -l completion (string split \t -- "$matches[1]")[1]
        if string match -r '/$' -- "$completion"
            if string match -r '^["\'].*["\']$' -- "$token"
                commandline -t -- "$completion"
            else
                commandline -t -- (string escape --no-quoted -- "$completion")
            end
        else
            if string match -r '^["\'].*["\']$' -- "$token"
                commandline -t -- "$completion "
            else
                commandline -t -- (string escape --no-quoted -- "$completion")" "
            end
        end
        commandline -f repaint
        return
    end

    # FZF completion flags
    set -l fzf_flags \
        --height=45% \
        --layout=reverse \
        --border \
        --inline-info \
        --ansi \
        --delimiter=\t \
        --tabstop=25 \
        --prompt="󰍉 Complete > " \
        --header="Tab / Enter to select, ESC to cancel, Ctrl-/ to toggle preview" \
        --preview='
            set -l item (string split \t -- {})[1]
            set -l desc (string split \t -- {})[2]
            if test -n "$desc"
                echo -e "\033[1;36mOption Description:\033[0m"
                echo "$desc"
                echo ""
            end
            if test -d "$item"
                echo -e "\033[1;34mDirectory Contents:\033[0m"
                eza --tree --level=2 --color=always --icons "$item" 2>/dev/null || ls -la "$item" 2>/dev/null
            else if test -f "$item"
                echo -e "\033[1;32mFile Preview:\033[0m"
                bat --color=always --style=numbers --line-range=:100 "$item" 2>/dev/null || cat "$item" 2>/dev/null
            end
        ' \
        --preview-window=right:45%:hidden:wrap \
        --bind='ctrl-/:toggle-preview'

    # Filter by current token if not empty and not just whitespace
    if test -n (string trim -- "$token")
        # Remove leading quotes or backslashes for the query
        set -l clean_query (string replace -r '^["\']' '' -- "$token")
        set -a fzf_flags --query="$clean_query"
    end

    set -l selected (printf '%s\n' $matches | fzf $fzf_flags)

    if test -n "$selected"
        set -l completion (string split \t -- "$selected")[1]
        if string match -r '/$' -- "$completion"
            if string match -r '^["\'].*["\']$' -- "$token"
                commandline -t -- "$completion"
            else
                commandline -t -- (string escape --no-quoted -- "$completion")
            end
        else
            if string match -r '^["\'].*["\']$' -- "$token"
                commandline -t -- "$completion "
            else
                commandline -t -- (string escape --no-quoted -- "$completion")" "
            end
        end
    end

    commandline -f repaint
end
