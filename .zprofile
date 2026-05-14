# Shared login environment
for dotfiles_dir in "$HOME/projects/dotfiles" "$HOME/dotfiles"; do
    if [ -d "$dotfiles_dir/bin" ]; then
        export PATH="$dotfiles_dir/bin:$PATH"
        break
    fi
done

export EDITOR=vi
export VISUAL=vi
