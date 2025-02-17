test ! -e "$HOME/.x-cmd.root/local/data/fish/rc.fish" || source "$HOME/.x-cmd.root/local/data/fish/rc.fish" # boot up x-cmd.
if status is-interactive
    # Commands to run in interactive sessions can go here
end

fnm env --use-on-cd --shell fish | source
zoxide init fish | source
starship init fish | source

# Added by LM Studio CLI (lms)
set -gx PATH $PATH /home/akito/.lmstudio/bin
