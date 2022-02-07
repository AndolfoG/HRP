#!/bin/bash

# C.G. 28.1.2022

# print an error message
err() {
	printf "%s\n" "ERROR: $@" >&1
}


# print usage information
usage() {
	name=$(basename "$0")
	filler=$(printf "%s" "$name" | sed 's/./ /g')
	cat>&2<<-EODAT

		usage: $name: [ -f ] [ -c conf1.tsv ] [ -d conf2.tsv ]
		       $filler  [ -o output.tsv ] [ -t temp1 ] [ -u temp2 ] infile

		       infile: read from infile

		       -f force existing files to be overwritten
		       -c filename1: use filename1 for config1 (default: conf1.tsv)
		       -d filename2: use filename2 for config2 (default: conf2.tsv)
		       -o filename3: use filename3 for output (default: stdout)
		       -t temp1: use temp1 for output of first step
		       -u temp2: use temp2 for output of second step

	EODAT
}


###   start   ###

(( force_overwrite=0 ))
while getopts "c:d:o:t:u:f" opt; do
        case "$opt" in
                c)      config1="$OPTARG";;
                d)      config2="$OPTARG";;
                o)      outfile="$OPTARG";;
		t)	output1="$OPTARG";;
		u)	output2="$OPTARG";;
		f)	(( force_overwrite = 1 ));;
                *)      usage; err "Wrong option letter"; exit 1
        esac
done
shift $((OPTIND-1))

(( $# == 1 )) || {
	usage
	err "Exactly one output file expected"
	exit 1
}

rc=0

config1=${config1:-conf1.tsv}
config2=${config2:-conf2.tsv}
infile="$1"

[[ -f "$config1" && -r "$config1" ]] || {
	err "Config file not found or not readable: $config1"
	rc=2
}
[[ -f "$config2" && -r "$config2" ]] || {
	err "Config file not found or not readable: $config2"
	rc=3
}
[[ -f "$infile" && -r "$infile" ]] || {
	err "Input file not found or not readable: $infile"
	rc=4
}

if (( force_overwrite == 0 ))
then
	[[ -f $output1 ]] && {
		err "Won't overwrite existing file $output1 unless -f is set"
		rc=6
	}
	[[ -f $output2 ]] && {
		err "Won't overwrite existing file $output2 unless -f is set"
		rc=7
	}
	[[ -f $outfile ]] && {
		err "Won't overwrite existing file $outfile unless -f is set"
		rc=8
	}
fi

(( rc != 0 )) && exit $rc

if [[ $outfile != "" ]]
then
	exec > "$outfile" || {
		err "Cannot write to output file $outfile"
		exit 5
	}
fi


traps=""
[[ -z $output1 ]] && {
	output1=$(mktemp output_1.tsv.XXXXXXXXXX) || {
		err "Cannot create temporary file, RC=$?"
		exit 9
	}
	traps="rm -f $output1; $traps"
}
[[ -z $output2 ]] && {
	output2=$(mktemp output_2.tsv.XXXXXXXXXX) || {
		err "Cannot create temporary file, RC=$?"
		exit 9
	}
	traps="rm -f $output2; $traps"
}

[[ -z $traps ]] || trap "$traps" EXIT

cat>&2<<-EODAT

	input:      $infile
	config1:    $config1
	config2:    $config2
	output1:    $output1
	output2:    $output2
	output:	    ${outfile:-stdout}

EODAT


# Step0 
LANG=en_EN

# Step1 
join -t $'\t' -1 5 -2 1 -o 1.1,2.2 <(sort -bk5 "$infile") <(sort -bk1 "$config1") | sort -u -bk1 -bk2 > "$output1" || {
	err "Step 1 failed with RC=$?"
	exit 11
}

# Step2 
awk -F '\t' '{a[$1] += $2} END {for(i in a) printf "%s\t%s\n", i, a[i]}' "$output1" > "$output2" || {
	err "Step 2 failed with RC=$?"
	exit 12
}

# Step3 
join -t $'\t' -1 2 -2 1 -o 1.1,2.2,2.3,2.4  <(sort -bk2 "$output2") <(sort  -bk1 "$config2") || {
	err "Step 3 failed with RC=$?"
	exit 13
}

