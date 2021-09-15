" Source config files
source $HOME/.config/nvim/config/plugin.vimrc
source $HOME/.config/nvim/config/bindings-vimwiki.vimrc
source $HOME/.config/nvim/config/init.vimrc
source $HOME/.config/nvim/config/general.vimrc
source $HOME/.config/nvim/config/bindings.vimrc
source $HOME/.config/nvim/config/functions.vimrc

" Python dependencies
let g:python_host_prog=expand('$HOME/.pyenv/versions/neovim2/bin/python')
let g:python3_host_prog=expand('$HOME/.pyenv/versions/neovim3/bin/python')

" Local overrides
let $LOCALFILE=expand("$HOME/.nvim_local.vimrc")
if filereadable($LOCALFILE)
    source $LOCALFILE
endif
