# Simple calculator
function calc() {
	local result="";
	result="$(printf "scale=10;$*\n" | bc --mathlib | tr -d '\\\n')";
	#                       └─ default (when `--mathlib` is used) is 20
	#
	if [[ "$result" == *.* ]]; then
		# improve the output for decimal numbers
		printf "$result" |
		sed -e 's/^\./0./'        `# add "0" for cases like ".5"` \
		    -e 's/^-\./-0./'      `# add "0" for cases like "-.5"`\
		    -e 's/0*$//;s/\.$//';  # remove trailing zeros
	else
		printf "$result";
	fi;
	printf "\n";
}

# Create a new directory and enter it
function mkd() {
	mkdir -p "$@" && cd "$_";
}

# Create a .tar.gz archive, using `zopfli`, `pigz` or `gzip` for compression
function targz() {
	local tmpFile="${@%/}.tar";
	tar -cvf "${tmpFile}" --exclude=".DS_Store" "${@}" || return 1;

	size=$(
		stat -f"%z" "${tmpFile}" 2> /dev/null; # OS X `stat`
		stat -c"%s" "${tmpFile}" 2> /dev/null # GNU `stat`
	);

	local cmd="";
	if (( size < 52428800 )) && hash zopfli 2> /dev/null; then
		# the .tar file is smaller than 50 MB and Zopfli is available; use it
		cmd="zopfli";
	else
		if hash pigz 2> /dev/null; then
			cmd="pigz";
		else
			cmd="gzip";
		fi;
	fi;

	echo "Compressing .tar using \`${cmd}\`…";
	"${cmd}" -v "${tmpFile}" || return 1;
	[ -f "${tmpFile}" ] && rm "${tmpFile}";
	echo "${tmpFile}.gz created successfully.";
}

# Determine size of a file or total size of a directory
function fs() {
	if du -b /dev/null > /dev/null 2>&1; then
		local arg=-sbh;
	else
		local arg=-sh;
	fi
	if [[ -n "$@" ]]; then
		du $arg -- "$@";
	else
		du $arg .[^.]* *;
	fi;
}

# Use Git’s colored diff when available
hash git &>/dev/null;
if [ $? -eq 0 ]; then
	function diff() {
		git diff --no-index --color-words "$@";
	}
fi;

