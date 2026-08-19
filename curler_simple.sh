#SCRIPT FOR FINDING HTML PAGES
#MY CODE NO STEALING - FISCHEEY
URLSET=0 
CODE=0
BODY=0
PARALLEL_VAL=1
DICTIONARY_VAL=0
SUFFIX_VAL=0

touch out.txt; : > out.txt
touch TEMP_URLS.txt; : > TEMP_URLS.txt
touch CURLOUT_TEMP.txt; : > CURLOUT_TEMP.txt
touch SUFFIX_TEMP.txt; : > SUFFIX_TEMP.txt


cleanup() {
    echo "🧹 Executing cleanup operations..."
    
    # Remove temporary directories safely
    if [ -n "$BACKGROUND_PID" ]; then
        kill "$BACKGROUND_PID" 2>/dev/null
    fi
    kill $(jobs -p) 2>/dev/null
    # remove temporary files
    rm -f TEMP_URLS.txt CURLOUT_TEMP.txt SUFFIX_TEMP.txt S_TEMP.txt 
}
trap cleanup EXIT INT TERM



#show usage details
usage() {
    echo "Usage: $0 [-P int ] [-S string] [-D filename] [-B] [-C]"
    echo "  -P thread count        "
    echo "  -S file suffix         "
    echo "  -D dictionary filename            "
    echo "  -B body mode            "
    echo "  -C code mode            "    
    exit 1
}

# Loop through arguments
while [ $# -gt 0 ]; do
    case "$1" in
        -S) SUFFIX_VAL="$2"; shift 2 ;;
        -P) PARALLEL_VAL="$2"; shift 2 ;;
        -D) DICTIONARY_VAL="$2"; shift 2 ;;
        -C) CODE=1; shift ;;
        -B) BODY=1; shift ;;
        http://*|https://*)
            if [ "$URLSET" != 1 ]; then
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

#print out information to terminal - contstant time
printf "\n\n--- PROGRAM SETUP ---\n"
if [ "$URLSET" != 0 ]; then
    echo -e " - URLSET - ${GREEN}${TICK}${RESET}  - $URL"
else
    echo -e " - URLSET - ${RED}${CROSS}${RESET}"
    echo " - ERROR - URL - PROGRAM EXIT"
    exit 1
fi
if [ "$DICTIONARY_VAL" != 0 ]; then
    if [ ! -f "$DICTIONARY_VAL" ]; then
        echo "Error: Dictionary file not found at $DICTIONARY_VAL."
        exit 1
    fi
    echo -e " - DICTIONARY MODE - ${GREEN}${TICK}${RESET} - $DICTIONARY_VAL"
fi
if [ "$PARALLEL_VAL" != 1 ]; then
    echo -e " - PARALLEL MODE - ${GREEN}${TICK}${RESET}   - SETTING TO $PARALLEL_VAL"
else 
    echo -e " - PARALLEL MODE - ${RED}${TICK}${RESET} - SETTING TO 1"
fi
if [ "$BODY" != 0 ]; then
    echo -e " - BODY MODE - ${GREEN}${TICK}${RESET}"
    echo -e " - CODE MODE - ${RED}${CROSS}${RESET}"
elif [ "$CODE" != 0 ]; then
    echo -e " - BODY MODE - ${RED}${CROSS}${RESET}"
    echo -e " - CODE MODE - ${GREEN}${TICK}${RESET}"
else
    echo " - ERROR - MUST SELECT AN ANALYSIS MODE - PROGRAM EXIT"
    exit 1
fi
if [ "$SUFFIX_VAL" != 0 ]; then
    echo -e " - SUFFIX MODE - ${GREEN}${TICK}${RESET} - $SUFFIX_VAL"
    if [ -f "$SUFFIX_VAL" ]; then
        while IFS= read -r suff; do
            while IFS= read -r dict; do
                echo "$dict/$suff" >> TEMP_URLS.txt
            done < "$DICTIONARY_VAL"
        done < "$SUFFIX_VAL"
    else
        while IFS= read -r dict; do
            echo "$dict/$SUFFIX_VAL" >> TEMP_URLS.txt
        done < "$DICTIONARY_VAL"
    fi
else 
    echo -e " - SUFFIX MODE - ${RED}${CROSS}${RESET}"
    cp "$DICTIONARY_VAL" TEMP_URLS.txt
fi
echo "--- PROGRAM RUN ---"


#runs asynchronous timer
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





