# Ngram Completion Based on Google Ngrams Viewer

This plugin is a helper for Vim completion plugin
[Vimcomplete](https://github.com/girishji/vimcomplete). It suggests (completes)
next word based on bigram, trigram and 4-gram word association by querying [Google Ngrams
Viewer](https://books.google.com/ngrams/). No additional packages or databases are required.


**Note:** Google ngram queries can be slow and can take over a second. However,
Vim's responsiveness is not affected because queries are asynchronous (`:h job`) and results
are cached. I implemented this out of curiosity but I do not find it very
useful. Your mileage may vary.

![image](https://i.imgur.com/HHDt2yh.png)

# Requirements

- Vim >= 9.0

# Installation

Install this plugin after [Vimcomplete](https://github.com/girishji/vimcomplete).

Install using [vim-plug](https://github.com/junegunn/vim-plug).

```
vim9script
plug#begin()
Plug 'girishji/ngram-complete.vim'
plug#end()
```

For those who prefer legacy script.

```
call plug#begin()
Plug 'girishji/ngram-complete.vim'
call plug#end()
```

Or use Vim's builtin package manager.

# Configuration

Default options are as follows.

```
vim9script
export var options: dict<any> = {
    priority: 11,    # Higher priority items are shown at the top
    maxCount: 10,    # Maximum number of next-word items shown
    cacheSize: 100,  # Each ngram takes up one slot in the cache
}
autocmd VimEnter * g:VimCompleteOptionsSet(options)
```
