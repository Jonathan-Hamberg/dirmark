" Vim plugin to follow directory bookmarks from shell.
"
" Copyright 2023-2023 , <jonathanhamberg@gmail.com>
" Released under the MIT licence.

if exists('g:loaded_dirmark')
  finish
endif
let g:loaded_dirmark = 1

let g:dirmark_todir = get(g:, 'dirmark_todir', '$HOME/.tofish')
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

    let db = resolve(expand(g:dirmark_todir))

    " If file doesn't exist return empty dictionary.
    if !isdirectory(db)
        return m
    endif

    for fname in readdir(db)
        let resolved = trim(system('readlink ' . dirmark#joinPath(g:dirmark_todir, fname)))

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

    let db = expand(g:dirmark_sdirs)

    " If file doesn't exist return empty dictionary.
    if !filereadable(db)
        return m
    endif

    for line in readfile(db)
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

    " If file doesn't exist return empty dictionary.
    let db = expand(g:dirmark_zshmarks)
    if !filereadable(db)
        return m
    endif

    for line in readfile(db)
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

    let m_tofish = dirmark#TofishList()
    let m_bashmarks = dirmark#BashmarksList()
    let m_zshmarks = dirmark#ZshmarksList()

    let m = extend(m_tofish, m_bashmarks)
    let m = extend(m, m_zshmarks)

    if !m->has_key(a:name)
        call s:msg_error("bookmark not found: " . a:name)
        return 0
    endif

    let dir = expand(m[a:name])

    if isdirectory(dir)
        execute 'cd ' . dir
        return 1
    else
        call s:msg_error("directory not found: " . dir)
        return 0
    endif
endfunction

command! -nargs=1 DirmarkGo call DirmarkGo(<f-args>)
