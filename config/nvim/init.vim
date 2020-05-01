" Source config files
source $HOME/.config/nvim/config/init.vimrc
source $HOME/.config/nvim/config/general.vimrc
source $HOME/.config/nvim/config/plugin.vimrc
source $HOME/.config/nvim/config/bindings.vimrc
source $HOME/.config/nvim/config/functions.vimrc

" Local overrides
let $LOCALFILE=expand("$HOME/.nvim_local.vimrc")
if filereadable($LOCALFILE)
    source $LOCALFILE
endif
