vim9script

import autoload './options.vim' as opts

var dictlines = []
def GetDictLines(): list<any>
    if dictlines->empty()
	var fpath = opts.GetBigramFile()
	if !fpath->empty()
	    dictlines = fpath->readfile()
	endif
    endif
    return dictlines
enddef

const batchsize: number = 10000
var bigrams = {}

# var starttime: list<any>

# Note: Takes 1.7 seconds to setup the dictionary. Use timer to enable concurrent execution.
export def SetupDict(startidx: number = 0, timer: number = 0)
    # if startidx == 0
	# starttime = reltime()
    # endif
    if !bigrams->empty()
	return
    endif
    if startidx < GetDictLines()->len()
	var endidx = min([startidx + batchsize, GetDictLines()->len()])
	var idx = startidx
	while idx < endidx
	    var line = GetDictLines()[idx]
	    var firstword = line->matchstr('\k\+')
	    var secondword = line->matchstr('\v\k+\s+\zs\k+')
	    if firstword->empty() || secondword->empty()
		continue
	    endif
	    if !bigrams->has_key(firstword)
		bigrams[firstword] = []
	    endif
	    if bigrams[firstword]->len() < opts.opts.maxCount
		bigrams[firstword]->add(secondword)
	    endif
	    idx += 1
	endwhile
	timer_start(0, function(SetupDict, [startidx + batchsize]))
    endif
    # if startidx != 0
	# echom starttime->reltime()->reltimestr()
    # endif
enddef

export def GetCompletion(prefix: string): list<string>
    return bigrams->get(prefix, [])
enddef
