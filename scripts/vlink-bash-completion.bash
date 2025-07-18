_vlink()
{
	COMP_WORDBREAKS="\"'><=;|&(	  "

	local cur=${COMP_WORDS[COMP_CWORD]}
	local prev=${COMP_WORDS[COMP_CWORD-1]}
	local pprev=${COMP_WORDS[COMP_CWORD-2]}

	allflags=" -l -s -r -bw -b -BER -B -dly -d -dup -D -e -eid -help -? "
	argflags=" -bw -b -BER -B -dly -d -dup -D -e -eid "

	if test $COMP_CWORD -ne 1; then
		for i in `seq 2 $COMP_CWORD`; do
			word=${COMP_WORDS[i-1]}
			if [[ "$word" != "" ]] ; then
				case "$word" in
					-b)
						word2="-bw"
						;;
					-bw)
						word2="-b"
						;;
					-B)
						word2="-BER"
						;;
					-BER)
						word2="-B"
						;;
					-d)
						word2="-dly"
						;;
					-dly)
						word2="-d"
						;;
					-D)
						word2="-dup"
						;;
					-dup)
						word2="-D"
						;;
					-e)
						word2="-eid"
						;;
					-eid)
						word2="-e"
						;;
				esac
				allflags=`echo "$allflags" | sed "s/ $word / /" | sed "s/ $word2 / /"`
				argflags=`echo "$argflags" | sed "s/ $word / /" | sed "s/ $word2 / /"`
			fi
		done
	fi

	eids=`vlink -l | awk '{print $1}'`
	links=`vlink -l | tr -d '()' | \
		awk '    { for(i=2;i<=NF;++i) {eid[$i]=eid[$i]" "$1; ++nexp[$i]}} \
		END {for (k in eid) {\
		if (nexp[k] > 1) {\
			split(eid[k],eids," "); \
			for (e in eids) printf "%s@%s ",k,eids[e] \
			} else { printf "%s ", k }\
		}}'`

	if test $COMP_CWORD -eq 1; then
		COMPREPLY=( $(compgen -W "$allflags" -- $cur))
	elif test $COMP_CWORD -eq 2; then
		case "$prev" in
			-[h]|-help|-[?])
				return 0
				;;
			-[rs])
				COMPREPLY=( $(compgen -W "$links" -- $cur))
				;;
			-e|-eid)
				COMPREPLY=( $(compgen -W "$eids" -- $cur))
				;;
			-l)
				COMPREPLY=( $(compgen -W "-e -eid" -- $cur))
				;;
		esac
	elif test $COMP_CWORD -eq 3; then
		case "$pprev" in
			-[rs])
				;;
			-*)
				COMPREPLY=( $(compgen -W "-l -s -r $argflags" -- $cur))
				;;
		esac
		case "$prev" in
			-e|-eid)
				COMPREPLY=( $(compgen -W "$eids" -- $cur))
				;;
			*)
				COMPREPLY+=( $(compgen -W "$links" -- $cur))
				;;
		esac
	elif test $COMP_CWORD -eq 4 || test $COMP_CWORD -eq 6 || test $COMP_CWORD -eq 8 || test $COMP_CWORD -eq 10; then
		case "$prev" in
			-l)
				return 0
				;;
			-[rs])
				COMPREPLY=( $(compgen -W "$links" -- $cur))
				;;
			-e|-eid)
				COMPREPLY=( $(compgen -W "$eids" -- $cur))
				;;
		esac
	elif test $COMP_CWORD -eq 5 || test $COMP_CWORD -eq 7 || test $COMP_CWORD -eq 9 || test $COMP_CWORD -eq 11; then
		COMPREPLY=( $(compgen -W "$argflags" -- $cur))
		COMPREPLY+=( $(compgen -W "$links" -- $cur))
	fi

	return 0
}

complete -o filenames -F _vlink vlink
