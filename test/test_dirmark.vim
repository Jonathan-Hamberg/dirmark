set noswapfile
function SuiteSetUp()

  let s:cwd = getcwd()

  call mkdir('tmp/dst/test', 'p')
  call mkdir('tmp/tofish', 'p')
  call mkdir('tmp/bashmarks', 'p')

  " create common paths for destination directories
  let target_dir = dirmark#joinPath(s:cwd, 'tmp', 'dst', 'test')

  " create .sdirs file for testing.
  let sdirs_path = dirmark#joinPath(s:cwd, 'tmp', 'bashmarks', '.sdirs')
  let sdir_entries = ['export DIR_test=' . target_dir, 'export DIR_bashmark_test=' . target_dir]

  call writefile(sdir_entries, sdirs_path)

  " create tofish files for testing.
  let tofish_src1 = dirmark#joinPath(s:cwd, 'tmp', 'tofish', 'test')
  let tofish_src2 = dirmark#joinPath(s:cwd, 'tmp', 'tofish', 'tofish_test')

  call system("ln -s " . target_dir . " " . tofish_src1)
  call system("ln -s " . target_dir . " " . tofish_src2)

endfunction

function SuiteTearDown()
  call Log("SuiteTearDown")
  execute 'cd' s:cwd

  call delete('tmp', 'rf')
endfunction

function SetUp()
endfunction

function TearDown()
  execute 'cd' s:cwd
endfunction

function Test_go_bashmarks()
    if dirmark#BashmarksExists()
        let success = dirmark#BashmarksGo('test')
        call assert_equal(dirmark#joinPath(s:cwd, 'tmp', 'dst', 'test'), getcwd())

        call dirmark#BashmarksGo('bashmarks_test')
        call assert_equal(dirmark#joinPath(s:cwd, 'tmp', 'dst', 'test'), getcwd())
    endif
endfunction

function Test_go_tofish()
    if dirmark#TofishExists()
        let success = dirmark#TofishGo('test')
        call assert_equal(dirmark#joinPath(s:cwd, 'tmp', 'dst', 'test'), getcwd())

        call dirmark#TofishGo('tofish_test')
        call assert_equal(dirmark#joinPath(s:cwd, 'tmp', 'dst', 'test'), getcwd())
    endif
endfunction


function Test_dirmark_go()
    call DirmarkGo('test')
    call assert_equal(dirmark#joinPath(s:cwd, 'tmp', 'dst', 'test'), getcwd())
endfunction

