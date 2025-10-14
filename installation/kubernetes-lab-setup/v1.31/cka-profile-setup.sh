#!/bin/sh

# Source: http://kubernetes.io/docs/getting-started-guides/kubeadm/
# 04-10-2024
# CKA Training Cluster Installation
# 

### setup terminal
apt-get install -y bash-completion binutils

cat <<EOF>>~/.vimrc
set ts=2 sw=2 sts=2 et ai number
syntax on
colorscheme ron
" set paste
EOF

#echo 'colorscheme ron' >> ~/.vimrc
#echo 'set tabstop=2' >> ~/.vimrc
#echo 'set shiftwidth=2' >> ~/.vimrc
#echo 'set expandtab' >> ~/.vimrc
#echo 'source <(kubectl completion bash)' >> ~/.bashrc
#echo 'alias k=kubectl' >> ~/.bashrc
#echo 'alias c=clear' >> ~/.bashrc
#echo 'complete -F __start_kubectl k' >> ~/.bashrc


cat <<EOF>> ~/.bashrc
source <(kubectl completion bash)
alias k=kubectl
alias c=clear
complete -F __start_kubectl k
#complete -F __start_kubectl k
EOF

sed -i '1s/^/force_color_prompt=yes\n/' ~/.bashrc

# short alias to set/show context/namespace (only works for bash and bash-compatible shells, current context to be set before using kn to set namespace)
alias kx='f() { [ "$1" ] && kubectl config use-context $1 || kubectl config current-context ; } ; f'
alias kn='f() { [ "$1" ] && kubectl config set-context --current --namespace $1 || kubectl config view --minify | grep namespace | cut -d" " -f6 ; } ; f'
alias kn='k config set-context --current --namespace '
alias kcc='k config get-contexts'