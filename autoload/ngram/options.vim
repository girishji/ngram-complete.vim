vim9script

export var opts: dict<any> = {
    enable: true,    # Enable this plugin
    priority: 11,    # Higher priority items are shown at the top
    maxCount: 5,     # Maximum number of items shown
    bigram: false,   # 'true' to enable next-word completion
    unigramfile: 'en_1w.txt',
    bigramfile: 'en_2w.txt',
    filetypes: ['text', 'markdown'],
    filetypesComments: [],
    triggerWordLen: 1, # Minimum number of characters needed to trigger completion menu.
}

export def GetPath(fname: string): string
    var scripts = getscriptinfo({ name: 'ngram-complete.vim' })
    if scripts->empty()
        return ''
    endif
    var path = scripts[0].name
    path = fnamemodify(path, ':p:h:h')
    var fpath = $'{path}/data/{fname}'
    return filereadable(fpath) ? fpath : $'{path}\data\{fname}'
enddef

export def GetUnigramFile(): string
    return GetPath(opts.unigramfile)
enddef

export def GetBigramFile(): string
    return GetPath(opts.bigramfile)
enddef

