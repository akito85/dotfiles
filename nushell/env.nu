# Nushell Environment Configuration

# Fast Node Manager (fnm) environment
$env.FNM_DIR = $"($env.HOME)/.local/share/fnm"
if (which fnm | is-not-empty) {
    ^fnm env --shell bash | lines | parse "{name}={value}" | transpose -r | into record | load-env
}

# SDKMAN environment
$env.SDKMAN_DIR = $"($env.HOME)/.sdkman"

# PATH additions - ensure all necessary bin directories are in PATH
$env.PATH = ($env.PATH | split row (char esep)
    | prepend "/opt/homebrew/bin"
    | prepend "/opt/homebrew/sbin"
    | prepend $"($env.HOME)/.cargo/bin"
    | prepend $"($env.HOME)/.local/bin")

# Carapace completions
# Bridges completions from zsh/fish/bash for commands not yet natively supported
$env.CARAPACE_BRIDGES = "zsh,fish,bash,inshellisense"
mkdir ($nu.data-dir | path join "vendor/autoload")
carapace _carapace nushell | save --force ($nu.data-dir | path join "vendor/autoload/carapace.nu")
