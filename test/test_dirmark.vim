set noswapfile
function SuiteSetUp()

  let s:cwd = getcwd()

  call mkdir('tmp/dst/test', 'p')
  call mkdir('tmp/tofish', 'p')
  call mkdir('tmp/bashmarks', 'p')
  call mkdir('tmp/zshmarks', 'p')

  " create common paths for destination directories
  let target_dir = dirmark#joinPath(s:cwd, 'tmp', 'dst', 'test')

  " create .sdirs file for testing.
  let sdirs_path = dirmark#joinPath(s:cwd, 'tmp', 'bashmarks', '.sdirs')
  let sdir_entries = ['export DIR_test=' . target_dir, 'export DIR_bashmarks_test=' . target_dir]
  call writefile(sdir_entries, sdirs_path)

  let g:dirmark_sdirs = sdirs_path

  " create tofish files for testing.
  let to_dir = dirmark#joinPath(s:cwd, 'tmp', 'tofish')
  let tofish_src1 = dirmark#joinPath(s:cwd, 'tmp', 'tofish', 'test')
  let tofish_src2 = dirmark#joinPath(s:cwd, 'tmp', 'tofish', 'tofish_test')

  call system("ln -s " . target_dir . " " . tofish_src1)
  call system("ln -s " . target_dir . " " . tofish_src2)

  let g:dirmark_to_dir = to_dir

  " create zshmarks .bookmarks file for testing.
  let zshmarks_path = dirmark#joinPath(s:cwd, 'tmp', 'zshmarks', '.bookmarks')
  let zshmarks_entries = [target_dir . '|test', target_dir . '|zshmarks_test']
  call writefile(zshmarks_entries, zshmarks_path)

  let g:dirmark_zshmarks=zshmarks_path

endfunction

function SuiteTearDown()
  execute 'cd' s:cwd

  call delete('tmp', 'rf')
endfunction

function SetUp()
endfunction

function TearDown()
  execute 'cd' s:cwd
endfunction

function Test_go_bashmarks()
    let success = dirmark#BashmarksGo('test')
    call assert_equal(dirmark#joinPath(s:cwd, 'tmp', 'dst', 'test'), getcwd())

    call dirmark#BashmarksGo('bashmarks_test')
    call assert_equal(dirmark#joinPath(s:cwd, 'tmp', 'dst', 'test'), getcwd())
endfunction

function Test_go_zshmarks()
    let success = dirmark#ZshmarksGo('test')
    call assert_equal(dirmark#joinPath(s:cwd, 'tmp', 'dst', 'test'), getcwd())

    call dirmark#ZshmarksGo('zshmarks_test')
    call assert_equal(dirmark#joinPath(s:cwd, 'tmp', 'dst', 'test'), getcwd())
endfunction

function Test_list_tofish()
    let m = dirmark#TofishList()

    call assert_equal(m['test'], dirmark#joinPath(s:cwd, 'tmp', 'dst', 'test'))
    call assert_equal(m['tofish_test'], dirmark#joinPath(s:cwd, 'tmp', 'dst', 'test'))
endfunction

function Test_list_bashmarks()
    let m = dirmark#BashmarksList()

    call assert_equal(m['test'], dirmark#joinPath(s:cwd, 'tmp', 'dst', 'test'))
    call assert_equal(m['bashmarks_test'], dirmark#joinPath(s:cwd, 'tmp', 'dst', 'test'))
endfunction

function Test_list_zshmarks()
    let m = dirmark#ZshmarksList()

    call assert_equal(m['test'], dirmark#joinPath(s:cwd, 'tmp', 'dst', 'test'))
    call assert_equal(m['zshmarks_test'], dirmark#joinPath(s:cwd, 'tmp', 'dst', 'test'))
endfunction

function Test_go_tofish()
    let success = dirmark#TofishGo('test')
    call assert_equal(dirmark#joinPath(s:cwd, 'tmp', 'dst', 'test'), getcwd())

    call dirmark#TofishGo('tofish_test')
    call assert_equal(dirmark#joinPath(s:cwd, 'tmp', 'dst', 'test'), getcwd())
endfunction

function Test_dirmark_go()
    call DirmarkGo('test')
    call assert_equal(dirmark#joinPath(s:cwd, 'tmp', 'dst', 'test'), getcwd())
endfunction

