# /etc/zshrc: system-wide .zshrc file for zsh(1).
#
# This file is sourced only for interactive shells. It
# should contain commands to set up aliases, functions,
# options, key bindings, etc.
#
# Global Order: zshenv, zprofile, zshrc, zlogin

# $Id: zshrc,v 1.2 2002/02/24 03:22:26 8host Exp $

# Security!
# NOT SECURE!!!: [[ $UID == $GID ]] && umask 002 || umask 022

export ZSHRC_LOCAL="$HOME/.local/zsh/zshrc"
export ZSHRC_LOCAL_MACHINE="$HOME/.zsh/local-"`uname -n`
export ZSHRC_LOCAL_ALIASES="$HOME/.zsh/aliases"

for f in $ZSHRC_LOCAL $ZSHRC_LOCAL_MACHINE $ZSHRC_LOCAL_ALIASES ; do
	if [[ -r $f ]]; then
		source $f
	fi
done

#bindkey -M emacs "\033[3~" delete-char
#bindkey -M emacs "\033OH" beginning-of-line
#bindkey -M emacs "\033OF" end-of-line
#bindkey -M vicmd "\033[3~" vi-delete-char
#bindkey -M vicmd "\033OH" vi-beginning-of-line
#bindkey -M vicmd "\033OF" vi-end-of-line
#
##bindkey -s '\033[3~' '^D'
#bindkey -M emacs '\033[1~' beginning-of-line
#bindkey -M emacs '\033[4~' end-of-line
## bindkey -v             # vi key bindings
#bindkey -e               # emacs key bindings
#bindkey ' ' magic-space  # also do history expansino on space


# The following line is meant for compatibility with previous versions.
# The use of these module aliases is deprecated.
#zmodload -A cap=zsh/cap clone=zsh/clone compctl=zsh/compctl complete=zsh/complete complist=zsh/complete computil=zsh/computil deltochar=zsh/deltochar example=zsh/example files=zsh/files mapfile=zsh/mapfile mathfunc=zsh/mathfunc parameter=zsh/parameter rlimits=zsh/rlimits sched=zsh/sched stat=zsh/stat zftp=zsh/zftp zle=zsh/zle zleparameter=zsh/zleparameter

# $Id: zshrc,v 1.2 2002/02/24 03:22:26 8host Exp $
#
# This file gives examples of possible programmable completions (compctl).
# You can either put the compctl commands in your .zshrc file, or put them
# in a separate file (say .zcompctl) and source it from your .zshrc file.
#
# These are just examples. Use and modify to personal taste.  Copying
# this file without thought will needlessly increase zsh's memory usage
# and startup time.
#
# For a detailed description of how these work, check the zshcompctl man
# page.
#
#------------------------------------------------------------------------------
hosts=("${(s: :)${(s:	:)${${(f)$(</etc/hosts)}%%\#*}#*[ 	]*}}")

# groups=( $(cut -d: -f1 /etc/group) )
# groups=( $(ypcat group.byname | cut -d: -f1) ) # if you use NIS

# It can be done without forking, but it used too much memory in old zsh's:
groups=( "${${(f)$(</etc/group)}%%:*}" )
#groups=( "${${(f)$(ypcat groups)}%%:*}" ) # if you use NIS

# Completion for zsh builtins.
compctl -z -P '%' bg
compctl -j -P '%' fg jobs disown
compctl -j -P '%' + -s '`ps x | tail +2 | cut -c1-5`' wait
compctl -A shift
compctl -c type whence where which man
compctl -m -x 'W[1,-*d*]' -n - 'W[1,-*a*]' -a - 'W[1,-*f*]' -F -- unhash
compctl -m -q -S '=' -x 'W[1,-*d*] n[1,=]' -/ - \
	'W[1,-*d*]' -n -q -S '=' - 'n[1,=]' -/g '*(*)' -- hash
compctl -F functions unfunction
compctl -k '(al dc dl do le up al bl cd ce cl cr
	dc dl do ho is le ma nd nl se so up)' echotc
