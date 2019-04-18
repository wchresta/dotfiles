" This vim script creates a new promptline from promptline.vim

let g:promptline_preset = {
  \ 'a' : [ promptline#slices#host() ],
  \ 'b' : [ promptline#slices#user() ],
  \ 'c' : [ promptline#slices#cwd() ],
  \ 'y' : [ promptline#slices#vcs_branch()
  \       , promptline#slices#git_status()
  \       ],
  \ 'warn' : [ promptline#slices#last_exit_code() ]
  \ }
let g:promptline_theme = 'airline'

promptline#slices#vcs_branch({ 'git': 1, 'hg': 0, 'svn': 0, 'fossil': 0 })

" Create the output file
PromptlineSnapshot! ~/.airline-shellprompt-full.sh

