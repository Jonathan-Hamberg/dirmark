" Vim plugin to follow directory bookmarks from shell.
"
" Copyright 2023-2023 , <jonathanhamberg@gmail.com>
" Released under the MIT licence.

if exists('g:loaded_dirmark')
  finish
endif
let g:loaded_dirmark = 1

let g:dirmark_to_dir = get(g:, 'dirmark_to_dir', '$HOME/.tofish')
let g:dirmark_sdirs = get(g:, 'dirmark_sdirs', '$HOME/.sdirs')
let g:dirmark_zshmarks = get(g:, 'dirmark_zshmarks', '$HOME/.bookmarks')

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

function! dirmark#TofishList()
    let m = {}
    for fname in readdir(resolve(g:dirmark_to_dir))
        let resolved = trim(system('readlink ' . dirmark#joinPath(g:dirmark_to_dir, fname)))

        let m[fname] = resolved
    endfor

    return m 
endfunction

function! dirmark#TofishGo(name)
    let m = dirmark#TofishList()

    if !m->has_key(a:name)
        call s:msg_error("bookmark not found: " . a:name)
        return 0
    endif

    let dir = m[a:name]

    if isdirectory(dir)
        execute 'cd ' . dir
        return 1
    else
        call s:msg_error("directory not found: " . dir)
        return 0
    endif

endfunction

function! dirmark#BashmarksList()
    let m = {}
    for line in readfile(resolve(g:dirmark_sdirs))
        let s = split(line, '=')
        let name = s[0][11:]
        let resolved = join(s[1:], '=')
        let m[name] = resolved
    endfor
    return m
endfunction

function! dirmark#BashmarksGo(name)
    let m = dirmark#BashmarksList()

    if !m->has_key(a:name)
        call s:msg_error("bookmark not found: " . a:name)
        return 0
    endif

    let dir = m[a:name]

    if isdirectory(dir)
        execute 'cd ' . dir
        return 1
    else
        call s:msg_error("directory not found: " . dir)
        return 0
    endif
endfunction

function! dirmark#ZshmarksList()
    let m = {}
    for line in readfile(resolve(g:dirmark_zshmarks))
        let s = split(line, '|')
        let name = s[1]
        let resolved = s[0]
        let m[name] = resolved
    endfor
    return m
endfunction

function! dirmark#ZshmarksGo(name)
    let m = dirmark#ZshmarksList()

    if !m->has_key(a:name)
        call s:msg_error("bookmark not found: " . a:name)
        return 0
    endif

    let dir = m[a:name]

    if isdirectory(dir)
        execute 'cd ' . dir
        return 1
    else
        call s:msg_error("directory not found: " . dir)
        return 0
    endif
endfunction

function! DirmarkGo(name)
    let ret = dirmark#TofishGo(a:name)
    if ret != 0
        let ret = dirmark#BashmarksGo(a:name)
    endif
    if ret != 0
        let ret = dirmark#ZshmarksGo(a:name)
    endif
    return ret
endfunction

command! -nargs=1 DirmarkGo call DirmarkGo(<f-args>)
