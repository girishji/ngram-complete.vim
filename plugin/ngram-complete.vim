if !has('vim9script') ||  v:version < 900
    " Needs Vim version 9.0 and above
    finish
endif

vim9script

if !get(g:, 'loaded_vimcomplete', false)
    finish
endif

g:loaded_ngram_complete = true

import autoload '../autoload/ngram/ngcomplete.vim' as complete
import autoload '../autoload/ngram/options.vim' as opts
import autoload '../autoload/ngram/unigram.vim'
import autoload '../autoload/ngram/bigram.vim'
import autoload 'vimcomplete/completor.vim'

# Download dictionary if it doesn't exist yet
# if empty(glob($'~/.vim/data/count_1w.txt')) && executable('curl')
#     silent !curl -fLo ~/.vim/data/count_1w.txt --create-dirs
# 		\ http://norvig.com/ngrams/count_1w.txt
# endif

const name = 'ngram'

def NgramSetupDict()
    unigram.SetupDict()
    if opts.opts.bigram
        bigram.SetupDict()
    endif
enddef

def UniGramUpdateDict(new_lang: string)
  var lang_pattern = '\v(^|,)\zs\a\a\ze(_\a\a)?($|,)'

  var matched = new_lang->matchstr(lang_pattern)->tolower()
  matched = matched->substitute('\s', '', 'g')

  if !matched->empty()
      var dict = opts.getPath(matched .. '_1w.txt')
      if dict->filereadable()
          opts.opts.unigramfile = dict
          unigram.SetupDict()
      endif
  endif
enddef

def Register()
    var o = opts.opts
    if !o->has_key('enable') || o.enable
        var ftypes = o->get('filetypes', [])->copy()
        ftypes->extend(o->get('filetypesComments', []))
        completor.Register(name, complete.Completor, ftypes, o->get('priority', 10))
        var ft = ftypes->join(',')
        if !ft->empty()
            NgramSetupDict() # Register() is called through VimEnter (after ft is detected)
            augroup NgramAutocmds | autocmd!
                exec $'autocmd BufEnter {ft} NgramSetupDict()'
                autocmd OptionSet spelllang
                    b:common_words_explicit = 1
                    UniGramUpdateDict(v:option_new)
                autocmd OptionSet spell
                    if &spell && !empty(&spelllang) && !exists('b:common_words_explicit')
                        UniGramUpdateDict(&spelllang)
                    endif
                autocmd BufWinEnter *
                    if &spell && !empty(&spelllang) && !exists('b:common_words_explicit')
                        UniGramUpdateDict(&spelllang)
                    endif
            augroup END
        endif
    else
        completor.Unregister(name)
    endif
enddef

autocmd User VimCompleteLoaded ++once Register()

def OptionsChanged()
    var options = completor.GetOptions(name)
    if !options->empty()
        opts.opts->extend(options)
        Register()
    endif
enddef

autocmd User VimCompleteOptionsChanged ++once OptionsChanged()
