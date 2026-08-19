#SCRIPT FOR FINDING HTML PAGES
#MY CODE NO STEALING - FISCHEEY


URLSET=0 
CODE=0
ANALYSISSET=0
TITLE=0
BODY=0
PARALLEL_VAL=1
DICTIONARY_VAL=""
RAW_VAL=""
NESTED_VAL=""
SUFFIX_VAL=""


touch out.txt; : > out.txt
touch TEMP_URLS.txt; : > TEMP_URLS.txt
touch CURLOUT_TEMP.txt; : > CURLOUT_TEMP.txt
touch SUFFIX_TEMP.txt; : > SUFFIX_TEMP.txt
touch S_TEMP.txt; : > S_TEMP.txt

cleanup() {
    echo "🧹 Executing cleanup operations..."
    
    # Remove temporary directories safely
    if [ -n "$BACKGROUND_PID" ]; then
        kill "$BACKGROUND_PID" 2>/dev/null
    fi
    kill $(jobs -p) 2>/dev/null
    # Optional: Terminate residual background processes spawned by this script
    kill $(jobs -p) 2>/dev/null
    rm -f TEMP_URLS.txt CURLOUT_TEMP.txt SUFFIX_TEMP.txt S_TEMP.txt NESTED_TEMP.txt
}
trap cleanup EXIT INT TERM

#show usage details
usage() {
    echo "Usage: $0 [-P int ] [-S string] [-D filename] [-B] [-C]"
    echo "  -P thread count    [INTEGER]"
    echo "  -S suffix mode     [FILENAME OR STRING] "
    echo "  -D dictionary mode [FILENAME]            "
    echo "  -N nested mode     [FILENAME]"
    echo "  -R raw mode        [RAW VALUE]          "
    echo "  -B body mode            "
    echo "  -C code mode            " 
    echo "  -T title mode            "
    echo "  -W word mode            "       
    exit 1
}
while [[ $# -gt 0 ]]; do
    case "$1" in
        -S) SUFFIX_VAL="$2"; shift 2 ;;
        -P) PARALLEL_VAL="$2"; shift 2 ;;
        -N) NESTED_VAL="$2"; shift 2 ;;
        -D) DICTIONARY_VAL="$2"; shift 2 ;;
        -R) RAW_VAL="$2"; shift 2 ;;
        -C) CODE=1; shift ;;
        -B) BODY=1; shift ;;
        -T) TITLE=1; shift ;;
        -W) WORD=1; shift ;;
        http://*|https://*)
            if [[ "$URLSET" != 1 ]]; then
                URL="$1"
                URLSET=1
            fi
            shift ;;
        *) echo "Error: Invalid argument $1" >&2 ; shift ;;
    esac
done









#symbols
RED=$(printf '\033[31m')
GREEN=$(printf '\033[32m')
RESET=$(printf '\033[0m')

TICK="✔"
CROSS="✘"



printf "\n\n--- PROGRAM SETUP ---\n"
if [ "$URLSET" != 0 ]; then
    echo -e " - URLSET - ${GREEN}${TICK}${RESET}  - $URL"
else
    echo -e " - URLSET - ${RED}${CROSS}${RESET}"
    echo " - ERROR - URL - PROGRAM EXIT"
    exit 1
fi


if [ "$RAW_VAL" != "" ]; then
    echo -e " - RAW MODE - ${GREEN}${TICK}${RESET}"
    echo -e " - DICTIONARY MODE - ${RED}${CROSS}${RESET}"
elif [ "$DICTIONARY_VAL" != "" ]; then
    if [ ! -f "$DICTIONARY_VAL" ]; then
        echo "Error: Dictionary file not found at $DICTIONARY_VAL."
        echo "On Debian/Ubuntu, install it using: sudo apt install wamerican"
        exit 1
    fi
    echo -e " - RAW MODE - ${RED}${CROSS}${RESET}"
    echo -e " - DICTIONARY MODE - ${GREEN}${TICK}${RESET} - $DICTIONARY_VAL"