compctl -a unalias
compctl -v getln getopts read unset vared
#compctl -v -S '=' -q declare export integer local readonly typeset
compctl -eB -x 'p[1] s[-]' -k '(a f m r)' - \
	'C[1,-*a*]' -ea - 'C[1,-*f*]' -eF - 'C[-1,-*r*]' -ew -- disable
compctl -dB -x 'p[1] s[-]' -k '(a f m r)' - \
	'C[1,-*a*]' -da - 'C[1,-*f*]' -dF - 'C[-1,-*r*]' -dw -- enable
compctl -k "(${(j: :)${(f)$(limit)}%% *})" limit unlimit
compctl -l '' -x 'p[1]' -f -- . source
# Redirection below makes zsh silent when completing unsetopt xtrace
compctl -s '$(setopt 2>/dev/null)' + -o + -x 's[no]' -o -- unsetopt
compctl -s '$(unsetopt 2>/dev/null)' + -o + -x 's[no]' -o -- setopt
compctl -s '${^fpath}/*(N:t)' autoload
compctl -b -x 'W[1,-*[DAN]*],C[-1,-*M]' -s '$(bindkey -l)' -- bindkey
compctl -c -x 'C[-1,-*k]' -A - 'C[-1,-*K]' -F -- compctl
compctl -x 'C[-1,-*e]' -c - 'C[-1,-[ARWI]##]' -f -- fc
compctl -x 'p[1]' - 'p[2,-1]' -l '' -- sched
compctl -x 'C[-1,[+-]o]' -o - 'c[-1,-A]' -A -- set
compctl -b -x 'w[1,-N] p[3]' -F -- zle
compctl -s '${^module_path}/*(N:t:r)' -x \
	'W[1,-*(a*u|u*a)*],W[1,-*a*]p[3,-1]' -B - \
	'W[1,-*u*]' -s '$(zmodload)' -- zmodload

# Anything after nohup is a command by itself with its own completion
compctl -l '' nohup noglob exec nice strace eval - time rusage
compctl -l '' -x 'p[1]' -eB -- builtin
compctl -l '' -x 'p[1]' -em -- command
compctl -x 'p[1]' -c - 'p[2,-1]' -k signals -- trap
#------------------------------------------------------------------------------
# kill takes signal names as the first argument after -, but job names after %
# or PIDs as a last resort
compctl -j -P '%' + -s '`ps x | tail +2 | cut -c1-5`' + \
	-x 's[-] p[1]' -k "($signals[1,-3])" -- kill
#------------------------------------------------------------------------------
compctl -s '$(groups)' + -k groups newgrp
compctl -f -x 'p[1], p[2] C[-1,-*]' -k groups -- chgrp
compctl -f -x 'p[1] n[-1,.], p[2] C[-1,-*] n[-1,.]' -k groups - \
	'p[1], p[2] C[-1,-*]' -u -S '.' -q -- chown
compctl -/g '*.x' rpcgen
compctl -u -x 's[+] c[-1,-f],s[-f+]' -W ~/Mail -f - \
	's[-f],c[-1,-f]' -f -- mail elm
#------------------------------------------------------------------------------
compctl -s "\$(awk '/^[a-zA-Z0-9][^ 	]+:/ {print \$1}' FS=: [mM]akefile)" -x \
	'c[-1,-f]' -f -- make gmake pmake
compctl -f -x 'W[1,*(z*f|f*z)*] p[2]' -/g '*.(tar.gz|tgz|tar.Z|taz)' - \
	'W[1,*f*] p[2]' -/g '*.tar' -- gnutar gtar tar
compctl -f -x 'W[1,*(I*f|f*I)*] p[2]' -/g '*.tar.bz2' -- tar
#------------------------------------------------------------------------------
# rmdir only real directories
compctl -/g '*(/)' rmdir dircmp
#------------------------------------------------------------------------------
# cd/pushd only directories or symbolic links to directories
compctl -/ cd chdir dirs pushd

