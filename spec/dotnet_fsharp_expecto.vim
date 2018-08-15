source spec/support/helpers.vim

function! s:remove_path(cmd)
  return substitute(a:cmd, '\/.*\/spec\/fixtures\/dotnet_fsharp_expecto\/', '', '')
endfunction

describe "expecto"

  before
    cd spec/fixtures/dotnet_fsharp_expecto
  end

  after
    call Teardown()
    cd -
  end

  it "runs nearest test"

    view +8 Program.fs
    TestNearest

    let actual = s:remove_path(g:test#last_command)
    Expect actual == 'dotnet run --run "Test Group/A simple test"'


  end

  it "runs nearest testCase"

    view +13 Program.fs
    TestNearest

    let actual = s:remove_path(g:test#last_command)
    Expect actual == 'dotnet run --run "Test Group/A simple test2"'

  end


end
