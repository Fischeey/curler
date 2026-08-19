#SCRIPT FOR FINDING HTML PAGES
#MY CODE NO STEALING - FISCHEEY
MODESET=0
DICTIONARY=0
URLSET=0 
COUNTER=0
RAW=0
PARALLEL=0
CODE=0
SUFFIX=0
ANALYSISSET=0
TITLE=0
BODY=0

touch out.txt
: > out.txt
touch TEMP_URLS.txt
: > TEMP_URLS.txt
touch CURLOUT_TEMP.txt
: > CURLOUT_TEMP.txt
touch SUFFIX_TEMP.txt
: > SUFFIX_TEMP.txt
touch S_TEMP.txt
: > S_TEMP.txt

cleanup() {
    echo "🧹 Executing cleanup operations..."
    
    # Remove temporary directories safely
    if [[ -n "$BACKGROUND_PID" ]]; then
        kill "$BACKGROUND_PID" 2>/dev/null
    fi
    kill $(jobs -p) 2>/dev/null
    # Optional: Terminate residual background processes spawned by this script
    kill $(jobs -p) 2>/dev/null
    rm -f TEMP_URLS.txt CURLOUT_TEMP.txt SUFFIX_TEMP.txt S_TEMP.txt 
}
trap cleanup EXIT INT TERM





if [ "$#" -eq 1 ]; then 
        echo "You must enter a url, dictionary location, and depth level in the format ./script.sh https://www.example.com /path/to/dictionary  1"
        exit 1
fi
for arg in "$@"; do
    if [[ "$arg" == "help" ]]; then
        echo "help menu"

    #
    # INPUT MODES
    #    
    elif [[ "$arg" == "-D" ]] && [[ "$MODESET" == 0 ]]; then
        DICTIONARY=$COUNTER
        MODESET=1


    
    elif [[ "$arg" == *"https://"* ]] || [[ $arg == *"http://"* ]]; then
        URLSET=1
        URL=$arg
    elif [[ "$arg" == "-P" ]]; then 
        PARALLEL=$COUNTER
    

    #F$
    #ANALYSIS MODE
    #
    elif [[ ("$arg" == "-B") && "$ANALYSISSET" == 1 ]]; then 
        echo "ERROR - can only enter one analysis mode"
        exit 1
    elif [[ "$arg" == "-B" ]] && [[ "$ANALYSISSET" == 0 ]]; then 
        ANALYSISSET=1
        BODY=1
    elif [[ "$arg" == "-C" ]] && [[ "$ANALYSISSET" == 0 ]]; then 
        ANALYSISSET=1
        CODE=1
    elif [[ "$arg" == "-S" ]]; then 
        SUFFIX=$COUNTER
        TITLE=1
    fi
    ((COUNTER++))
    
done 

PARALLEL_VAL=1
DICTIONARY_VAL=1
SUFFIX_VAL=1

if [[ "$PARALLEL" -gt 0 ]]; then
    TEMP=$((2 + "$PARALLEL"))
    PARALLEL_VAL=${!TEMP}
fi 
if [[ "$DICTIONARY" -gt 0 ]]; then
    TEMP=$((2 + "$DICTIONARY"))
    DICTIONARY_VAL=${!TEMP}
fi

if [[ "$SUFFIX" -gt 0 ]]; then
    TEMP=$((2 + "$SUFFIX"))
    SUFFIX_VAL=${!TEMP}
fi


















RED='\e[31m'
GREEN='\e[32m'
RESET='\e[0m'


TICK="\u2714" # ✔
CROSS="\u2718" # ✘



printf "\n\n--- PROGRAM SETUP ---\n"
if [[ "$URLSET" -ne 0 ]]; then
    echo -e " - URLSET - ${GREEN}${TICK}${RESET}  - $URL"
else
    echo -e " - URLSET - ${RED}${CROSS}${RESET}"
    echo " - ERROR - URL - PROGRAM EXIT"
    exit 1
fi



if [[ "$DICTIONARY" -ne 0 ]]; then
    if [ ! -f "$DICTIONARY_VAL" ]; then
        echo "Error: Dictionary file not found at $DICTIONARY_VAL."
        exit 1
    fi
    echo -e " - DICTIONARY MODE - ${GREEN}${TICK}${RESET} - $DICTIONARY_VAL"
else
if [[ "$PARALLEL" -ne 0 ]]; then
    echo -e " - PARALLEL MODE - ${GREEN}${TICK}${RESET}   - SETTING TO $PARALLEL_VAL"
else 
    echo -e " - PARALLEL MODE - ${RED}${TICK}${RESET} - SETTING TO 1"
fi
elif [[ "$BODY" -ne 0 ]]; then
    echo -e " - BODY MODE - ${GREEN}${TICK}${RESET}"
    echo -e " - CODE MODE - ${RED}${CROSS}${RESET}"
elif [[ "$CODE" -ne 0 ]]; then
    echo -e " - BODY MODE - ${RED}${CROSS}${RESET}"
    echo -e " - CODE MODE - ${GREEN}${TICK}${RESET}"