# Create a data URL from a file
function dataurl() {
	local mimeType=$(file -b --mime-type "$1");
	if [[ $mimeType == text/* ]]; then
		mimeType="${mimeType};charset=utf-8";
	fi
	echo "data:${mimeType};base64,$(openssl base64 -in "$1" | tr -d '\n')";
}

# Create a git.io short URL
function gitio() {
	if [ -z "${1}" -o -z "${2}" ]; then
		echo "Usage: \`gitio slug url\`";
		return 1;
	fi;
	curl -i http://git.io/ -F "url=${2}" -F "code=${1}";
}

# Start an HTTP server from a directory, optionally specifying the port
function server() {
	local port="${1:-8000}";
	sleep 1 && open "http://localhost:${port}/" &
	# Set the default Content-Type to `text/plain` instead of `application/octet-stream`
	# And serve everything as UTF-8 (although not technically correct, this doesn’t break anything for binary files)
	python -c $'import SimpleHTTPServer;\nmap = SimpleHTTPServer.SimpleHTTPRequestHandler.extensions_map;\nmap[""] = "text/plain";\nfor key, value in map.items():\n\tmap[key] = value + ";charset=UTF-8";\nSimpleHTTPServer.test();' "$port";
}

# Start a PHP server from a directory, optionally specifying the port
# (Requires PHP 5.4.0+.)
function phpserver() {
	local port="${1:-4000}";
	local ip=$(ipconfig getifaddr en0);
	sleep 1 && open "http://${ip}:${port}/" &
	php -S "${ip}:${port}";
}

# Compare original and gzipped file size
function gz() {
	local origsize=$(wc -c < "$1");
	local gzipsize=$(gzip -c "$1" | wc -c);
	local ratio=$(LC_ALL="en_US" echo "$gzipsize * 100 / $origsize" | bc -l);
	printf "orig: %d bytes\n" "$origsize";
	LC_ALL="en_US" printf "gzip: %d bytes (%2.2f%%)\n" "$gzipsize" "$ratio";
}

# Syntax-highlight JSON strings or files
# Usage: `json '{"foo":42}'` or `echo '{"foo":42}' | json`
function json() {
	if [ -t 0 ]; then # argument
		python -mjson.tool <<< "$*" | pygmentize -l javascript;
	else # pipe
		python -mjson.tool | pygmentize -l javascript;
	fi;
}

# Run `dig` and display the most useful info
function digga() {
	dig +nocmd "$1" any +multiline +noall +answer;
}

# UTF-8-encode a string of Unicode symbols
function escape() {
	printf "\\\x%s" $(printf "$@" | xxd -p -c1 -u);
	# print a newline unless we’re piping the output to another program
	if [ -t 1 ]; then
		echo ""; # newline
	fi;
}

# Decode \x{ABCD}-style Unicode escape sequences
function unidecode() {
	perl -e "binmode(STDOUT, ':utf8'); print \"$@\"";
	# print a newline unless we’re piping the output to another program
	if [ -t 1 ]; then
		echo ""; # newline
	fi;
}

# Get a character’s Unicode code point
function codepoint() {
	perl -e "use utf8; print sprintf('U+%04X', ord(\"$@\"))";
	# print a newline unless we’re piping the output to another program
	if [ -t 1 ]; then
		echo ""; # newline
	fi;
}

# Show all the names (CNs and SANs) listed in the SSL certificate
# for a given domain
function getcertnames() {
	if [ -z "${1}" ]; then
		echo "ERROR: No domain specified.";
		return 1;
	fi;

	local domain="${1}";
	echo "Testing ${domain}…";
	echo ""; # newline

	local tmp=$(echo -e "GET / HTTP/1.0\nEOT" \
		| openssl s_client -connect "${domain}:443" -servername "${domain}" 2>&1);

	if [[ "${tmp}" = *"-----BEGIN CERTIFICATE-----"* ]]; then
		local certText=$(echo "${tmp}" \
			| openssl x509 -text -certopt "no_aux, no_header, no_issuer, no_pubkey, \
			no_serial, no_sigdump, no_signame, no_validity, no_version");
		echo "Common Name:";
		echo ""; # newline
		echo "${certText}" | grep "Subject:" | sed -e "s/^.*CN=//" | sed -e "s/\/emailAddress=.*//";
		echo ""; # newline
		echo "Subject Alternative Name(s):";
		echo ""; # newline
		echo "${certText}" | grep -A 1 "Subject Alternative Name:" \
			| sed -e "2s/DNS://g" -e "s/ //g" | tr "," "\n" | tail -n +2;
		return 0;
	else
		echo "ERROR: Certificate not found.";
		return 1;
	fi;
}

# `v` with no arguments opens the current directory in Vim, otherwise opens the
# given location
function v() {
	if [ $# -eq 0 ]; then
		vim .;
	else
		vim "$@";
	fi;
}

# `tre` is a shorthand for `tree` with hidden files and color enabled, ignoring
# the `.git` directory, listing directories first. The output gets piped into
# `less` with options to preserve color and line numbers, unless the output is
# small enough for one screen.
function tre() {
	tree -aC -I '.git|node_modules|bower_components' --dirsfirst "$@" | less -FRNX;
}

# Copy w/ progress
cp_p () {
  rsync -WavP --human-readable --progress "$1" "$2"
}

#if [ $(uname) == "Darwin" ]
if [ $(uname) = "Darwin" ]
then

  # Change working directory to the top-most Finder window location
  function cdf() { # short for `cdfinder`
  	cd "$(osascript -e 'tell app "Finder" to POSIX path of (insertion location as alias)')";
  }

  # `o` with no arguments opens the current directory, otherwise opens the given
  # location
  function o() {
  	if [ $# -eq 0 ]; then
  		open .;
  	else
  		open "$@";
  	fi;
  }
 fi 

# Vagrant goodies

function vlog {
	VAGRANT_LOG=info vagrant "$@" 2> vagrant.log
}

# vagrant sftp
function vsftp {
	[ "$1" = '' ] || [ "$2" != '' ] && echo "Usage: vsftp  - vagrant sftp" 1>&2 && return 1
	wd=`pwd`		# save wd, then find the Vagrant project
	while [ "`pwd`" != '/' ] && [ ! -e "`pwd`/Vagrantfile" ] && [ ! -d "`pwd`/.vagrant/" ]; do
		#echo "pwd is `pwd`"
		cd ..
	done
	pwd=`pwd`
	cd $wd
	if [ ! -e "$pwd/Vagrantfile" ] || [ ! -d "$pwd/.vagrant/" ]; then
		echo 'Vagrant project not found!' 1>&2 && return 2
	fi

	d="$pwd/.ssh"
	f="$d/$1.config"

	# if mtime of $f is > than 5 minutes (5 * 60 seconds), re-generate...
	if [ `date -d "now - $(stat -c '%Y' "$f" 2> /dev/null) seconds" +%s` -gt 300 ]; then
		mkdir -p "$d"
		# we cache the lookup because this command is slow...
		vagrant ssh-config "$1" > "$f" || rm "$f"
	fi
	[ -e "$f" ] && sftp -F "$f" "$1"
}

# vagrant screen
function vscreen {
	[ "$1" = '' ] || [ "$2" != '' ] && echo "Usage: vscreen <vm-name> - vagrant screen" 1>&2 && return 1
	wd=`pwd`		# save wd, then find the Vagrant project
	while [ "`pwd`" != '/' ] && [ ! -e "`pwd`/Vagrantfile" ] && [ ! -d "`pwd`/.vagrant/" ]; do
		#echo "pwd is `pwd`"
		cd ..
	done
	pwd=`pwd`
	cd $wd
	if [ ! -e "$pwd/Vagrantfile" ] || [ ! -d "$pwd/.vagrant/" ]; then
		echo 'Vagrant project not found!' 1>&2 && return 2
	fi

	d="$pwd/.ssh"
	f="$d/$1.config"
	h="$1"
	# hostname extraction from user@host pattern
	p=`expr index "$1" '@'`
	if [ $p -gt 0 ]; then
		let "l = ${#h} - $p"
		h=${h:$p:$l}
	fi

	# if mtime of $f is > than 5 minutes (5 * 60 seconds), re-generate...
	if [ `date -d "now - $(stat -c '%Y' "$f" 2> /dev/null) seconds" +%s` -gt 300 ]; then
		mkdir -p "$d"
		# we cache the lookup because this command is slow...
		vagrant ssh-config "$h" > "$f" || rm "$f"
	fi
	[ -e "$f" ] && ssh -t -F "$f" "$1" 'screen -xRR'
}


# vagrant cssh

function vcssh {
	[ "$1" = '' ] && echo "Usage: vcssh [options] [user@]<vm1>[ [user@]vm2[ [user@]vmN...]] - vagrant cssh" 1>&2 && return 1
	wd=`pwd`		# save wd, then find the Vagrant project
	while [ "`pwd`" != '/' ] && [ ! -e "`pwd`/Vagrantfile" ] && [ ! -d "`pwd`/.vagrant/" ]; do
		#echo "pwd is `pwd`"
		cd ..
	done
	pwd=`pwd`
	cd $wd
	if [ ! -e "$pwd/Vagrantfile" ] || [ ! -d "$pwd/.vagrant/" ]; then
		echo 'Vagrant project not found!' 1>&2 && return 2
	fi

	d="$pwd/.ssh"
	cssh="$d/cssh"
	cmd=''
	cat='cat '
	screen=''
	options=''

	multi='f'
	special=''
	for i in "$@"; do	# loop through the list of hosts and arguments!
		#echo $i

		if [ "$special" = 'debug' ]; then	# optional arg value...
			special=''
			if [ "$1" -ge 0 -o "$1" -le 4 ]; then
				cmd="$cmd $i"
				continue
			fi
		fi

		if [ "$multi" = 'y' ]; then	# get the value of the argument
			multi='n'
			cmd="$cmd '$i'"
			continue
		fi

		if [ "${i:0:1}" = '-' ]; then	# does argument start with: - ?

			# build a --screen option
			if [ "$i" = '--screen' ]; then
				screen=' -o RequestTTY=yes'
				cmd="$cmd --action 'screen -xRR'"
				continue
			fi

			if [ "$i" = '--debug' ]; then
				special='debug'
				cmd="$cmd $i"
				continue
			fi

			if [ "$i" = '--options' ]; then
				options=" $i"
				continue
			fi

			# NOTE: commented-out options are probably not useful...
			# match for key => value argument pairs
			if [ "$i" = '--action' -o "$i" = '-a' ] || \
			[ "$i" = '--autoclose' -o "$i" = '-A' ] || \
			#[ "$i" = '--cluster-file' -o "$i" = '-c' ] || \
			#[ "$i" = '--config-file' -o "$i" = '-C' ] || \
			#[ "$i" = '--evaluate' -o "$i" = '-e' ] || \
			[ "$i" = '--font' -o "$i" = '-f' ] || \
			#[ "$i" = '--master' -o "$i" = '-M' ] || \
			#[ "$i" = '--port' -o "$i" = '-p' ] || \
			#[ "$i" = '--tag-file' -o "$i" = '-c' ] || \
			[ "$i" = '--term-args' -o "$i" = '-t' ] || \
			[ "$i" = '--title' -o "$i" = '-T' ] || \
			[ "$i" = '--username' -o "$i" = '-l' ] ; then
				multi='y'	# loop around to get second part
				cmd="$cmd $i"
				continue
			else			# match single argument flags...
				cmd="$cmd $i"
				continue
			fi
		fi

		f="$d/$i.config"
		h="$i"
		# hostname extraction from user@host pattern
		p=`expr index "$i" '@'`
		if [ $p -gt 0 ]; then
			let "l = ${#h} - $p"
			h=${h:$p:$l}
		fi

		# if mtime of $f is > than 5 minutes (5 * 60 seconds), re-generate...
		if [ `date -d "now - $(stat -c '%Y' "$f" 2> /dev/null) seconds" +%s` -gt 300 ]; then
			mkdir -p "$d"
			# we cache the lookup because this command is slow...
			vagrant ssh-config "$h" > "$f" || rm "$f"
		fi

		if [ -e "$f" ]; then
			cmd="$cmd $i"
			cat="$cat $f"	# append config file to list
		fi
	done

	cat="$cat > $cssh"
	#echo $cat
	eval "$cat"			# generate combined config file

	#echo $cmd && return 1
	#[ -e "$cssh" ] && cssh --options "-F ${cssh}$options" $cmd
	# running: bash -c glues together --action 'foo --bar' type commands...
	[ -e "$cssh" ] && bash -c "cssh --options '-F ${cssh}${screen}$options' $cmd"
}