# Another possibility for cd/pushd is to use it in conjunction with the
# cdmatch function (in the Functions subdirectory of zsh distribution).
#compctl -K cdmatch -S '/' -q -x 'p[2]' -Q -K cdmatch2 - \
#	'S[/][~][./][../]' -g '*(-/)' + -g '*(-/D)' - \
#	'n[-1,/]' -K cdmatch -S '/' -q -- cd chdir pushd
#------------------------------------------------------------------------------
# If the command is rsh, make the first argument complete to hosts and treat the
# rest of the line as a command on its own.
compctl -k hosts -x 'p[2,-1]' -l '' -- rsh ssh

# rlogin takes hosts and users after `-l'
compctl -k hosts -x 'c[-1,-l]' -u -- rlogin 

# rcp: match users, hosts and files initially.  Match files after a :, or hosts
# after an @.  If one argument contains a : then the other matches files only.
# Not quite perfect; compctl just isn't up to it yet.
compctl -u -k hosts -f -x 'n[1,:]' -f - 'n[1,@]' -k hosts -S ':' - \
	'p[1] W[2,*:*]' -f - 'p[1] W[2,*?*]' -u -k hosts -S ':' - \
	'p[2] W[1,*:*]' -f - 'p[2] W[1,*?*]' -u -k hosts -S ':' -- rcp

compctl -k hosts host nslookup rup rusers telnet ping mtr
#------------------------------------------------------------------------------
# strip, profile, and debug only executables.  The compctls for the
# debuggers could be better, of course.
compctl -/g '*(*)' strip gprof adb dbx xdbx ups
compctl -/g '*.[ao]' -/g '*(*)' nm
#------------------------------------------------------------------------------
# shells: compctl needs some more enhancement to do -c properly.
compctl -f -x 'C[-1,-*c]' -c - 'C[-1,[-+]*o]' -o -- bash ksh sh zsh 
#------------------------------------------------------------------------------
# su takes a username and args for the shell.
compctl -u -x 'w[1,-]p[3,-1]' -l sh - 'w[1,-]' -u - 'p[2,-1]' -l sh -- su
#------------------------------------------------------------------------------
# Run ghostscript on postscript files, but if no postscript file matches what
# we already typed, complete directories as the postscript file may not be in
# the current directory.
compctl -/g '*.(e|E|)(ps|PS)' \
	gs ghostview nup psps pstops psmulti psnup psselect
#------------------------------------------------------------------------------
# Similar things for tex, texinfo and dvi files.
compctl -/g '*.tex*' {,la,gla,ams{la,},{g,}sli}tex texi2dvi
compctl -/g '*.dvi' xdvi dvips
#------------------------------------------------------------------------------
# For rcs users, co and rlog from the RCS directory.  We don't want to see
# the RCS and ,v though.
compctl -g 'RCS/*(:s@RCS/@@:s/,v//)' co rlog rcs rcsdiff
#------------------------------------------------------------------------------
# gzip uncompressed files, but gzip -d only gzipped or compressed files
compctl -x 'R[-*[dt],^*]' -/g '*.(gz|z|Z|t[agp]z|tarZ|tz)' + -f - \
    's[]' -/g '^*(.(tz|gz|t[agp]z|tarZ|zip|ZIP|jpg|JPG|gif|GIF|[zZ])|[~#])' \
    + -f -- gzip
compctl -/g '*.(gz|z|Z|t[agp]z|tarZ|tz)' gunzip gzcat zcat
compctl -/g '*.Z' uncompress zmore
compctl -/g '*.F' melt fcat
#------------------------------------------------------------------------------
# ftp takes hostnames
ftphosts=(prep.ai.mit.edu wuarchive.wustl.edu ftp.uu.net ftp.math.gatech.edu)
compctl -k hosts ftp lftp cftp

# Some systems have directories containing indices of ftp servers.
# For example: we have the directory /home/ftp/index/INDEX containing
# files of the form `<name>-INDEX.Z', this leads to:
#compctl -g '/home/ftp/index/INDEX/*-INDEX.Z(:t:r:s/-INDEX//)' ftp tftp
#------------------------------------------------------------------------------
# Change default completion (see the multicomp function in the Function
# subdirectory of the zsh distribution).
#compctl -D -f + -U -K multicomp
# If completion of usernames is slow for you, you may want to add something
# like
#    -x 'C[0,*/*]' -f - 's[~]' -S/ -k users + -u
# where `users' contains the names of the users you want to complete often.
# If you want to use this and to be able to complete named directories after
# the `~' you should add `+ -n' at the end
#------------------------------------------------------------------------------
# This is to complete all directories under /home, even those that are not
# yet mounted (if you use the automounter).

