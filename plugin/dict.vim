if !has('vim9script') ||  v:version < 900
    " Needs Vim version 9.0 and above
    finish
endif

vim9script

import 'vimcompletor.vim'
import autoload '../autoload/dfcomplete.vim' as complete

# Download dictionary if it doesn't exist yet
# if empty(glob($'~/.vim/data/count_1w.txt')) && executable('curl')
#     silent !curl -fLo ~/.vim/data/count_1w.txt --create-dirs
# 		\ http://norvig.com/ngrams/count_1w.txt
# endif

def Register()
    var o = complete.options
    if !o->has_key('enable') || o.enable
	var ftypes = o->get('filetypes', ['text', 'markdown'])
	vimcompletor.Register('dictfreq', complete.Completor, ftypes, o->get('priority', 10))
	if &ft->empty() || ftypes->index(&ft) != -1
	    complete.SetupDict()
	endif
    else
	vimcompletor.Unregister('dictfreq')
    endif
enddef

autocmd User VimCompleteLoaded ++once Register()

def OptionsChanged()
    var opts = vimcompletor.GetOptions('dictfreq')
    if !opts->empty()
	complete.options->extend(opts)
	Register()
    endif
enddef

autocmd User VimCompleteOptionsChanged ++once OptionsChanged()
