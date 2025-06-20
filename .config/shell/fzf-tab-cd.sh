##!/usr/bin/env zsh
## Minimalist fzf-tab configuration with elegant cda function
## Save as ~/.config/zsh/fzf-tab-enhanced.zsh
## Source in .zshrc with: source ~/.config/zsh/fzf-tab-enhanced.zsh
#
## ═══════════════════════════════════════════════════════════════════════════════
## Basic completion settings
## ═══════════════════════════════════════════════════════════════════════════════
#zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
#zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
#zstyle ':completion:*' menu no
#
## ═══════════════════════════════════════════════════════════════════════════════
## Enhanced preview matching your cdf script
## ═══════════════════════════════════════════════════════════════════════════════
#zstyle ':fzf-tab:complete:cd:*' fzf-preview '
#ph=$(tput lines 2>/dev/null || echo 24);
#pw=$(tput cols 2>/dev/null || echo 80);
#if (( ph < 30 )); then
#  preview_lines=5;
#else
#  preview_lines=10;
#fi;
#item="$realpath";
#if [[ "$item" == *".." ]]; then
#  parent=$(dirname "$(pwd)");
#  echo "⬆️  Directório pai: $parent";
#  echo;
#  echo "Conteúdo (até $preview_lines linhas):";
#  if command -v eza >/dev/null 2>&1; then
#    eza -lah --color=always "$parent" 2>/dev/null | head -n $preview_lines;
#  else
#    ls -la "$parent" 2>/dev/null | head -n $preview_lines;
#  fi;
#elif [[ -d "$item" ]]; then
#  echo "📁 $item/";
#  echo;
#  echo "Conteúdo (até $preview_lines linhas):";
#  if command -v eza >/dev/null 2>&1; then
#    if (( pw >= 60 )); then
#      eza -lah --group-directories-first --icons --color=always "$item" 2>/dev/null | head -n $preview_lines;
#    else
#      eza -lah --group-directories-first --color=always "$item" 2>/dev/null | head -n $preview_lines;
#    fi;
#  else
#    ls -la "$item" 2>/dev/null | head -n $preview_lines;
#  fi;
#elif [[ -f "$item" ]]; then
#  size=$(stat -f%z "$item" 2>/dev/null || stat -c%s "$item" 2>/dev/null);
#  if command -v numfmt >/dev/null 2>&1; then
#    hsize=$(numfmt --to=iec "$size" 2>/dev/null);
#  else
#    hsize="$size";
#  fi;
#  echo "📄 $item ($hsize bytes)";
#  ftype=$(file -b "$item" 2>/dev/null);
#  echo "🔍 $ftype";
#  if file "$item" 2>/dev/null | grep -qE "text|ASCII|UTF-8"; then
#    echo;
#    echo "📖 Pré-visualização (até $preview_lines linhas):";
#    head -n $preview_lines "$item" 2>/dev/null;
#  fi;
#fi'
#
## ═══════════════════════════════════════════════════════════════════════════════
## Responsive preview window & clean styling
## ═══════════════════════════════════════════════════════════════════════════════
#zstyle ':fzf-tab:complete:cd:*' fzf-preview-window 'eval "
#term_height=\$(tput lines 2>/dev/null || echo 24);
#term_width=\$(tput cols 2>/dev/null || echo 80);
#if (( term_height < 25 || term_width < 80 )); then
#  echo \"down:40%:wrap\";
#else
#  echo \"right:50%:wrap\";
#fi"'
#
#zstyle ':fzf-tab:complete:cd:*' fzf-flags \
#  '--height=80%' \
#  '--layout=reverse' \
#  '--ansi' \
#  '--exact' \
#  '--bind=ctrl-u:execute-silent(echo ..)+accept' \
#  '--bind=ctrl-p:toggle-preview' \
#  '--header=Enter: entrar | Ctrl-u: pai | Ctrl-p: preview | Esc: sair'
#
## ═══════════════════════════════════════════════════════════════════════════════
## fzf-tab general settings
## ═══════════════════════════════════════════════════════════════════════════════
#zstyle ':fzf-tab:*' use-fzf-default-opts yes
#zstyle ':fzf-tab:*' group-colors $'\033[94m' $'\033[32m' $'\033[33m' $'\033[35m' $'\033[31m'
#
## ═══════════════════════════════════════════════════════════════════════════════
## The elegant cda function - shows all files including hidden ones
## ═══════════════════════════════════════════════════════════════════════════════
#
## Create custom completion function for cda that includes hidden files
#_cda() {
#    # Enable globdots for this completion only
#    local -a _comp_options
#    _comp_options+=(globdots)
#
#    # Use the standard _cd completion but with globdots enabled
#    _cd "$@"
#}
#
## Define the cda function
#cda() {
#    # Simple wrapper around cd - the magic happens in the completion
#    cd "$@"
#}
#
## Register the custom completion for cda
#compdef _cda cda
#
## ═══════════════════════════════════════════════════════════════════════════════
## Custom preview for cda to show it includes hidden files
## ═══════════════════════════════════════════════════════════════════════════════
#zstyle ':fzf-tab:complete:cda:*' fzf-preview '
#ph=$(tput lines 2>/dev/null || echo 24);
#pw=$(tput cols 2>/dev/null || echo 80);
#if (( ph < 30 )); then
#  preview_lines=5;
#else
#  preview_lines=10;
#fi;
#item="$realpath";
#if [[ "$item" == *".." ]]; then
#  parent=$(dirname "$(pwd)");
#  echo "⬆️  Directório pai: $parent";
#  echo;
#  echo "Conteúdo incluindo ocultos (até $preview_lines linhas):";
#  if command -v eza >/dev/null 2>&1; then
#    eza -lah --color=always "$parent" 2>/dev/null | head -n $preview_lines;
#  else
#    ls -la "$parent" 2>/dev/null | head -n $preview_lines;
#  fi;
#elif [[ -d "$item" ]]; then
#  echo "📁 $item/ $(if [[ "$item" == .* ]]; then echo "(oculto)"; fi)";
#  echo;
#  echo "Conteúdo incluindo ocultos (até $preview_lines linhas):";
#  if command -v eza >/dev/null 2>&1; then
#    if (( pw >= 60 )); then
#      eza -lah --group-directories-first --icons --color=always "$item" 2>/dev/null | head -n $preview_lines;
#    else
#      eza -lah --group-directories-first --color=always "$item" 2>/dev/null | head -n $preview_lines;
#    fi;
#  else
#    ls -la "$item" 2>/dev/null | head -n $preview_lines;
#  fi;
#elif [[ -f "$item" ]]; then
#  size=$(stat -f%z "$item" 2>/dev/null || stat -c%s "$item" 2>/dev/null);
#  if command -v numfmt >/dev/null 2>&1; then
#    hsize=$(numfmt --to=iec "$size" 2>/dev/null);
#  else
#    hsize="$size";
#  fi;
#  echo "📄 $item ($hsize bytes) $(if [[ "$item" == .* ]]; then echo "(oculto)"; fi)";
#  ftype=$(file -b "$item" 2>/dev/null);
#  echo "🔍 $ftype";
#  if file "$item" 2>/dev/null | grep -qE "text|ASCII|UTF-8"; then
#    echo;
#    echo "📖 Pré-visualização (até $preview_lines linhas):";
#    head -n $preview_lines "$item" 2>/dev/null;
#  fi;
#fi'
#
## Copy the same responsive preview settings for cda
#zstyle ':fzf-tab:complete:cda:*' fzf-preview-window 'eval "
#term_height=\$(tput lines 2>/dev/null || echo 24);
#term_width=\$(tput cols 2>/dev/null || echo 80);
#if (( term_height < 25 || term_width < 80 )); then
#  echo \"down:40%:wrap\";
#else
#  echo \"right:50%:wrap\";
#fi"'
#
#zstyle ':fzf-tab:complete:cda:*' fzf-flags \
#  '--height=80%' \
#  '--layout=reverse' \
#  '--ansi' \
#  '--exact' \
#  '--bind=ctrl-u:execute-silent(echo ..)+accept' \
#  '--bind=ctrl-p:toggle-preview' \
#  '--header=Enter: entrar | Ctrl-u: pai | Ctrl-p: preview | 👻: incluindo ocultos | Esc: sair'
#!/usr/bin/env zsh
# Minimalist fzf-tab configuration with elegant cda function
# Save as ~/.config/zsh/fzf-tab-enhanced.zsh
# Source in .zshrc with: source ~/.config/zsh/fzf-tab-enhanced.zsh