# This is for NIS+ (e.g. Solaris 2.x)
#compctl -Tx 's[/home/] C[0,^/home/*/*]'  -S '/' -s '$(niscat auto_home.org_dir | \
#	awk '\''/export\/[a-zA-Z]*$/ {print $NF}'\'' FS=/)'

# And this is for YP (e.g. SunOS4.x)
#compctl -Tx 's[/home/] C[0,^/home/*/*]' -S '/' -s '$(ypcat auto.home | \
#	awk '\''/export\/[a-zA-Z]*$/ {print $NF}'\'' FS=/)'
#------------------------------------------------------------------------------
# Find is very system dependent, this one is for GNU find.
# Note that 'r[-exec,;]' must come first
if [[ -r /proc/filesystems ]]; then
    # Linux
    filesystems='"${${(f)$(</proc/filesystems)}#*	}"'
else
    filesystems='ufs 4.2 4.3 nfs tmp mfs S51K S52K'
fi
compctl -x 'r[-exec,;][-ok,;]' -l '' - \
's[-]' -s 'daystart {max,min,}depth follow noleaf version xdev
	{a,c,}newer {a,c,m}{min,time} empty false {fs,x,}type gid inum links
	{i,}{l,}name {no,}{user,group} path perm regex size true uid used
	exec {f,}print{f,0,} ok prune ls' - \
	'p[1]' -g '. .. *(-/)' - \
	'C[-1,-((a|c|)newer|fprint(|0|f))]' -f - \
	'c[-1,-fstype]' -s $filesystems - \
	'c[-1,-group]' -k groups - \
	'c[-1,-user]' -u -- find
#------------------------------------------------------------------------------
# Generic completion for C compiler.
compctl -/g "*.[cCoa]" -x 's[-I]' -/ - \
	's[-l]' -s '${(s.:.)^LD_LIBRARY_PATH}/lib*.a(:t:r:s/lib//)' -- cc
#------------------------------------------------------------------------------
# GCC completion, by Andrew Main
# completes to filenames (*.c, *.C, *.o, etc.); to miscellaneous options after
# a -; to various -f options after -f (and similarly -W, -g and -m); and to a
# couple of other things at different points.
# The -l completion is nicked from the cc compctl above.
# The -m completion should be tailored to each system; the one below is i386.
compctl -/g '*.([cCmisSoak]|cc|cxx|ii|k[ih])' -x \
	's[-l]' -s '${(s.:.)^LD_LIBRARY_PATH}/lib*.a(:t:r:s/lib//)' - \
	'c[-1,-x]' -k '(none c objective-c c-header c++ cpp-output
	assembler assembler-with-cpp)' - \
	'c[-1,-o]' -f - \
	'C[-1,-i(nclude|macros)]' -/g '*.h' - \
	'C[-1,-i(dirafter|prefix)]' -/ - \
	's[-B][-I][-L]' -/ - \
	's[-fno-],s[-f]' -k '(all-virtual cond-mismatch dollars-in-identifiers
	enum-int-equiv external-templates asm builtin strict-prototype
	signed-bitfields signd-char this-is-variable unsigned-bitfields
	unsigned-char writable-strings syntax-only pretend-float caller-saves
	cse-follow-jumps cse-skip-blocks delayed-branch elide-constructors
	expensive-optimizations fast-math float-store force-addr force-mem
	inline-functions keep-inline-functions memoize-lookups default-inline
	defer-pop function-cse inline peephole omit-frame-pointer
	rerun-cse-after-loop schedule-insns schedule-insns2 strength-reduce
	thread-jumps unroll-all-loops unroll-loops)' - \
	's[-g]' -k '(coff xcoff xcoff+ dwarf dwarf+ stabs stabs+ gdb)' - \
	's[-mno-][-mno][-m]' -k '(486 soft-float fp-ret-in-387)' - \
	's[-Wno-][-W]' -k '(all aggregate-return cast-align cast-qual
	char-subscript comment conversion enum-clash error format id-clash-6
	implicit inline missing-prototypes missing-declarations nested-externs
	import parentheses pointer-arith redundant-decls return-type shadow
	strict-prototypes switch template-debugging traditional trigraphs
	uninitialized unused write-strings)' - \
	's[-]' -k '(pipe ansi traditional traditional-cpp trigraphs pedantic
	pedantic-errors nostartfiles nostdlib static shared symbolic include
	imacros idirafter iprefix iwithprefix nostdinc nostdinc++ undef)' \
	-X 'Use "-f", "-g", "-m" or "-W" for more options' -- gcc g++
