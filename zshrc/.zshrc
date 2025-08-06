# Carrega o P10k
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
	git
	zsh-syntax-highlighting
	zsh-autosuggestions
	fzf
)

source $ZSH/oh-my-zsh.sh

# User configuration
alias work="~/.scripts/start-work.sh"
alias deploy-prd="~/.scripts/deploy-producao.sh"
alias deploy-hml="~/.scripts/deploy-homologacao.sh"
alias reload-zsh="source ~/.zshrc"
alias edit-zsh="nvim ~/.zshrc"
alias edit-hypr="nvim ~/.config/hypr/"
alias c="clear"
alias q="exit"
alias lg="lazygit"
alias yz="yazi"

alias v="nvim"
alias t="tmux"
alias ta="tmux attach-session -t"
alias tn="tmux new-session -s"
alias grep="grep --color=auto"

# Gerenciamento de Pacotes (Arch Linux)
alias update="sudo pacman -Syyuu"
alias install="sudo pacman -S"
alias remove="sudo pacman -Rns"

# # Gerenciamento de Pacotes (Ubuntu)
# alias update="sudo apt update && sudo apt upgrade -y"
# alias install="sudo apt install"
# alias remove="sudo apt remove --purge"
# alias autoremove="sudo apt autoremove --purge -y && sudo apt autoclean"
# alias fullupdate="sudo apt update && sudo apt full-upgrade -y"

# Ruby
alias rs="rails server"
alias rc="rails console"
alias b="bundle"
alias be="bundle exec"
alias ber="bundle exec rake"
alias bes="bundle exec rspec"
alias logs="tail -f log/development.log"

# Docker
alias d="docker"
alias dps="docker ps --format 'table {{.ID}}\t{{.Names}}\t{{.Ports}}\t{{.Status}}'"
alias dpa="docker ps -a --format 'table {{.ID}}\t{{.Names}}\t{{.Ports}}\t{{.Status}}'"
alias da="docker attach"
alias di="docker images"
alias dv="docker volume ls"
alias dn="docker network ls"
alias dlogs="docker logs -f"

# Docker compose
alias dc="docker compose"
alias dcu="TERM=xterm-256color docker compose up"
alias dcd="docker compose down"
alias dcb="docker compose build"
alias dcr="docker compose restart"
alias dcl="docker compose logs -f"
alias dce="docker compose exec"
alias dcbash="docker compose exec web /bin/bash"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ---- Eza (better ls) -----
alias ls="eza --icons"

# ---- Zoxide (better cd) ----
eval "$(zoxide init zsh)"

alias cd="z"

export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"
export PATH="$HOME/go/bin:$PATH"

typeset -g POWERLEVEL9K_INSTANT_PROMPT=off

# Setup Project Function
pj() {
  local base_path="/home/isaac/workspace/projects"
  if [ -z "$1" ]; then
    local selected
    selected=$(find "$base_path" -maxdepth 1 -mindepth 1 -type d | fzf --prompt="Select the project: " --height=40%)
    [ -z "$selected" ] && echo "❌ Cancelado." && return 1
    project_name=$(basename "$selected")
  else
    project_name="$1"
    selected="$base_path/$project_name"
  fi
  [ ! -d "$selected" ] && echo "❌ Projeto '$project_name' não encontrado em $selected" && return 1
  cd "$selected" || return
  if tmux has-session -t "$project_name" 2>/dev/null; then
    tmux attach-session -t "$project_name"
  else
    # Neovim
    tmux new-session -d -s "$project_name" -n Editor -c "$selected"
    tmux send-keys -t "$project_name:Editor" 'nvim' C-m

    # Misc
    tmux new-window -t "$project_name" -n Misc -c "$selected"

    # Entra na sessão
    tmux select-window -t "$project_name:Editor"
    tmux attach-session -t "$project_name"
  fi
}