# ═══════════════════════════════════════════════════════════════════════════════
# Basic completion settings
# ═══════════════════════════════════════════════════════════════════════════════
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no

# ═══════════════════════════════════════════════════════════════════════════════
# SOLUÇÃO 1: Ativar globdots globalmente para cda (RECOMENDADA)
# ═══════════════════════════════════════════════════════════════════════════════
# Esta é a forma mais simples e eficaz
# cda function removed to avoid conflicts with Oh My Zsh aliases

# ═══════════════════════════════════════════════════════════════════════════════
# SOLUÇÃO ALTERNATIVA 2: Completion customizada com globdots
# ═══════════════════════════════════════════════════════════════════════════════
# Se preferir ter mais controlo sobre a completion
cda_alternative() {
    # Guardar opções atuais
    local oldopts
    [[ -o globdots ]] && oldopts=globdots
    
    # Ativar globdots temporariamente
    setopt localoptions globdots
    
    # Chamar a completion padrão do cd
    _cd "$@"
}

# Para usar esta alternativa, descomente a linha abaixo e comente a linha "compdef cda=cd" acima
# compdef _cda_alternative cda

# ═══════════════════════════════════════════════════════════════════════════════
# SOLUÇÃO 3: Para mostrar ficheiros ocultos SEMPRE (em todo o zsh)
# ═══════════════════════════════════════════════════════════════════════════════
# Se quiser que TODOS os comandos mostrem ficheiros ocultos, adicione isto ao seu .zshrc:

# ═══════════════════════════════════════════════════════════════════════════════
# Enhanced preview matching your cdf script
# ═══════════════════════════════════════════════════════════════════════════════
zstyle ':fzf-tab:complete:cd:*' fzf-preview '
ph=$(tput lines 2>/dev/null || echo 24);
pw=$(tput cols 2>/dev/null || echo 80);
if (( ph < 30 )); then
  preview_lines=5;
else
  preview_lines=10;
fi;
item="$realpath";
if [[ "$item" == *".." ]]; then
  parent=$(dirname "$(pwd)");
  echo "⬆️  Directório pai: $parent";
  echo;
  echo "Conteúdo (até $preview_lines linhas):";
  if command -v eza >/dev/null 2>&1; then
    eza -lah --color=always "$parent" 2>/dev/null | head -n $preview_lines;
  else
    ls -la "$parent" 2>/dev/null | head -n $preview_lines;
  fi;
elif [[ -d "$item" ]]; then
  echo "📁 $item/";
  echo;
  echo "Conteúdo (até $preview_lines linhas):";
  if command -v eza >/dev/null 2>&1; then
    if (( pw >= 60 )); then
      eza -lah --group-directories-first --icons --color=always "$item" 2>/dev/null | head -n $preview_lines;
    else
      eza -lah --group-directories-first --color=always "$item" 2>/dev/null | head -n $preview_lines;
    fi;
  else
    ls -la "$item" 2>/dev/null | head -n $preview_lines;
  fi;
elif [[ -f "$item" ]]; then
  size=$(stat -f%z "$item" 2>/dev/null || stat -c%s "$item" 2>/dev/null);
  if command -v numfmt >/dev/null 2>&1; then
    hsize=$(numfmt --to=iec "$size" 2>/dev/null);
  else
    hsize="$size";
  fi;
  echo "📄 $item ($hsize bytes)";
  ftype=$(file -b "$item" 2>/dev/null);
  echo "🔍 $ftype";
  if file "$item" 2>/dev/null | grep -qE "text|ASCII|UTF-8"; then
    echo;
    echo "📖 Pré-visualização (até $preview_lines linhas):";
    head -n $preview_lines "$item" 2>/dev/null;
  fi;
fi'

# ═══════════════════════════════════════════════════════════════════════════════
# Responsive preview window & clean styling
# ═══════════════════════════════════════════════════════════════════════════════
zstyle ':fzf-tab:complete:cd:*' fzf-preview-window 'eval "
term_height=\$(tput lines 2>/dev/null || echo 24);
term_width=\$(tput cols 2>/dev/null || echo 80);
if (( term_height < 25 || term_width < 80 )); then
  echo \"down:40%:wrap\";
else
  echo \"right:50%:wrap\";
fi"'

zstyle ':fzf-tab:complete:cd:*' fzf-flags \
  '--height=80%' \
  '--layout=reverse' \
  '--ansi' \
  '--exact' \
  '--bind=ctrl-u:execute-silent(echo ..)+accept' \
  '--bind=ctrl-p:toggle-preview' \
  '--header=Enter: entrar | Ctrl-u: pai | Ctrl-p: preview | Esc: sair'