#------------------------------------------------------------------------------
# There are (at least) two ways to complete manual pages.  This one is
# extremely memory expensive if you have lots of man pages
man_var() {
    man_pages=( ${^manpath}/man*/*(N:t:r) )
    compctl -k man_pages -x 'C[-1,-P]' -m - \
	    'R[-*l*,;]' -/g '*.(man|[0-9nlpo](|[a-z]))' -- man
    reply=( $man_pages )
}
#compctl -K man_var -x 'C[-1,-P]' -m - \
#	'R[-*l*,;]' -/g '*.(man|[0-9nlpo](|[a-z]))' -- man

# This one isn't that expensive but somewhat slower
man_glob () {
   local a
   read -cA a
   if [[ $a[2] = -s ]] then         # Or [[ $a[2] = [0-9]* ]] for BSD
     reply=( ${^manpath}/man$a[3]/$1*$2(N:t:r) )
   else
     reply=( ${^manpath}/man*/$1*$2(N:t:r) )
   fi
}
#compctl -K man_glob -x 'C[-1,-P]' -m - \
#	'R[-*l*,;]' -/g '*.(man|[0-9nlpo](|[a-z]))' -- man
#------------------------------------------------------------------------------
# xsetroot: gets possible colours, cursors and bitmaps from wherever.
# Uses two auxiliary functions.  You might need to change the path names.
# The =:- can be omitted if you use a beta6-hzoli4 or later version.
Xcolours() {
  reply=( ${(L)=:-$(awk '{ if (NF = 4) print $4 }' \
	< /usr/openwin/lib/X11/rgb.txt)} )
}
Xcursor() {
  reply=( $(sed -n 's/^#define[	 ][ 	]*XC_\([^ 	]*\)[ 	].*$/\1/p' \
	  < /usr/include/X11/cursorfont.h) )
}
compctl -k '(-help -def -display -cursor -cursor_name -bitmap -mod -fg -bg
	-grey -rv -solid -name)' -x \
	'c[-1,-display]' -s '$DISPLAY' -k hosts -S ':0' - \
	'c[-1,-cursor]' -f -  'c[-2,-cursor]' -f - \
	'c[-1,-bitmap]' -g '/usr/include/X11/bitmaps/*' - \
	'c[-1,-cursor_name]' -K Xcursor - \
	'C[-1,-(solid|fg|bg)]' -K Xcolours -- xsetroot
#------------------------------------------------------------------------------
# dd
compctl -k '(if of conv ibs obs bs cbs files skip file seek count)' \
	-S '=' -x 's[if=], s[of=]' -f - 'C[0,conv=*,*] n[-1,,], s[conv=]' \
	-k '(ascii ebcdic ibm block unblock lcase ucase swap noerror sync)' \
	-q -S ',' - 'n[-1,=]' -X '<number>'  -- dd
#------------------------------------------------------------------------------
# Various MH completions by Peter Stephenson
# You may need to edit where it says *Edit Me*.

# The following three functions are best autoloaded.
# mhcomp completes folders (including subfolders),
# mhfseq completes sequence names and message numbers,
# mhfile completes files in standard MH locations.

function mhcomp {
  # Completion function for MH folders.
  # Works with both + (rel. to top) and @ (rel. to current).
  local nword args pref char mhpath
  read -nc nword
  read -cA args

  pref=$args[$nword]
  char=$pref[1]
  pref=$pref[2,-1]

  # The $(...) here accounts for most of the time spent in this function.
  if [[ $char = + ]]; then
  #    mhpath=$(mhpath +)
  # *Edit Me*: use a hard wired value here: it's faster.
    mhpath=~/Mail
  elif [[ $char = @ ]]; then
    mhpath=$(mhpath)
  fi

  eval "reply=($mhpath/$pref*(N-/))"

  # I'm frankly amazed that this next step works, but it does.
  reply=(${reply#$mhpath/})
}

mhfseq() {
  # Extract MH message names and numbers for completion.  Use of the
  # correct folder, if it is not the current one, requires that it
  # should be the previous command line argument.  If the previous
  # argument is `-draftmessage', a hard wired draft folder name is used.

  local folder foldpath words pos nums
  read -cA words
  read -cn pos

  # Look for a folder name.
  # First try the previous word.
  if [[ $words[$pos-1] = [@+]* ]]; then
    folder=$words[$pos-1]
  # Next look and see if we're looking for a draftmessage
  elif [[ $words[$pos-1] = -draftmessage ]]; then
    # *Edit Me*:  shortcut -- hard-wire draftfolder here
    # Should really look for a +draftfolder argument.
    folder=+drafts
  fi
  # Else use the current folder ($folder empty)

  if [[ $folder = +* ]]; then
  # *Edit Me*:  use hard-wired path with + for speed.
    foldpath=~/Mail/$folder[2,-1]
  else
    foldpath=$(mhpath $folder)
  fi

  # Extract all existing message numbers from the folder.
  nums=($foldpath/<->(N:t))
  # If that worked, look for marked sequences.
  # *Edit Me*: if you never use non-standard sequences, comment out
  # or delete the next three lines.
  if (( $#nums )); then
    nums=($nums $(mark $folder | awk -F: '{print $1}'))
  fi

  # *Edit Me*:  `unseen' is the value of Unseen-Sequence, if it exists;
  set -A reply next cur prev first last all unseen $nums

}

mhfile () {
  # Find an MH file; for use with -form arguments and the like.
  # Use with compctl -K mhfile.

  local mhfpath file
  # *Edit Me*:  Array containing all the places MH will look for templates etc.
  mhfpath=(~/Mail /usr/local/lib/MH)

  # Emulate completeinword behaviour as appropriate
  local wordstr
  if [[ -o completeinword ]]; then
    wordstr='$1*$2'
  else
    wordstr='$1$2*'
  fi

  if [[ $1$2 = */* ]]; then
    # path given: don't search MH locations
    eval "reply=($wordstr(.N))"
  else
    # no path:  only search MH locations.
    eval "reply=(\$mhfpath/$wordstr(.N:t))"
  fi
}