else
    echo " - ERROR - MUST SELECT EITHER RAW MODE OR DICTIONARY MODE - PROGRAM EXIT"
    exit 1
fi

if [ "$NESTED_VAL" != "" ]; then
    echo -e " - NESTED MODE - ${GREEN}${TICK}${RESET} - $NESTED_VAL"
else 
    echo -e " - NESTED MODE - ${RED}${CROSS}${RESET}"
fi

if [ "$PARALLEL_VAL" != 1 ]; then
    echo -e " - PARALLEL MODE - ${GREEN}${TICK}${RESET}   - SETTING TO $PARALLEL_VAL"
else 
    echo -e " - PARALLEL MODE - ${RED}${TICK}${RESET} - SETTING TO 1"
fi

if [ "$TITLE" != 0 ]; then
    echo -e " - TITLE MODE - ${GREEN}${TICK}${RESET}"
    echo -e " - BODY MODE - ${RED}${CROSS}${RESET}"
    echo -e " - WORD MODE - ${RED}${CROSS}${RESET}"
    echo -e " - CODE MODE - ${RED}${CROSS}${RESET}"
elif [ "$BODY" != 0 ]; then
    echo -e " - TITLE MODE - ${RED}${CROSS}${RESET}"
    echo -e " - BODY MODE - ${GREEN}${TICK}${RESET}"
    echo -e " - WORD MODE - ${RED}${CROSS}${RESET}"
    echo -e " - CODE MODE - ${RED}${CROSS}${RESET}"
elif [ "$WORD" != 0 ]; then
    echo -e " - TITLE MODE - ${RED}${CROSS}${RESET}"
    echo -e " - BODY MODE - ${RED}${CROSS}${RESET}"
    echo -e " - WORD MODE - ${GREEN}${TICK}${RESET}"
    echo -e " - CODE MODE - ${RED}${CROSS}${RESET}"
elif [ "$CODE" != 0 ]; then
    echo -e " - TITLE MODE - ${RED}${CROSS}${RESET}"
    echo -e " - BODY MODE - ${RED}${CROSS}${RESET}"
    echo -e " - WORD MODE - ${RED}${CROSS}${RESET}"
    echo -e " - CODE MODE - ${GREEN}${TICK}${RESET}"
else
    echo " - ERROR - MUST SELECT AN ANALYSIS MODE - PROGRAM EXIT"
    exit 1
fi

if [ "$SUFFIX_VAL" != "" ]; then
    echo -e " - SUFFIX MODE - ${GREEN}${TICK}${RESET} - $SUFFIX_VAL"
    if [ -f "$SUFFIX_VAL" ]; then
        cp -n "$SUFFIX_VAL" SUFFIX_TEMP.txt
    else
        echo "$SUFFIX_VAL" >> SUFFIX_TEMP.txt
    fi
else 
    echo -e " - SUFFIX MODE - ${RED}${CROSS}${RESET}"
fi
echo "--- PROGRAM RUN ---"











