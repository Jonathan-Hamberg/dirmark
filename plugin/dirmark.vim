" Vim plugin to follow directory bookmarks from shell.
"
" Copyright 2023-2023 , <jonathanhamberg@gmail.com>
" Released under the MIT licence.

if exists('g:loaded_dirmark')
  finish
endif
let g:loaded_dirmark = 1

func! s:msg_error(msg) abort
  redraw | echohl ErrorMsg | echomsg 'dirmark:' a:msg | echohl None
endf

" \ on Windows unless shellslash is set, / everywhere else.
function! dirmark#getPathSeparator()
  return !exists("+shellslash") || &shellslash ? '/' : '\'
endfunction

" @return: true of given path name has trailing path separator
" ex: 
"	echo hasTrailingPathSeparator("/my/path") = 0
"	echo hasTrailingPathSeparator("/my/path/") = 1
function! dirmark#hasTrailingPathSeparator(filePath)
	if match(a:filePath, '.*[/\\]$') >= 0
		return 1
	endif	
	return 0
endfunction	


" concatenate file path components
" Args: supports two versions of arguments
"	- single argument of type List
"	  e.g. dirmark#joinPath(['/path', 'to' , 'file']) - '/path/to/file'
"	- separate arguments 
"	  e.g. dirmark#joinPath('/path', 'to' , 'file') - '/path/to/file'
function! dirmark#joinPath(...)
	if a:0 < 1
		throw "Argument required."
	endif	
	let filePathList = []
	if 3 == type(a:1) " first argument is a List
		let filePathList = a:1
	else "path components are passed as separate arguments
		let filePathList = a:000
	endif
	let resPath = ''
	for path in filePathList
		if len(resPath)>0 
			if dirmark#hasTrailingPathSeparator(resPath)
				let resPath .= path
			else
				let resPath = join([resPath, path], dirmark#getPathSeparator())
			endif
		else
			let resPath = path
		endif	
	endfor
	return resPath
endfunction	

function! dirmark#TofishExists()
    let out = system('type -t to')
    call Log(out)
    call Log(v:shell_error)
    return  v:shell_error == 0
endfunction

function! dirmark#TofishGo(name)
    let dir = trim(system('to resolve ' . a:name))

    call Log(dir)
    if isdirectory(dir)
        execute 'cd ' . dir
        return 1
    else
        call s:msg_error("directory not found: b" . dir . "b")
        return 0
    endif

endfunction

function! dirmark#BashmarksExists()
    let out = system('type -t g')
    call Log(out)
    call Log(v:shell_error)
    return  v:shell_error == 0
endfunction

function! dirmark#BashmarksGo(name)
    let dir = trim(system('p ' . a:name))

    if isdirectory(dir)
        execute 'cd ' . dir
    else
        call s:msg_error("bookmark not found")
    endif
endfunction

function! DirmarkGo(name)
    if dirmark#TofishExists()
        call dirmark#TofishGo(a:name)
    elseif dirmark#BashmarksExists() 
        call dirmark#BashmarksGo(a:name)
    endif
endfunction

command! -nargs=1 DirmarkGo call DirmarkGo(<f-args>)