# Note: you must type the initial + or @ of a folder name to get
# completion, even in places where only folder names are allowed.
# Abbreviations for options are not recognised.  Hit tab to complete
# the option name first.
compctl -K mhfseq -x 's[+][@]' -K mhcomp -S / -q - \
  's[-]' -k "(all fast nofast header noheader help list nolist \
  pack nopack pop push recurse norecurse total nototal)" -- folder
compctl -K mhfseq -x 's[+][@],c[-1,-draftfolder] s[+][@]' \
  -K mhcomp -S / -q - 'c[-1,-draftmessage]' -K mhfseq - \
  'C[-1,-(editor|whatnowproc)]' -c - \
  's[-]' -k "(draftfolder draftmessage nodraftfolder editor noedit \
  file form use nouse whatnowproc nowhatnowproc help)" - \
  'c[-1,-form]' -K mhfile -- comp
compctl -K mhfseq -x 's[+][@]' -K mhcomp -S / -q - \
  's[-]' -k "(audit noaudit changecur nochangecur form format \
  file silent nosilent truncate notruncate width help)" - \
  'C[-1,-(audit|form)]' -K mhfile - 'c[-1,-file]' -f + -- inc
compctl -K mhfseq -x 's[+][@]' -K mhcomp -S / -q - \
  's[-]' -k "(sequence add delete list public nopublic zero nozero help)" -- \
  mark
