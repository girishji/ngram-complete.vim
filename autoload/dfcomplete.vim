vim9script

export var options: dict<any> = {
    maxCount: 5,
}

var dictlines = []

def GetDictLines(): list<any>
    if dictlines->empty()
	var scripts = getscriptinfo({ name: 'dictionary-frequency.vim/plugin' })
	if scripts->empty()
	    return []
	endif
	var path = scripts[0].name
	path = fnamemodify(path, ':p:h')
	var fname = $'{path}/../data/count_1w.txt'
	dictlines = fname->readfile()
    endif
    return dictlines
enddef

const batchsize: number = 1000
var onedict = {}
var twodict = {}

def Worker(startidx: number, timer: number)
    def AddWord(worddict: dict<any>, key: string, word: string, limit: bool)
	if !worddict->has_key(key)
	    worddict[key] = []
	endif
	if !limit || worddict[key]->len() < options.maxCount
	    worddict[key]->add(word)
	endif
    enddef
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
	timer_start(0, function(Worker, [startidx + batchsize]))
    endif
enddef

export def SetupDict()
    Worker(0, 0)
enddef

def GetDictCompletion(prefix: string): list<string>
    if prefix->len() == 1
	return onedict[prefix->tolower()]->copy()
    endif
    if prefix->len() == 2
	return twodict[prefix->tolower()]->copy()->slice(0, options.maxCount)
    endif
    return twodict[prefix->tolower()->slice(0, 2)]->copy()->filter((_, v) => v =~? $'\v^{prefix}')
enddef

export def Completor(findstart: number, base: string): any
    var line = getline('.')->strpart(0, col('.') - 1)
    if findstart == 1
	var prefix = line->matchstr('\a\+$')
	return prefix->empty() ? -2 : line->len() - prefix->len() + 1
    elseif findstart == 2
	return 1
    endif

    var items = GetDictCompletion(base)
    if base =~ '^\u\+$' # uppercase
	items->map((_, v) => v->toupper())
    elseif base =~ '^\u' # camelcase
	items->map((_, v) => $'{v[0]->toupper()}{v->slice(1)}')
    endif

    var citems = []
    for item in items
	citems->add({ abbr: item, word: item, kind: 'D' })
    endfor
    return citems->slice(0, options.maxCount)
enddef
