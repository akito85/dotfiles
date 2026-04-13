# Nushell Configuration

# Zoxide initialization (smart cd)
source ~/.config/nushell/zoxide.nu

# Starship prompt - generated via: starship init nu | save -f ~/.cache/starship/init.nu
use ~/.cache/starship/init.nu

# Custom Functions

# Function to clean all Neovim plugin git repos
def nvim-clean-plugins [] {
    let original_dir = (pwd)
    let plugins_dir = $"($env.HOME)/.local/share/nvim/lazy"

    if ($plugins_dir | path exists) {
        cd $plugins_dir

        for dir in (ls | where type == dir) {
            let git_dir = $"($dir.name)/.git"
            if ($git_dir | path exists) {
                print $"Cleaning ($dir.name)..."
                cd $dir.name
                git reset --hard HEAD | complete | ignore
                git submodule update --init --recursive | complete | ignore
                cd ..
            }
        }

        cd $original_dir
        print "All plugins cleaned!"
    } else {
        print "Neovim plugins directory not found"
    }
}

# Shell configuration
$env.config = {
    show_banner: false
    edit_mode: emacs

    hooks: {
        env_change: {
            PWD: [
                # Auto-activate fnm node version if .node-version or .nvmrc exists
                {|before, after|
                    if (which fnm | is-not-empty) {
                        if ('.node-version' | path exists) or ('.nvmrc' | path exists) {
                            ^fnm use --silent-if-unchanged
                        }
                    }
                }
            ]
        }
    }
}

alias claude = claude --dangerously-skip-permissions