compctl -K mhfseq -x 's[+][@]' \
  -K mhcomp -S / -q - 'c[-1,-file]' -f - 'c[-1,-rmmprov]' -c - \
  's[-]' -k "(draft link nolink preserve nopreserve src file \
  rmmproc normmproc help)" -- refile
compctl -K mhfseq -x 's[+][@]' \
  -K mhcomp -S / -q - 'c[-1,-draftmessage]'  -K mhfseq -\
  's[-]' -k "(annotate noannotate cc nocc draftfolder nodraftfolder \
  draftmessage editor noedit fcc filter form inplace noinplace query \
  noquery width whatnowproc nowhatnowproc help)" - 'c[-1,(cc|nocc)]' \
  -k "(all to cc me)" - 'C[-1,-(filter|form)]' -K mhfile - \
  'C[-1,-(editor|whatnowproc)]' -c -- repl
compctl -K mhfseq -x 's[+][@]' -K mhcomp -S / -q - \
  's[-]' -k "(clear noclear form format header noheader reverse noreverse \
  file help width)" - 'c[-1,-file]' -f - 'c[-1,-form]' -K mhfile -- scan
compctl -K mhfseq -x 's[+][@]'  -K mhcomp -S / -q - \
  's[-]' -k "(draft form moreproc nomoreproc header noheader \
   showproc noshowproc length width help)" - 'C[-1,-(show|more)proc]' -c - \
   'c[-1,-file]' -f - 'c[-1,-form]' -K mhfile - \
   'c[-1,-length]' -s '$LINES' - 'c[-1,-width]' -s '$COLUMNS' -- show next prev
compctl -K mhfseq -x 's[+][@]' -K mhcomp -S / -q - 's[-]' \
  -k "(help)" -- rmm
compctl -K mhfseq -x 's[+][@]' -K mhcomp -S / -q - \
  's[-]' -k "(after before cc date datefield from help list nolist \
  public nopublic search sequence subject to zero nozero not or and \
  lbrace rbrace)" -- pick
compctl -K mhfseq -x 's[+][@]' -K mhcomp -S / -q - 's[-]' \
  -k "(alias check draft draftfolder draftmessage help nocheck \
  nodraftfolder)" -- whom
compctl -K mhfseq -x 's[+][@]' -K mhcomp -S / -q - 's[-]' \
  -k "(file part type list headers noheaders realsize norealsize nolist \
  show serialonly noserialonly form pause nopause noshow store auto noauto \
  nostore cache nocache rcache wcache check nocheck ebcdicsafe noebcdicsafe \
  rfc934mode norfc934mode verbose noverbose help)" - \
  'c[-1,-file]' -f - 'c[-1,-form]' -K mhfile - \
  'C[-1,-[rw]cache]' -k '(public private never ask)' -- mhn
compctl -K mhfseq -x 's[+][@]' -K mhcomp -S / -q - 's[-]' -k '(help)' -- mhpath