#runs tests to get what should respond for negative 
#i considered making this a loop for the three things but it seemed like it wouldnt help so im just not
if [ "$BODY" != 0 ]; then
    TESTURL1=$(curl -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" --max-filesize 5000 -s "$URL/$(tr -dc 'a-z0-9' < /dev/urandom | head -c 24)"  | sed -e '/<style[^>]*>/,/<\/style>/d' -e 's/<[^>]*>//g' -e 's/{[^}]*}//g' -e 's/[[:space:]]//g' | tr -d '\n\r')
    TESTURL2=$(curl -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" --max-filesize 5000 -s "$URL/$(tr -dc 'a-z0-9' < /dev/urandom | head -c 24)"  | sed -e '/<style[^>]*>/,/<\/style>/d' -e 's/<[^>]*>//g' -e 's/{[^}]*}//g' -e 's/[[:space:]]//g' | tr -d '\n\r')
    TESTURL3=$(curl -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" --max-filesize 5000 -s "$URL/$(tr -dc 'a-z0-9' < /dev/urandom | head -c 24)"  | sed -e '/<style[^>]*>/,/<\/style>/d' -e 's/<[^>]*>//g' -e 's/{[^}]*}//g' -e 's/[[:space:]]//g' | tr -d '\n\r')

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
else
    #TODO run tests for code version
    TESTURL1=$(curl -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" --max-filesize 5000 -sI -o /dev/null -w "%{http_code}" "$URL/$(tr -dc 'a-z0-9' < /dev/urandom | head -c 24)")
    if [ "$TESTURL1" != 404 ]; then
        echo "ERROR - RANDOM URL RETURNED POSITIVE RESPONSE, RECOMMEDED TO USE TITLE MODE - EXITING"
        exit 1
    fi 
fi


#define curler functions for body and code
curler_CURLS_B()
{
    printf "%s\x1f%s\n" "$2/$1" "$(curl -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" --max-filesize 5000 -s "${2}/${1}"  | sed -e '/<style[^>]*>/,/<\/style>/d' -e 's/<[^>]*>//g' -e 's/{[^}]*}//g'  -e 's/[[:space:]]//g' | tr -d '\n\r')">> CURLOUT_TEMP.txt
}

curler_CURLS_C()
{
    RESPCODE=$("$(curl -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" --max-filesize 5000 -sI -o /dev/null -w "%{http_code}" "${2}/${1}" )") 
    if [ "$RESPCODE" != "404" ]; then
        echo "$2/$1 : RESPONSE : $CODE" >> out.txt
    fi 
}
#export functions
export -f curler_CURLS_B
export -f curler_CURLS_C
#run functions in parallel 
if [ "$BODY" != 0 ]; then
    cat TEMP_URLS.txt | sed 's/[^a-zA-Z0-9:./_-]//g' | xargs -P $PARALLEL_VAL -I {} bash -c 'curler_CURLS_B "$1" "$2"' _   "{}" "$URL"
    echo curler done
elif [ "$CODE" != 0 ]; then
    cat TEMP_URLS.txt | sed 's/[^a-zA-Z0-9:./_-]//g' | xargs -P $PARALLEL_VAL -I {} bash -c 'curler_CURLS_C "$1" "$2" "$3"' _   "{}" "$URL" 
else
    echo "ERROR 111"
    exit 1
fi

    

# define analysis function
curler_ANALYSIS_B()
{
    #seperate title and data in the file 
    TITLESTR="${1%%$'\x1f'*}"
    DATALINE="${1#*$'\x1f'}"
    DATAAVE=0
    #for loop counts how many characters are idential between the test curl and the line curl
    i=0
    while [ "$i" -lt ${#3} ]; do
        KEYCHAR="${2:$i:1}"
        TESTCHAR="${DATALINE:$i:1}"
        if [ "$TESTCHAR" != "$KEYCHAR" ]; then
            DATAAVE=$((DATAAVE + 1))
        fi
        i=$((i + 1))
    done
    LENGTH="${#3}"
    #creates average value based on percentage accurate
    if [ "$LENGTH" -gt 0 ]; then
        DATAAVE=$(awk -v sum="$DATAAVE" -v len="$LENGTH" \
            'BEGIN { printf "%.2f\n", sum / len }')
    else
        if [ ${#DATALINE} -gt 0 ]; then
            DATAAVE=1
        fi
    fi
    #if unique average is greater then .5 then add it to the out file
    if awk "BEGIN {exit !($DATAAVE > 0.5)}"; then
        echo "$TITLESTR : UNIQUE VALUE : $DATAAVE" >> out.txt
    fi
}
#export analysis function
export -f curler_ANALYSIS_B
#run analysis function
if  [ "$BODY" != 0 ]  ; then
    cat CURLOUT_TEMP.txt | xargs -P $PARALLEL_VAL -I {} bash -c 'curler_ANALYSIS_B "$1" "$2" "$3"' _  {} "$greatest" "$smallest"
fi


exit 0