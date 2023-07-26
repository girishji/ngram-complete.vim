vim9script

import autoload './options.vim'
import autoload './unigram.vim'
import autoload './bigram.vim'

var opts = options.opts

export def Completor(findstart: number, base: string): any
    var line = getline('.')->strpart(0, col('.') - 1)
    var EndsInSpace = () => line =~ '\s$'
    if findstart == 1
	if opts.bigram && EndsInSpace()
	    return line->len() + 1
	endif
	var prefix = line->matchstr('\a\+$')
	return prefix->empty() ? -2 : line->len() - prefix->len() + 1
    elseif findstart == 2
	return 1
    endif

    var items: list<string>
    if opts.bigram
	if EndsInSpace()
	    var pattern = '\v\k+\ze\s+$'
	    var context = line->matchstr(pattern)
	    items = bigram.GetCompletion(context)
	else
	    var pattern = '\v(\k+)\s+(\k+)$'
	    var matches = line->matchlist(pattern)
	    if !matches->empty() && !matches[1]->empty() && !matches[2]->empty()
		items = bigram.GetCompletion(matches[1])
		items->filter((_, v) => v =~# $'\v^{matches[2]}')
	    endif
	    if items->len() < opts.maxCount
		items += unigram.GetCompletion(base)
	    endif
	endif
    else
	items = unigram.GetCompletion(base)
    endif

    var citems = []
    for item in items
	citems->add({ abbr: item, word: item, kind: 'D' })
    endfor
    return citems->slice(0, opts.maxCount)
enddef