else
    echo " - ERROR - MUST SELECT AN ANALYSIS MODE - PROGRAM EXIT"
    exit 1
fi

if [[ "$SUFFIX" -ne 0 ]]; then
    echo -e " - SUFFIX MODE - ${GREEN}${TICK}${RESET} - $SUFFIX_VAL"
    if [[ -f "$SUFFIX_VAL" ]]; then
        cp -n "$SUFFIX_VAL" SUFFIX_TEMP.txt
    else
        echo "$SUFFIX_VAL" >> SUFFIX_TEMP.txt
    fi
else 
    echo -e " - SUFFIX MODE - ${RED}${CROSS}${RESET}"
fi
echo "--- PROGRAM RUN ---"
















echo $WORD



if [[ "$BODY" -eq 1 ]]; then
    TESTURL1=$(curl -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" --max-filesize 5000 -s "$URL/$(tr -dc 'a-z0-9' < /dev/urandom | head -c 24)"  | sed -e '/<style[^>]*>/,/<\/style>/d' -e 's/<[^>]*>//g' -e 's/{[^}]*}//g' -e 's/[[:space:]]//g' | tr -d '\n\r')
    TESTURL2=$(curl -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" --max-filesize 5000 -s "$URL/$(tr -dc 'a-z0-9' < /dev/urandom | head -c 24)"  | sed -e '/<style[^>]*>/,/<\/style>/d' -e 's/<[^>]*>//g' -e 's/{[^}]*}//g' -e 's/[[:space:]]//g' | tr -d '\n\r')
    TESTURL3=$(curl -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" --max-filesize 5000 -s "$URL/$(tr -dc 'a-z0-9' < /dev/urandom | head -c 24)"  | sed -e '/<style[^>]*>/,/<\/style>/d' -e 's/<[^>]*>//g' -e 's/{[^}]*}//g' -e 's/[[:space:]]//g' | tr -d '\n\r')

#TODO check if curl output is empty (can still be valid)
else [[ "$CODE" -ne 1 ]]; then
    echo "ERROR 112"
    exit 1
fi
if [[ "$BODY" -eq 1 ]] ; then
    if [ "${#TESTURL1}" -le "${#TESTURL2}" ] && [ "${#TESTURL1}" -le "${#TESTURL3}" ]; then
        smallest=$TESTURL1
    elif [ "${#TESTURL2}" -le "${#TESTURL1}" ] && [ "${#TESTURL2}" -le "${#TESTURL3}" ]; then
        smallest=$TESTURL2
    else
        smallest=$TESTURL3
    fi

    TESTURL1AVE=0
    TESTURL2AVE=0
    TESTURL3AVE=0

    for (( i=0; i<${#smallest}; i++ )); do
        URL1char="${TESTURL1:$i:1}"
        URL2char="${TESTURL2:$i:1}"
        URL3char="${TESTURL3:$i:1}"

        if [[ "$URL1char" = "$URL2char" ]] && [[ "$URL2char" = "$URL3char" ]]; then
        
            ((TESTURL1AVE++))
            ((TESTURL2AVE++))
            ((TESTURL3AVE++))
        elif [[ "$URL1char" = "$URL2char" ]] ; then
            ((TESTURL1AVE++))
            ((TESTURL2AVE++))
        elif [[ "$URL1char" = "$URL2char" ]] ; then
            ((TESTURL2AVE++))
            ((TESTURL3AVE++))
        fi
    done
    if [[ "${#smallest}" -ne 0 ]]; then
        ((TESTURL1AVE /= "${#smallest}"))
        ((TESTURL2AVE /= "${#smallest}"))
        ((TESTURL3AVE /= "${#smallest}"))
    else
        TESTURL1AVE=0
        TESTURL2AVE=0
        TESTURL3AVE=0
    fi 
    if awk "BEGIN {exit !($TESTURL1AVE > $TESTURL2AVE && $TESTURL1AVE > $TESTURL3AVE)}"; then
        greatest=$TESTURL1
    elif awk "BEGIN {exit !($TESTURL2AVE > $TESTURL1AVE && $TESTURL2AVE > $TESTURL3AVE)}"; then
        greatest=$TESTURL2
    else
        greatest=$TESTURL3
    fi
fi


















TIMER(){
    SECONDS=0
    urlcount=$(wc -l < "TEMP_URLS.txt")
    CURLcount=$(wc -l < "CURLOUT_TEMP.txt")
    while [ -f TEMP_URLS.txt ]; do
        urlcount=$(wc -l < "TEMP_URLS.txt")
        outcount=$(wc -l < "CURLOUT_TEMP.txt")
        echo "LINES PROCESSED = $outcount/$urlcount --- TIME ELAPSED = $SECONDS"
        sleep 2
    done
}

TIMER &
































#dictionary setup

echo "$URL"  >> TEMP_URLS.txt
CURLER_DICT_FILL()
{
    echo "$2/$1"  >> TEMP_URLS.txt
}
CURLER_DICTNEST_FILL()
{
    while IFS= read -r LINE; do
        echo "${LINE}/$1" >> TEMP_URLS.txt
    done < NESTED_TEMP.txt
}
CURLER_NESTED_FILL()
{
    echo "$2/$1"  >> NESTED_TEMP.txt
}
CURLER_SUFFIX_FILL()
{
    
    while IFS= read -r SUFFIX; do
        echo "$1$SUFFIX"  >> TEMP_URLS.txt
    done < SUFFIX_TEMP.txt
}

export -f CURLER_DICT_FILL
export -f CURLER_DICTNEST_FILL
export -f CURLER_NESTED_FILL
export -f CURLER_SUFFIX_FILL


if [[ "$DICTIONARY" -gt 0 ]]; then
    if [[ "$NESTED" -gt 0 ]]; then
        cat NESTED_TEMP.txt | sed 's/[^a-z:./]//g' | xargs -P $PARALLEL_VAL -I {} bash -c 'CURLER_DICTNEST_FILL "$1" ' _  {} 
    else
        cat $DICTIONARY_VAL | sed 's/[^a-z:./]//g' | xargs -P $PARALLEL_VAL -I {} bash -c 'CURLER_DICT_FILL "$1" "$2"' _  {} "$URL"
    fi

if [[ "$SUFFIX" -gt 0 ]]; then
    mv TEMP_URLS.txt S_TEMP.txt
    : > TEMP_URLS.txt
    cat S_TEMP.txt | sed 's/[^a-z:./]//g' | xargs -P $PARALLEL_VAL -I {} bash -c 'CURLER_SUFFIX_FILL "$1" ' _  {}
fi











curler_CURLS_B()
{
    printf "%s\x1f%s\n" "$1" "$(curl -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" --max-filesize 5000 -s  "${1}"  | sed -e '/<style[^>]*>/,/<\/style>/d' -e 's/<[^>]*>//g' -e 's/{[^}]*}//g'  -e 's/[[:space:]]//g' | tr -d '\n\r')">> CURLOUT_TEMP.txt
}

curler_CURLS_C()
{
    printf "%s\x1f%s\n" "$1" "$(curl -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" --max-filesize 5000 -sI -o /dev/null -w "%{http_code}" "${1}" )" >> CURLOUT_TEMP.txt
}

export -f curler_CURLS_B
export -f curler_CURLS_C


if [[ "$BODY" -eq 1 ]]; then
    cat TEMP_URLS.txt | xargs -P $PARALLEL_VAL -I {} bash -c 'curler_CURLS_B "$1" ' _   "{}"
elif [[ "$CODE" -eq 1 ]]; then
    cat TEMP_URLS.txt | xargs -P $PARALLEL_VAL -I {} bash -c 'curler_CURLS_C "$1" ' _   "{}"
else
    echo "ERROR 111"
    exit 1
fi

    





curler_ANALYSIS_B()
{
    TITLESTR="${1%%$'\x1f'*}"
    DATALINE="${1#*$'\x1f'}"
    DATAAVE=0
    for (( i=0; i<${#3}; i++ )); do
        KEYCHAR="${2:$i:1}"
        TESTCHAR="${DATALINE:$i:1}"
        if [[ "$TESTCHAR" != "$KEYCHAR" ]]; then
            ((DATAAVE++))
        fi

    done
    LENGTH="${#3}"
    if [ "$LENGTH" -gt 0 ]; then
        DATAAVE=$(awk -v sum="$DATAAVE" -v len="$LENGTH" \
            'BEGIN { printf "%.2f\n", sum / len }')
    else
        echo "LENGTH is zero"
    fi
    if awk "BEGIN {exit !($DATAAVE > 0.5)}"; then
        echo "$TITLESTR : UNIQUE VALUE : $DATAAVE" >> out.txt
    fi
}
curler_ANALYSIS_C()
{
    
    TITLESTR="${1%%$'\x1f'*}"
    CODELINE="${1#*$'\x1f'}"
    if [ "$CODELINE" -ne 404 ]; then
        echo "$TITLESTR : UNIQUE VALUE : $CODELINE" >> out.txt
    fi
       
}



export -f curler_ANALYSIS_B
export -f curler_ANALYSIS_C

 
if [[ "$TITLE" -eq 1 ]] || [[ "$BODY" -eq 1 ]]  ; then
    cat CURLOUT_TEMP.txt | xargs -P $PARALLEL_VAL -I {} bash -c 'curler_ANALYSIS_B "$1" "$2" "$3"' _  {} "$greatest" "$smallest"
elif [[ "$CODE" -eq 1 ]]; then
    cat CURLOUT_TEMP.txt | xargs -P $PARALLEL_VAL -I {} bash -c 'curler_ANALYSIS_C "$1"' _  {} 

else
    echo "ERROR 114" 
    exit 1
fi















exit 0