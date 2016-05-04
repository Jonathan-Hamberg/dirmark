function SetUp()
  " project/
  "   +-- .git/
  "   +-- foo/
  "   |     +-- bar.txt
  "   +-- baz.txt
  "   +-- quux.z
  let tmpdir = resolve(fnamemodify(tempname(), ':h'))
  let s:project_dir = tmpdir.'/project'
  silent call mkdir(s:project_dir.'/_git', 'p')
  silent call mkdir(s:project_dir.'/foo', 'p')
  silent call writefile([], s:project_dir.'/foo/bar.txt')
  silent call writefile([], s:project_dir.'/baz.txt')
  silent call writefile([], s:project_dir.'/quux.z')

  let s:non_project_file = tempname()
  silent call writefile([], s:non_project_file)

  let g:rooter_patterns = ['_git/']
  let s:cwd = getcwd()
  let s:targets = g:rooter_targets
  let g:rooter_targets = '/,*'
endfunction

function TearDown()
  call delete(s:project_dir, 'rf')
  call delete(s:non_project_file)
  let g:rooter_targets = s:targets
  execute ':cd' s:cwd
endfunction



function Test_file_in_project()
  execute 'edit' s:project_dir.'/baz.txt'
  call assert_equal(s:project_dir, getcwd())
endfunction

function Test_file_in_project_subdir()
  execute 'edit' s:project_dir.'/foo/bar.txt'
  call assert_equal(s:project_dir, getcwd())
endfunction

function Test_dir_in_project()
  execute 'edit' s:project_dir.'/foo'
  " FIXME: test fails without invoking Rooter manually.  I have no idea why.
  execute ':Rooter'
  call assert_equal(s:project_dir, getcwd())
endfunction

function Test_project_dir()
  execute 'edit' s:project_dir
  " FIXME: test fails without invoking Rooter manually.  I have no idea why.
  execute ':Rooter'
  call assert_equal(s:project_dir, getcwd())
endfunction

function Test_non_project_file_default()
  let cwd = getcwd()
  execute 'edit' s:non_project_file
  call assert_equal(cwd, getcwd())
endfunction

function Test_non_project_file_change_to_parent()
  let g:rooter_change_directory_for_non_project_files = 'current'
  execute 'edit' s:non_project_file
  call assert_equal(expand('%:p:h'), getcwd())
  let g:rooter_change_directory_for_non_project_files = ''
endfunction

function Test_non_project_file_change_to_home()
  let g:rooter_change_directory_for_non_project_files = 'home'
  execute 'edit' s:non_project_file
  call assert_equal(expand('~'), getcwd())
  let g:rooter_change_directory_for_non_project_files = ''
endfunction

function Test_target_directories_only()
  let cwd = getcwd()
  let g:rooter_targets = '/'

  execute 'edit' s:project_dir.'/baz.txt'
  call assert_equal(cwd, getcwd())

  execute 'edit' s:project_dir.'/foo'
  " FIXME: test fails without invoking Rooter manually.  I have no idea why.
  execute ':Rooter'
  call assert_equal(s:project_dir, getcwd())
endfunction

function Test_target_some_files_only()
  let cwd = getcwd()
  let g:rooter_targets = '*.txt'

  execute 'edit' s:project_dir.'/baz.txt'
  call assert_equal(s:project_dir, getcwd())

  execute ':cd' cwd
  execute 'edit' s:project_dir.'/quux.z'
  call assert_equal(cwd, getcwd())
endfunction