# ═══════════════════════════════════════════════════════════════════════════════
# Custom preview for cda to show it includes hidden files
# ═══════════════════════════════════════════════════════════════════════════════
zstyle ':fzf-tab:complete:cda:*' fzf-preview '
ph=$(tput lines 2>/dev/null || echo 24);
pw=$(tput cols 2>/dev/null || echo 80);
if (( ph < 30 )); then
  preview_lines=5;
else
  preview_lines=10;
fi;
item="$realpath";
if [[ "$item" == *".." ]]; then
  parent=$(dirname "$(pwd)");
  echo "⬆️  Directório pai: $parent";
  echo;
  echo "Conteúdo incluindo ocultos (até $preview_lines linhas):";
  if command -v eza >/dev/null 2>&1; then
    eza -lah --color=always "$parent" 2>/dev/null | head -n $preview_lines;
  else
    ls -la "$parent" 2>/dev/null | head -n $preview_lines;
  fi;
elif [[ -d "$item" ]]; then
  echo "📁 $item/ $(if [[ "$item" == .* ]]; then echo "(oculto)"; fi)";
  echo;
  echo "Conteúdo incluindo ocultos (até $preview_lines linhas):";
  if command -v eza >/dev/null 2>&1; then
    if (( pw >= 60 )); then
      eza -lah --group-directories-first --icons --color=always "$item" 2>/dev/null | head -n $preview_lines;
    else
      eza -lah --group-directories-first --color=always "$item" 2>/dev/null | head -n $preview_lines;
    fi;
  else
    ls -la "$item" 2>/dev/null | head -n $preview_lines;
  fi;
elif [[ -f "$item" ]]; then
  size=$(stat -f%z "$item" 2>/dev/null || stat -c%s "$item" 2>/dev/null);
  if command -v numfmt >/dev/null 2>&1; then
    hsize=$(numfmt --to=iec "$size" 2>/dev/null);
  else
    hsize="$size";
  fi;
  echo "📄 $item ($hsize bytes) $(if [[ "$item" == .* ]]; then echo "(oculto)"; fi)";
  ftype=$(file -b "$item" 2>/dev/null);
  echo "🔍 $ftype";
  if file "$item" 2>/dev/null | grep -qE "text|ASCII|UTF-8"; then
    echo;
    echo "📖 Pré-visualização (até $preview_lines linhas):";
    head -n $preview_lines "$item" 2>/dev/null;
  fi;
fi'

# Copy the same responsive preview settings for cda
zstyle ':fzf-tab:complete:cda:*' fzf-preview-window 'eval "
term_height=\$(tput lines 2>/dev/null || echo 24);
term_width=\$(tput cols 2>/dev/null || echo 80);
if (( term_height < 25 || term_width < 80 )); then
  echo \"down:40%:wrap\";
else
  echo \"right:50%:wrap\";
fi"'

zstyle ':fzf-tab:complete:cda:*' fzf-flags \
  '--height=80%' \
  '--layout=reverse' \
  '--ansi' \
  '--exact' \
  '--bind=ctrl-u:execute-silent(echo ..)+accept' \
  '--bind=ctrl-p:toggle-preview' \
  '--header=Enter: entrar | Ctrl-u: pai | Ctrl-p: preview | 👻: incluindo ocultos | Esc: sair'

# ═══════════════════════════════════════════════════════════════════════════════
# fzf-tab general settings
# ═══════════════════════════════════════════════════════════════════════════════
zstyle ':fzf-tab:*' use-fzf-default-opts yes
zstyle ':fzf-tab:*' group-colors $'\033[94m' $'\033[32m' $'\033[33m' $'\033[35m' $'\033[31m'

# ═══════════════════════════════════════════════════════════════════════════════
# EXTRA: Função para alternar globdots on/off dinamicamente
# ═══════════════════════════════════════════════════════════════════════════════
toggle-hidden-files() {
    if [[ -o globdots ]]; then
        unsetopt globdots
        echo "🙈 Ficheiros ocultos: DESATIVADOS"
    else
        setopt globdots
        echo "👻 Ficheiros ocultos: ATIVADOS"
    fi
}

# Pode criar um atalho para esta função:
# bindkey '^H' toggle-hidden-files  # Ctrl+H para alternar

# ═══════════════════════════════════════════════════════════════════════════════
# DEBUGGING: Para testar se globdots está ativo
# ═══════════════════════════════════════════════════════════════════════════════
check-globdots() {
    if [[ -o globdots ]]; then
        echo "✅ globdots está ATIVO - ficheiros ocultos serão mostrados"
    else
        echo "❌ globdots está INATIVO - ficheiros ocultos NÃO serão mostrados"
    fi
}
