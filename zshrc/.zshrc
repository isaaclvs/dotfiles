# ===== HISTORY =====
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt INC_APPEND_HISTORY SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE HIST_REDUCE_BLANKS

# ===== OPTIONS =====
setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS NO_BEEP CORRECT
setopt INTERACTIVE_COMMENTS
setopt NO_NOMATCH

# ===== COMPLETION =====
autoload -Uz compinit
compinit -C

# ===== COLORS & PROMPT =====
autoload -Uz colors && colors
PROMPT='%F{blue}%~%f %# '

# ===== FZF =====
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# ===== AUTO-SUGGESTIONS =====
[[ -f ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

# ===== ZOXIDE =====
eval "$(zoxide init zsh)"
alias cd="z"

# ===== ASDF =====
export ASDF_DATA_DIR="$HOME/.asdf"
fpath=(${ASDF_DATA_DIR}/completions $fpath)
export PATH="$ASDF_DATA_DIR/shims:$PATH:$HOME/.local/bin:$HOME/bin:$HOME/go/bin:$PATH"

# ===== ALIASES =====
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias dot='cd ~/.dotfiles'
# alias reload-hypr='hyprctl reload && notify-send "Hyprland Reloaded"'
alias reload-zsh="source ~/.zshrc"
alias edit-zsh="nvim ~/.zshrc"
# alias edit-hypr="nvim ~/.dotfiles/hypr/.config/hypr/"
alias c="clear"
alias q="exit"
alias lg="lazygit"
alias v="nvim"
alias t="tmux"
alias ta="tmux attach-session -t"
alias tn="tmux new-session -s"
alias grep="grep --color=auto"

# ---- Eza (better ls) -----
alias ls="eza --icons"
alias l="ls -la"

# ---- Pacman ----
alias update="sudo pacman -Syyuu"
alias install="sudo pacman -S"
alias remove="sudo pacman -Rns"

# ---- Ruby / Rails ----
alias rs="rails server"
alias rc="rails console"
alias b="bundle"
alias be="bundle exec"
alias ber="bundle exec rake"
alias bes="bundle exec rspec"
alias logs="tail -f log/development.log"

# ---- Docker ----
alias d="docker"
alias dps="docker ps --format 'table {{.ID}}\t{{.Names}}\t{{.Ports}}\t{{.Status}}'"
alias dpa="docker ps -a --format 'table {{.ID}}\t{{.Names}}\t{{.Ports}}\t{{.Status}}'"
alias da="docker attach"
alias di="docker images"
alias dv="docker volume ls"
alias dn="docker network ls"
alias dlogs="docker logs -f"

# ---- Docker Compose ----
alias dc="docker compose"
alias dcu="TERM=xterm-256color docker compose up"
alias dcd="docker compose down"
alias dcb="docker compose build"
alias dcr="docker compose restart"
alias dcl="docker compose logs -f"
alias dce="docker compose exec"
alias dcbash="docker compose exec web /bin/bash"

# ---- Work ----
alias vpnup='sudo resolvconf -u && wg-quick up wg0'
alias vpndown='sudo wg-quick down wg0'
alias mount-lxc='sshfs root@10.0.182.12:/var/lib/samba/usershares/isaac/workspace/saude-publica ~/workspace/crescer/crescer-lxc -p 220 -o reconnect,cache=yes,compression=yes'
alias umount-lxc='fusermount3 -u ~/workspace/crescer/crescer-lxc'

# ===== FUNCTIONS =====
pj() {
  local base_path="$HOME/workspace/projects"
  local selected project_name

  if [ -z "$1" ]; then
    selected=$(find "$base_path" -maxdepth 1 -mindepth 1 -type d | fzf --prompt="Select the project: " --height=40%)
    [ -z "$selected" ] && echo "❌ Cancelado." && return 1
    project_name=$(basename "$selected")
  else
    project_name="$1"
    selected="$base_path/$project_name"
  fi

  [ ! -d "$selected" ] && echo "❌ Projeto '$project_name' não encontrado." && return 1
  cd "$selected" || return

  if tmux has-session -t "$project_name" 2>/dev/null; then
    tmux attach-session -t "$project_name"
  else
    tmux new-session -d -s "$project_name" -n Editor -c "$selected"
    tmux send-keys -t "$project_name:Editor" 'nvim' C-m
    tmux new-window -t "$project_name" -n Misc -c "$selected"
    tmux attach-session -t "$project_name"
  fi
}

# ---- Pomodoro ----
declare -A pomo_options=( ["work"]="50" ["break"]="10" )

pomodoro() {
  if [[ -n "$1" && -n "${pomo_options[$1]}" ]]; then
    val=$1
    echo "$val" | lolcat
    timer "${pomo_options[$val]}m"
    notify-send "Pomodoro" "$val session completed!" -i alarm
  fi
}

alias wo="pomodoro work"
alias br="pomodoro break"