if [ "$TITLE" == 1 ]; then
    TESTURL1=$(curl -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" --max-filesize 5000 -s "$URL/$(tr -dc 'a-z0-9' < /dev/urandom | head -c 24)"  | grep -iPo '(?<=<title>).*?(?=</title>)')
    TESTURL2=$(curl -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" --max-filesize 5000 -s "$URL/$(tr -dc 'a-z0-9' < /dev/urandom | head -c 24)"  | grep -iPo '(?<=<title>).*?(?=</title>)')
    TESTURL3=$(curl -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" --max-filesize 5000 -s "$URL/$(tr -dc 'a-z0-9' < /dev/urandom | head -c 24)"  | grep -iPo '(?<=<title>).*?(?=</title>)')
elif [ "$BODY" == 1 ]; then
    TESTURL1=$(curl -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" --max-filesize 5000 -s "$URL/$(tr -dc 'a-z0-9' < /dev/urandom | head -c 24)"  | sed -e '/<style[^>]*>/,/<\/style>/d' -e 's/<[^>]*>//g' -e 's/{[^}]*}//g' -e 's/[[:space:]]//g' | tr -d '\n\r')
    TESTURL2=$(curl -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" --max-filesize 5000 -s "$URL/$(tr -dc 'a-z0-9' < /dev/urandom | head -c 24)"  | sed -e '/<style[^>]*>/,/<\/style>/d' -e 's/<[^>]*>//g' -e 's/{[^}]*}//g' -e 's/[[:space:]]//g' | tr -d '\n\r')
    TESTURL3=$(curl -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" --max-filesize 5000 -s "$URL/$(tr -dc 'a-z0-9' < /dev/urandom | head -c 24)"  | sed -e '/<style[^>]*>/,/<\/style>/d' -e 's/<[^>]*>//g' -e 's/{[^}]*}//g' -e 's/[[:space:]]//g' | tr -d '\n\r')
elif [ "$WORD" == 1 ]; then
    TESTURL1=$(curl -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" --max-filesize 5000 -s "$URL/$(tr -dc 'a-z0-9' < /dev/urandom | head -c 24)"  | sed -e '/<style[^>]*>/,/<\/style>/d' -e 's/<[^>]*>//g' -e 's/{[^}]*}//g' | tr -d '\n\r')
    TESTURL2=$(curl -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" --max-filesize 5000 -s "$URL/$(tr -dc 'a-z0-9' < /dev/urandom | head -c 24)"  | sed -e '/<style[^>]*>/,/<\/style>/d' -e 's/<[^>]*>//g' -e 's/{[^}]*}//g' | tr -d '\n\r')
    TESTURL3=$(curl -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" --max-filesize 5000 -s "$URL/$(tr -dc 'a-z0-9' < /dev/urandom | head -c 24)"  | sed -e '/<style[^>]*>/,/<\/style>/d' -e 's/<[^>]*>//g' -e 's/{[^}]*}//g' | tr -d '\n\r') 

#TODO check if curl output is empty (can still be valid)
elif [ "$CODE" != 1 ]; then
    echo "ERROR 112"
    exit 1
fi
if [ "$TITLE" == 1 ] || [ "$BODY" == 1 ] || [ "$WORD" == 1 ]; then
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
    i=0
while [ "$i" -lt ${#smallest} ]; do
        URL1char="${TESTURL1:$i:1}"
        URL2char="${TESTURL2:$i:1}"
        URL3char="${TESTURL3:$i:1}"
        if [ "$URL1char" = "$URL2char" ] && [ "$URL2char" = "$URL3char" ]; then
            TESTURL1AVE=$((TESTURL1AVE + 1))
            TESTURL2AVE=$((TESTURL2AVE + 1))
            TESTURL2AVE=$((TESTURL2AVE + 1))
        elif [ "$URL1char" = "$URL2char" ] ; then
            TESTURL1AVE=$((TESTURL1AVE + 1))
            TESTURL2AVE=$((TESTURL2AVE + 1))
        elif [ "$URL2char" = "$URL3char" ] ; then
            TESTURL2AVE=$((TESTURL2AVE + 1))
            TESTURL3AVE=$((TESTURL3AVE + 1))
        fi
        i=$((i + 1))
    done
    if [ "${#smallest}" != 0 ]; then
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

if [ "$NESTED_VAL" != "" ]; then
    cat $NESTED_VAL | sed 's/[^a-zA-Z0-9:./_-]//g' | xargs -P $PARALLEL_VAL -I {} bash -c 'CURLER_NESTED_FILL "$1" "$2"' _  {} "$URL"
fi
if [ "$DICTIONARY_VAL" != "" ]; then
    if [ "$NESTED_VAL" != "" ]; then
        cat NESTED_TEMP.txt | sed 's/[^a-zA-Z0-9:./_-]//g' | xargs -P $PARALLEL_VAL -I {} bash -c 'CURLER_DICTNEST_FILL "$1" ' _  {} 
    else
        cat $DICTIONARY_VAL | sed 's/[^a-zA-Z0-9:./_-]//g' | xargs -P $PARALLEL_VAL -I {} bash -c 'CURLER_DICT_FILL "$1" "$2"' _  {} "$URL"
    fi

elif [ "$RAW_VAL" != "" ]; then
 # Set your max length here
awk -v max="$RAW_VAL" -v URL="$URL/" '
BEGIN {
    charset = "abcdefghijklmnopqrstuvwxyz0123456789"
    len = length(charset)
    for (i = 1; i <= max; i++) gen(URL, i)
}
# Notice "   j" in the signature below — this creates a brand-new 'j' for every stack level!
function gen(p, n,   j) {
    if (n == 0) { print p; return }
    for (j = 1; j <= len; j++) gen(p substr(charset, j, 1), n - 1)
}
' >> TEMP_URLS.txt
fi
if [ "$SUFFIX_VAL" != "" ]; then
    mv TEMP_URLS.txt S_TEMP.txt
    : > TEMP_URLS.txt
    cat S_TEMP.txt | sed 's/[^a-zA-Z0-9:./_-]//g' | xargs -P $PARALLEL_VAL -I {} bash -c 'CURLER_SUFFIX_FILL "$1" ' _  {}
fi










curler_CURLS_T()
{
    printf "%s\x1f%s\n" "$1" "$(curl -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" --max-filesize 5000 -s  "${1}" | grep -iPo '(?<=<title>).*?(?=</title>)')" >> CURLOUT_TEMP.txt
}
curler_CURLS_B()
{
    printf "%s\x1f%s\n" "$1" "$(curl -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" --max-filesize 5000 -s  "${1}"  | sed -e '/<style[^>]*>/,/<\/style>/d' -e 's/<[^>]*>//g' -e 's/{[^}]*}//g'  -e 's/[[:space:]]//g' | tr -d '\n\r')">> CURLOUT_TEMP.txt
}
curler_CURLS_W()
{
    printf "%s\x1f%s\n" "$1" "$(curl -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" --max-filesize 5000 -s  "${1}"  | sed -e '/<style[^>]*>/,/<\/style>/d' -e 's/<[^>]*>//g' -e 's/{[^}]*}//g' | tr -d '\n\r')">> CURLOUT_TEMP.txt

}
curler_CURLS_C()
{
    RESPCODE=$("$(curl -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" --max-filesize 5000 -sI -o /dev/null -w "%{http_code}" "${2}/${1}" )") 
    if [ "$RESPCODE" != "404" ]; then
        echo "$2/$1 : RESPONSE : $CODE" >> out.txt
    fi 
}
export -f curler_CURLS_T
export -f curler_CURLS_B
export -f curler_CURLS_W
export -f curler_CURLS_C

if [ "$TITLE" == 1 ]; then
    cat TEMP_URLS.txt | xargs -P $PARALLEL_VAL -I {} bash -c 'curler_CURLS_T "$1" ' _   "{}"
elif [ "$BODY" == 1 ]; then
    cat TEMP_URLS.txt | xargs -P $PARALLEL_VAL -I {} bash -c 'curler_CURLS_B "$1" ' _   "{}"
elif [ "$WORD" == 1 ]; then
    cat TEMP_URLS.txt | xargs -P $PARALLEL_VAL -I {} bash -c 'curler_CURLS_W "$1" ' _   "{}"
elif [ "$CODE" == 1 ]; then
    cat TEMP_URLS.txt | xargs -P $PARALLEL_VAL -I {} bash -c 'curler_CURLS_C "$1" ' _   "{}"
else
    echo "ERROR 111"
    exit 1
fi

    





curler_ANALYSIS_TB()
{
    TITLESTR="${1%%$'\x1f'*}"
    DATALINE="${1#*$'\x1f'}"
    DATAAVE=0
    i=0
    while [ "$i" -lt ${#3} ]; do
        KEYCHAR="${2:$i:1}"
        TESTCHAR="${DATALINE:$i:1}"
        if [ "$TESTCHAR" != "$KEYCHAR" ]; then
            ((DATAAVE++))
        fi
        i=$((i + 1))
    done
    LENGTH="${#3}"
    if [ "$LENGTH" -gt 0 ]; then
        DATAAVE=$(awk -v sum="$DATAAVE" -v len="$LENGTH" \
            'BEGIN { printf "%.2f\n", sum / len }')
    else
        if [ ${#DATALINE} -gt 0 ]; then
            DATAAVE=1
        fi
    fi
    if awk "BEGIN {exit !($DATAAVE > 0.5)}"; then
        echo "$TITLESTR : UNIQUE VALUE : $DATAAVE" >> out.txt
    fi
}
curler_ANALYSIS_W()
{
    
    TITLESTR="${1%%$'\x1f'*}"
    DATALINE="${1#*$'\x1f'}"
    KEY_MAP=$2
    declare -A DATA_MAP
    eval "$KEY_MAP_DEF"
    set -f
    for word in $DATALINE; do
        ((DATA_MAP["$word"]++))
    done
    set +f
    DATAAVE=0
    TOTAL=0
    for key in "${!DATA_MAP[@]}"; do
        if  [ -v "KEY_MAP["$key"]" ]; then
            d_count="${DATA_MAP["$key"]}"
            k_count="${KEY_MAP["$key"]}"

            if (( d_count < k_count )); then
                MIN=$d_count
                MAX=$k_count
            else
                MIN=$k_count
                MAX=$d_count
            fi
            
            DATAAVE=$(awk -v total="$DATAAVE" -v min="$MIN" -v max="$MAX" \
                'BEGIN { printf "%.2f", total + (min / max) }')
            ((TOTAL++))
        else
            ((TOTAL += DATA_MAP["$key"]))
        fi
    done


    if [ "$TOTAL" -gt 0 ]; then
        DATAAVE=$(awk -v sum="$DATAAVE" -v len="$TOTAL" \ 'BEGIN { printf "%.2f\n", sum / len }')
    else
        DATAAVE=0
        
    fi
    DATAAVE=$(awk -v sum="$DATAAVE" \
            'BEGIN { printf "%.2f\n", 1 - sum }')
    if awk "BEGIN {exit !($DATAAVE > 0.5)}"; then
        echo "$TITLESTR : UNIQUE VALUE : $DATAAVE" >> out.txt
    fi
}


export -f curler_ANALYSIS_TB

export -f curler_ANALYSIS_W

 
if [ "$TITLE" == 1 ] || [ "$BODY" == 1 ]  ; then
    cat CURLOUT_TEMP.txt | xargs -P $PARALLEL_VAL -I {} bash -c 'curler_ANALYSIS_TB "$1" "$2" "$3"' _  {} "$greatest" "$smallest"
elif [ "$WORD" == 1 ]; then
    #build key map
    declare -A KEY_MAP
   
    for word in $greatest; do
        if  [ -v KEY_MAP["$word"] ]; then
            ((KEY_MAP[$word]++))
        else
            KEY_MAP[$word]=1
        fi
    done
    KEY_MAP_DEF=$(declare -p KEY_MAP)
    export KEY_MAP_DEF
    cat CURLOUT_TEMP.txt | xargs -P $PARALLEL_VAL -I {} bash -c 'curler_ANALYSIS_W "$1" "$2"' _  {} "$KEY_MAP"
else
    echo "ERROR 114" 
    exit 1
fi




exit 0