vim9script

export var opts: dict<any> = {
    maxCount: 5,
    bigram: true,
    unigramfile: 'count_1w.txt',
    bigramfile: 'count_2w.txt',
}

def GetPath(fname: string): string
    var scripts = getscriptinfo({ name: 'ngram-complete.vim/plugin' })
    if scripts->empty()
	return ''
    endif
    var path = scripts[0].name
    path = fnamemodify(path, ':p:h')
    return $'{path}/../data/{fname}'
enddef

export def GetUnigramFile(): string
    return GetPath(opts.unigramfile)
enddef

export def GetBigramFile(): string
    return GetPath(opts.bigramfile)
enddef