##------------------------------------------------------------------------------
## By Bart Schaefer
## CVS -- there's almost no way to make this all-inclusive, but ...
##
#cvsflags=(-H -Q -q -r -w -l -n -t -v -b -e -d)
#cvscmds=(add admin checkout commit diff history import export log rdiff
#	    release remove status tag rtag update)
#
## diff assumes gnu rcs using gnu diff
## log assumes gnu rcs
#
#compctl -k "($cvscmds $cvsflags)" \
#    -x "c[-1,-D]" -k '(today yesterday 1\ week\ ago)' \
#    - "r[add,;][ad,;][new,;]" -k "(-k -m)" -f \
#    - "r[admin,;][adm,;][rcs,;]" -K cvstargets \
#    - "r[checkout,;][co,;][get,;]" -k "(-A -N -P -Q -c -f -l -n -p -q -s -r -D -d -k -j)" \
#    - "r[commit,;][ci,;][com,;]" -k "(-n -R -l -f -m -r)"  -K cvstargets \
#    - "r[diff,;][di,;][dif,;]" -k "(-l -D -r -c -u -b -w)" -K cvstargets \
#    - "r[history,;][hi,;][his,;] c[-1,-u]" -u \
#    - "r[history,;][hi,;][his,;]" \
#	-k "(-T -c -o -m -x -a -e -l -w -D -b -f -n -p -r -t -u)" \
#	-K cvstargets \
#    - "r[import,;][im,;][imp,;]" -k "(-Q -q -I -b -m)" -f \
#    - "r[export,;][ex,;][exp,;]" -k "(-N -Q -f -l -n -q -r -D -d)" -f \
#    - "r[rlog,;][log,;][lo,;]" -k "(-l -R -h -b -t -r -w)" -K cvstargets \
#    - 'r[rlog,;][log,;][lo,;] s[-w] n[-1,,],s[-w]' -u -S , -q \
#    - "r[rdiff,;][patch,;][pa,;]" -k "(-Q -f -l -c -u -s -t -D -r -V)" -K cvstargets \
#    - "r[release,;][re,;][rel,;]" -k "(-Q -d -q)" -f \
#    - "r[remove,;][rm,;][delete,;]" -k "(-l -R)" -K cvstargets \
#    - "r[status,;][st,;][stat,;]" -k "(-v -l -R)" -K cvstargets \
#    - "r[tag,;][ta,;][freeze,;]" -k "(-Q -l -R -q -d -b)" -K cvstargets \
#    - "r[rtag,;][rt,;][rfreeze,;]" -k "(-Q -a -f -l -R -n -q -d -b -r -D)" -f \
#    - "r[update,;][up,;][upd,;]" -k "(-A -P -Q -d -f -l -R -p -q -k -r -D -j -I)" \
#	-K cvstargets \
#    -- cvs
#unset cvsflags cvscmds
#
#cvstargets() {
#    local nword args pref f
#    setopt localoptions nullglob
#    read -nc nword; read -Ac args
#    pref=$args[$nword]
#    if [[ -d $pref:h && ! -d $pref ]]; then
#		pref=$pref:h
#    elif [[ $pref != */* ]]; then
#		pref=
#    fi
#    [[ -n "$pref" && "$pref" != */ ]] && pref=$pref/
#    if [[ -f ${pref}CVS/Entries ]]; then
#		reply=( "${pref}${^${${(f@)$(<${pref}CVS/Entries)}#/}%%/*}"
#		${pref}*/**/CVS(:h) )
#    else
#		reply=( ${pref}*/**/CVS(:h) )
#    fi
#}

#------------------------------------------------------------------------------
# RedHat Linux rpm utility
#
compctl -s '$(rpm -qa)' \
	-x 's[--]' -s 'oldpackage percent replacefiles replacepkgs noscripts
		       root excludedocs includedocs test upgrade test clean
		       short-circuit sign recompile rebuild resign querytags
		       queryformat version help quiet rcfile force hash' - \
	's[ftp:]' -P '//' -s '$(</u/zsh/ftphosts)' -S '/' - \
	'c[-1,--root]' -/ - \
	'c[-1,--rcfile]' -f - \
	'p[1] s[-b]' -k '(p l c i b a)' - \
	'c[-1,--queryformat] N[-1,{]' \
		-s '"${${(f)$(rpm --querytags)}#RPMTAG_}"' -S '}' - \
	'W[1,-q*] C[-1,-([^-]*|)f*]' -f - \
	'W[1,-i*], W[1,-q*] C[-1,-([^-]*|)p*]' \
		-/g '*.rpm' + -f -- rpmbogus
#------------------------------------------------------------------------------
compctl -u -x 'c[-1,-w]' -f -- ac
compctl -/g '*.m(.)' mira
#------------------------------------------------------------------------------
# talk completion: complete local users, or users at hosts listed via rwho
compctl -K talkmatch talk ytalk ytalk3 utalk write xtell tell
function talkmatch {
    local u
    reply=($(users))
    for u in "${${(f)$(rwho 2>/dev/null)}%%:*}"; do
		reply=($reply ${u%% *}@${u##* })
    done
}


