let s:slash = (has('win32') || has('win64')) && fnamemodify(&shell, ':t') ==? 'cmd.exe' ? '\' : '/'

function! test#fsharp#get_project_path(file) abort
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

function! s:get_project_files(filepath) abort
  return split(glob(a:filepath . s:slash . '*.fsproj'), '\n')
endfunction

" This is copy of test#base#nearest test with the exception that we allow
" modules and namespaces to occur at the same indent level as the tests
" themselves
function! test#fsharp#nearest_test(position, patterns) abort
  let test        = []
  let namespace   = []
  let last_indent = -1

  for line in reverse(getbufline(a:position['file'], 1, a:position['line']))
    let test_match      = s:find_match(line, a:patterns['test'])
    let namespace_match = s:find_match(line, a:patterns['namespace'])

    let indent = len(matchstr(line, '^\s*'))
    if !empty(test_match) && last_indent == -1
      call add(test, filter(test_match[1:], '!empty(v:val)')[0])
      let last_indent = indent
    elseif !empty(namespace_match) && (indent <= last_indent || last_indent == -1)
      call add(namespace, filter(namespace_match[1:], '!empty(v:val)')[0])
      let last_indent = indent
    endif
  endfor

  return {'test': test, 'namespace': reverse(namespace)}
endfunction

function! s:find_match(line, patterns) abort
  let matches = map(copy(a:patterns), 'matchlist(a:line, v:val)')
  return get(filter(matches, '!empty(v:val)'), 0, [])
endfunction
