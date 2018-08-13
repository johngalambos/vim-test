let s:slash = (has('win32') || has('win64')) && fnamemodify(&shell, ':t') ==? 'cmd.exe' ? '\' : '/'

let g:test#fsharp#patterns = {
  \ 'test':      ['\v^\s*let ``(\w+)``'],
  \ 'namespace': ['\v^\s*module (\w+)', '\v^\s*namespace ((\w|\.)+)'],
\}

if !exists('g:test#fsharp#dotnettest#file_pattern')
  echomsg('testing the pattern for fsharp')
  let g:test#fsharp#dotnettest#file_pattern = '\v\.fs$'
endif

function! test#fsharp#dotnettest#test_file(file) abort
  if fnamemodify(a:file, ':t') =~# g:test#fsharp#dotnettest#file_pattern
    if exists('g:test#fsharp#runner')
      return g:test#fsharp#runner ==# 'dotnettest'
    endif
    return 1
  endif
endfunction

function! test#fsharp#dotnettest#get_project_path(file) abort
  let l:filepath = fnamemodify(a:file, ':p:h')
  let l:project_files = s:get_project_files(l:filepath)
  let l:search_for_fsproj = 1

  while len(l:project_files) == 0 && l:search_for_fsproj
    let l:filepath_parts = split(l:filepath, s:slash)
    let l:search_for_fsproj = len(l:filepath_parts) > 1
    " only want the forward slash at the root dir for non-windows machines
    let l:filepath = substitute(s:slash, '\', '', '').join(l:filepath_parts[0:-2], s:slash)
    let l:project_files = s:get_project_files(l:filepath)
  endwhile

  if len(l:project_files) == 0
    throw 'Unable to find .fsproj file, a .fsproj file is required to make use of the `dotnet test` command.'
  endif

  return l:project_files[0]
endfunction

function! test#fsharp#dotnettest#build_position(type, position) abort
  let file = a:position['file']
  let filename = fnamemodify(file, ':t:r')
  let project_path = test#fsharp#dotnettest#get_project_path(file)

  if a:type ==# 'nearest'
    let name = s:nearest_test(a:position)
    if !empty(name)
      return [project_path, '--filter', 'FullyQualifiedName\~' . name]
    else
      return [project_path, '--filter', 'FullyQualifiedName\~' . filename]
    endif
  elseif a:type ==# 'file'
    return [project_path,  '--filter', 'FullyQualifiedName\~' . filename]
  else
    return [project_path]
  endif
endfunction

function! test#fsharp#dotnettest#build_args(args) abort
  let args = a:args
  return [join(args, ' ')]
endfunction

function! test#fsharp#dotnettest#executable() abort
  return 'dotnet test'
endfunction

function! s:nearest_test(position) abort
  let name = test#base#nearest_test(a:position, g:test#fsharp#patterns)
  return join(name['namespace'] + name['test'], '.')
endfunction

function! s:get_project_files(filepath) abort
  return split(glob(a:filepath . s:slash . '*.fsproj'), '\n')
endfunction
