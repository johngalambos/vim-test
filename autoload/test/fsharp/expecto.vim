let g:test#fsharp#expecto#patterns = {
  \ 'test':      ['\v^\s*%(test|testCase)\s"((\w|\s)+)"'],
  \ 'namespace': ['\v^\s*testList\s"((\w|\s)+)"']
\}

if !exists('g:test#fsharp#expecto#file_pattern')
  echomsg('testing the pattern for fsharp')
  let g:test#fsharp#expecto#file_pattern = '\v\.fs$'
endif

function! test#fsharp#expecto#test_file(file) abort
  if fnamemodify(a:file, ':t') =~# g:test#fsharp#expecto#file_pattern
    if exists('g:test#fsharp#runner')
      return g:test#fsharp#runner ==# 'expecto'
    else
      return s:is_using_expecto(a:file)
          \ && (search('open Expecto', 'n') > 0)
          \ && (search('[<Tests>]', 'n') > 0)
    endif
    return 1
  endif
endfunction

function! test#fsharp#expecto#build_position(type, position) abort
  let file = a:position['file']
  let filename = fnamemodify(file, ':t:r')
  let project_path = test#fsharp#get_project_path(file)

  if a:type ==# 'nearest'
    let name = s:nearest_test(a:position)
    if !empty(name)
      return ['--run', '"'.name.'"']
    else
      return ['--project', project_path, '--run', 'FullyQualifiedName\~' . filename]
    endif
  elseif a:type ==# 'file'
    return ['--project', project_path,  '--run', 'FullyQualifiedName\~' . filename]
  else
    return ['--project', project_path]
  endif
endfunction

function! test#fsharp#expecto#build_args(args) abort
  let args = a:args
  return [join(args, ' ')]
endfunction

function! test#fsharp#expecto#executable() abort
  return 'dotnet run'
endfunction

function! s:nearest_test(position) abort
  let name = test#base#nearest_test(a:position, g:test#fsharp#expecto#patterns)
  return join(name['namespace'] + name['test'], '/')
endfunction

function! s:is_using_expecto(file) abort
  let l:project_path = test#fsharp#get_project_path(a:file)
  return filereadable(l:project_path) 
      \ && match(
          \ readfile(l:project_path), 
          \ 'PackageReference.*Expecto')
endfunction
