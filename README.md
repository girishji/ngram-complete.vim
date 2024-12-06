#### Dictionary and Next-Word Completion for Vim using Google Ngrams English Corpus

Traditional dictionary based word completion is more or less useless since it
prioritizes obsure words over frequently used words. A better approach is to use
unigrams (list of most frequently used words in English corpus).

Data comes from [ngrams](http://norvig.com/ngrams/) sourced from _Google Web
Trillion Word Corpus_. Unigrams file has 333,333 most frequently occuring words and
bigrams file has 286,358 pairs of words. No additional download is necessary.
Unigrams complete single words while bigrams suggest next word. Both uppercase
and camelcase are respected. Bigram completion is turned off by default.

There is also an option to complete words within the comment section of source code.

This plugin is a helper for Vim completion plugin
[Vimcomplete](https://github.com/girishji/vimcomplete).

_Note: Unigram and bigram files cannot be sorted alphabetically. To make search
efficient associative arrays (|Dictionaries|) are used. There is one-time
upfront cost (~0.8 sec for unigrams and bigrams each) associated with creating
data structures. There is no degradation in startup performance since
processing is done asynchronously._

[![asciicast](https://asciinema.org/a/ROsT1n4Z0mJJM1thotftJcb1U.svg)](https://asciinema.org/a/ROsT1n4Z0mJJM1thotftJcb1U)

# Requirements

- Vim >= 9.0
- [Vimcomplete](https://github.com/girishji/vimcomplete)

# Installation

Install this plugin after installing [Vimcomplete](https://github.com/girishji/vimcomplete).

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
    enable: true,    # Enable this plugin
    priority: 10,    # Higher priority items are shown at the top
    maxCount: 5,     # Maximum number of items shown
    bigram: false,   # 'true' to enable next-word completion
    filetypes: ['text', 'markdown'], # Enable completion for these filetypes only ('*' for all)
    filetypesComments: [], # Enable completion only in comments
    triggerWordLen: 1, # Minimum number of characters needed to trigger completion menu.
}
```

It is possible to complete words only in the comment section of source code
files. `filetypesComments` should be set to a list of file types (ex. `['c',
'cpp', 'python']`).

Options can be modified using `g:VimCompleteOptionsSet()`. It takes a dictionary
argument. If you are using [vim-plug](https://github.com/junegunn/vim-plug),
call this function through _VimEnter_ autocommand event.

```
autocmd VimEnter * g:VimCompleteOptionsSet(options)
```
