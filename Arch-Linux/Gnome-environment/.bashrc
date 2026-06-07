# Configurações de Histórico
HISTFILE=~/.bash_history
HISTSIZE=10000
HISTFILESIZE=10000
shopt -s histappend
export HISTCONTROL=ignoredups

# Ativação de autocompletação padrão do Bash
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# --- ADICIONE O BLE.SH AQUI (Deve ser carregado ANTES dos aliases e do prompt) ---
# Instalação padrão geralmente fica em ~/.local/share/blesh/ble.sh
if [[ -f ~/.local/share/blesh/ble.sh ]]; then
    source ~/.local/share/blesh/ble.sh --noattach
fi

# Aliases de editores e utilitários
alias nano='micro'
alias grep='grep --color=auto'
alias bashconf='micro ~/.bashrc'
alias bashsave='source ~/.bashrc'
alias activate='source .venv/bin/activate'
alias cmatrix='unimatrix -n -s 96 -l o -c'
alias netconf='micro /etc/network/interfaces'

# Aliases condicionados ao tipo de terminal (Eza)
if [ "$TERM" != "linux" ]; then
    alias ls='eza --icons'
    alias ll='eza -lh --icons --git --group-directories-first'
    alias la='eza -a --icons --group-directories-first'
    alias lla='eza -lah --icons --git --group-directories-first'
    alias tree='eza --tree --icons=always'
else
    alias ls='eza'
    alias ll='eza -lh --git --group-directories-first'
    alias la='eza -a --group-directories-first'
    alias lla='eza -lah --git --group-directories-first'
    alias tree='eza --tree'
fi

# Função para obter o ambiente virtual Python ativo
function get_venv() {
    if [[ -n "$VIRTUAL_ENV" ]]; then
        echo -e "\[\e[1;32m\]($(basename "$VIRTUAL_ENV"))\[\e[0m\] "
    fi
}

export VIRTUAL_ENV_DISABLE_PROMPT=1

# Função para extrair a branch atual do Git
function get_git_branch() {
    local branch
    if branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null); then
        echo -e "\[\e[35m\][$branch]\[\e[0m\] "
    fi
}

# Construção do Prompt (PS1) do Bash
PROMPT_COMMAND='PS1="\n$(get_venv)\[\e[36m\]\u\[\e[0m\]@\[\e[37m\]\h\[\e[0m\]:\[\e[33m\]\w\[\e[0m\] $(get_git_branch)\$ "'

# --- ANEXAR O BLE.SH AO PROMPT ---
if [[ -f ~/.local/share/blesh/ble.sh ]]; then
    ble-attach
fi

# Comando padrão para comando não encontrado
if [ -f /usr/share/doc/pkgfile/command-not-found.bash ]; then
    source /usr/share/doc/pkgfile/command-not-found.bash
fi

# Path ajustado pelo pipx
export PATH="$PATH:/home/luizsousa/.local/bin"
