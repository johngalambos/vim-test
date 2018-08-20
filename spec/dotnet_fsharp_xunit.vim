source spec/support/helpers.vim

function! s:remove_path(cmd)
  return substitute(a:cmd, '\/.*\/spec\/fixtures\/dotnet_fsharp_xunit\/', '', '')
endfunction

describe "xunit"

  before
    cd spec/fixtures/dotnet_fsharp_xunit
  end

  after
    call Teardown()
    cd -
  end

  it "runs nearest test"

    view +8 Tests.fs
    TestNearest

    let actual = s:remove_path(g:test#last_command)
    Expect actual == 'dotnet test dotnet_fsharp_xunit.fsproj --filter "FullyQualifiedName=Tests.My test"'


  end

end
