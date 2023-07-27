vim9script

import autoload './options.vim' as opts

# It takes 0.9 sec to build dictionary (parse each line) from lines read from
# file. It takes .024 sec for readfile(). Use timer_start() to enable
# concurrent execution so that Vim remains responsive.

var dictlines = []
def GetDictLines(): list<any>
    if dictlines->empty()
	var fpath = opts.GetUnigramFile()
	if !fpath->empty()
	    dictlines = fpath->readfile()
	endif
    endif
    return dictlines
enddef

const batchsize: number = 10000
var onedict = {}
var twodict = {}

export def SetupDict(startidx: number = 0, timer: number = 0)
    def AddWord(worddict: dict<any>, key: string, word: string, limit: bool)
	if !worddict->has_key(key)
	    worddict[key] = []
	endif
	if !limit || worddict[key]->len() < opts.opts.maxCount
	    worddict[key]->add(word)
	endif
    enddef
    if !onedict->empty()
	return
    endif
    if startidx < GetDictLines()->len() 
	var endidx = min([startidx + batchsize, GetDictLines()->len()])
	var idx = startidx
	while idx < endidx
	    var line = GetDictLines()[idx]
	    var word = line->matchstr('\a\+')
	    if !word->empty()
		AddWord(onedict, word[0], word, true)
	    endif
	    if word->len() > 1
		AddWord(twodict, word[0 : 1], word, false)
	    endif
	    idx += 1
	endwhile
	timer_start(0, function(SetupDict, [startidx + batchsize]))
    endif
enddef

export def GetCompletion(prefix: string): list<string>
    var items: list<string>
    if prefix->len() == 1
	items = onedict->get(prefix->tolower(), [])->copy()
    elseif prefix->len() == 2
	items = twodict->get(prefix->tolower(), [])->copy()->slice(0, opts.opts.maxCount)
    else
	items = twodict->get(prefix->tolower()->slice(0, 2), [])->copy()->filter((_, v) => v =~? $'\v^{prefix}')
    endif

    if prefix =~ '^\u\+$' # uppercase
	items->map((_, v) => v->toupper())
    elseif prefix =~ '^\u' # camelcase
	items->map((_, v) => $'{v[0]->toupper()}{v->slice(1)}')
    endif
    return items
enddef
