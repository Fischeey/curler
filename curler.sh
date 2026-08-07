#SCRIPT FOR FINDING HTML PAGES
#MY CODE NO STEALING - FISCHEEY
MODESET=0
DICTIONARY=0
NESTED=0
URLSET=0 
COUNTER=0
RAW=0
PARALLEL=0
CODE=0

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


cleanup() {
    echo "🧹 Executing cleanup operations..."
    
    # Remove temporary directories safely
    kill "$BACKGROUND_PID" 2>/dev/null
    # Optional: Terminate residual background processes spawned by this script
    kill $(jobs -p) 2>/dev/null
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
    elif [[ "$arg" == "-D" ]] && [[ "$MODESET" == 1 ]]; then
        echo " - ERROR - MUST SELECT EITHER RAW MODE OR DICTIONARY MODE - PROGRAM EXIT"
        exit 1
    elif [[ "$arg" == "-R" ]]  && [[ "$MODESET" == 0 ]]; then
        RAW=$COUNTER
        MODESET=1
    elif [[ "$arg" == "-R" ]]  && [[ "$MODESET" == 1 ]]; then
        echo " - ERROR - MUST SELECT EITHER RAW MODE OR DICTIONARY MODE - PROGRAM EXIT"
        exit 1

    
    elif [[ "$arg" == "-N" ]]; then
        NESTED=$COUNTER
    elif [[ "$arg" == *"https://"* ]] || [[ $arg == *"http://"* ]]; then
        URLSET=1
        URL=$arg
    elif [[ "$arg" == "-P" ]]; then 
        PARALLEL=$COUNTER
    

    #F$
    #ANALYSIS MODE
    #
    elif [[ ("$arg" == "-T" || "$arg" == "-B" || "$arg" == "-W" ) && "$ANALYSISSET" == 1 ]]; then 
        echo "ERROR - can only enter one analysis mode"
        exit 1
    elif [[ "$arg" == "-T" ]] && [[ "$ANALYSISSET" == 0 ]]; then 
        TITLE=1
        ANALYSISSET=1
    elif [[ "$arg" == "-B" ]] && [[ "$ANALYSISSET" == 0 ]]; then 
        ANALYSISSET=1
        BODY=1
    elif [[ "$arg" == "-W" ]] && [[ "$ANALYSISSET" == 0 ]]; then 
        ANALYSISSET=1
        WORD=1
    elif [[ "$arg" == "-C" ]] && [[ "$ANALYSISSET" == 0 ]]; then 
        ANALYSISSET=1
        CODE=1
    elif [[ "$arg" == "-S" ]]; then 
        TITLE=1
    fi
    ((COUNTER++))
    
done 

PARALLEL_VAL=1
DICTIONARY_VAL=1
RAW_VAL=1
NESTED_VAL=1
SUFFIX_VAL=1

if [[ "$PARALLEL" -gt 0 ]]; then
    TEMP=$((2 + "$PARALLEL"))
    PARALLEL_VAL=${!TEMP}
fi 
if [[ "$DICTIONARY" -gt 0 ]]; then
    TEMP=$((2 + "$DICTIONARY"))
    DICTIONARY_VAL=${!TEMP}
fi
if [[ "$RAW" -gt 0 ]]; then
    TEMP=$((2 + "$RAW"))
    RAW_VAL=${!TEMP}
fi
if [[ "$NESTED" -gt 0 ]]; then
    TEMP=$((2 + "$NESTED"))
    NESTED_VAL=${!TEMP}
fi
if [[ "$SUFFIX" -gt 0 ]]; then
    TEMP=$((2 + "$SUFFIC"))
    SUFFIX_VAL=${!TEMP}
fi


#need to implement response mode



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


if [[ "$RAW" -ne 0 ]]; then
    echo -e " - RAW MODE - ${GREEN}${TICK}${RESET}"
    echo -e " - DICTIONARY MODE - ${RED}${CROSS}${RESET}"
elif [[ "$DICTIONARY" -ne 0 ]]; then
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

if [[ "$NESTED" -ne 0 ]]; then
    echo -e " - NESTED MODE - ${GREEN}${TICK}${RESET} - $NESTED_VAL"
else 
    echo -e " - NESTED MODE - ${RED}${CROSS}${RESET}"
fi

if [[ "$PARALLEL" -ne 0 ]]; then
    echo -e " - PARALLEL MODE - ${GREEN}${TICK}${RESET}   - SETTING TO $PARALLEL_VAL"
else 
    echo -e " - PARALLEL MODE - ${RED}${TICK}${RESET} - SETTING TO 1"
fi

if [[ "$TITLE" -ne 0 ]]; then
    echo -e " - TITLE MODE - ${GREEN}${TICK}${RESET}"
    echo -e " - BODY MODE - ${RED}${CROSS}${RESET}"
    echo -e " - WORD MODE - ${RED}${CROSS}${RESET}"
    echo -e " - CODE MODE - ${RED}${CROSS}${RESET}"
elif [[ "$BODY" -ne 0 ]]; then
    echo -e " - TITLE MODE - ${RED}${CROSS}${RESET}"
    echo -e " - BODY MODE - ${GREEN}${TICK}${RESET}"
    echo -e " - WORD MODE - ${RED}${CROSS}${RESET}"
    echo -e " - CODE MODE - ${RED}${CROSS}${RESET}"
elif [[ "$WORD" -ne 0 ]]; then
    echo -e " - TITLE MODE - ${RED}${CROSS}${RESET}"
    echo -e " - BODY MODE - ${RED}${CROSS}${RESET}"
    echo -e " - WORD MODE - ${GREEN}${TICK}${RESET}"
    echo -e " - CODE MODE - ${RED}${CROSS}${RESET}"
elif [[ "$CODE" -ne 0 ]]; then
    echo -e " - TITLE MODE - ${RED}${CROSS}${RESET}"
    echo -e " - BODY MODE - ${RED}${CROSS}${RESET}"
    echo -e " - WORD MODE - ${RED}${CROSS}${RESET}"
    echo -e " - CODE MODE - ${GREEN}${TICK}${RESET}"
else
    echo " - ERROR - MUST SELECT AN ANALYSIS MODE - PROGRAM EXIT"
    exit 1
fi

if [[ "$SUFFIX" -ne 0 ]]; then
    echo -e " - SUFFIX MODE - ${GREEN}${TICK}${RESET}"
else 
    echo -e " - SUFFIX MODE - ${RED}${CROSS}${RESET}"
fi
echo "--- PROGRAM RUN ---"




TIMER(){
    urlcount=$(wc -l < "TEMP_URLS.txt")
    outcount=$(wc -l < "out.txt")
    timer=0
    while [ "$urlcount" -gt "$outcount" ] && [ -f TEMP_URLS.txt ] ; do
        urlcount=$(wc -l < "TEMP_URLS.txt")
        outcount=$(wc -l < "out.txt")
        echo "LINES PROCESSED = $outcount/$urlcount --- TIME ELAPSED = "
        sleep 2
        (( timer += 2 ))
    done
}

TIMER &








#dictionary setup
echo "url = $URL" >> TEMP_URLS.txt
if [[ "$DICTIONARY" -gt 0 ]]; then
    if [[ "$NESTED" -gt 0 ]]; then
        while IFS= read -r NEST; do
            while IFS= read -r LINE; do
                echo "$URL/$NEST/$LINE" >> TEMP_URLS.txt
            done < "$DICTIONARY_VAL"
        done < "$NESTED_VAL"
    else
        while IFS= read -r LINE; do
            echo "$URL/$LINE" >> TEMP_URLS.txt
        done < "$DICTIONARY_VAL"
    fi
elif [[ "$RAW" -gt 0 ]]; then
    echo "RAW"
fi

if [[ "$SUFFIX" -gt 0 ]]; then
    cp TEMP_URLS.txt SUFFIX_TEMP.txt
    while IFS= read -r SUFFIX; do
        while IFS= read -r LINE; do
            echo "$LINE/$SUFFIX" >> TEMP_URLS.txt
        done < TEMP_URLS.txt
    done < "$SUFFIX_VAL"
fi



curler_T()
{
    printf "%s>%s\n" "$1" "$(curl -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" --max-filesize 50000 -s  "${1}" | grep -iPo '(?<=<title>).*?(?=</title>)')" >> CURLOUT_TEMP.txt
}
curler_B()
{
    printf "%s>%s\n" "$1" "$(curl -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" --max-filesize 5000 -s  "${1}"  | sed -e '/<style[^>]*>/,/<\/style>/d' -e 's/<[^>]*>//g' -e 's/{[^}]*}//g'  -e 's/[[:space:]]//g' | tr -d '\n\r')">> CURLOUT_TEMP.txt
}
curler_W()
{
    printf "%s>%s\n" "$1" "$(curl -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" --max-filesize 5000 -s  "${1}"  | sed -e '/<style[^>]*>/,/<\/style>/d' -e 's/<[^>]*>//g' -e 's/{[^}]*}//g' | tr -d '\n\r')">> CURLOUT_TEMP.txt
}
curler_C()
{
    printf "%s>%s\n" "$1" "$(curl -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" --max-filesize 5000 -sI -o /dev/null -w "%{http_code}" "${1}" )" >> CURLOUT_TEMP.txt
}
export -f curler_T
export -f curler_B
export -f curler_W
export -f curler_C

if [[ "$TITLE" -eq 1 ]]; then
    cat TEMP_URLS.txt | xargs -P $PARALLEL_VAL -I {} bash -c 'curler_T "$1" ' _   "{}"
elif [[ "$BODY" -eq 1 ]]; then
    cat TEMP_URLS.txt | xargs -P $PARALLEL_VAL -I {} bash -c 'curler_B "$1" ' _   "{}"
elif [[ "$WORD" -eq 1 ]]; then
    cat TEMP_URLS.txt | xargs -P $PARALLEL_VAL -I {} bash -c 'curler_W "$1" ' _   "{}"
elif [[ "$CODE" -eq 1 ]]; then
    cat TEMP_URLS.txt | xargs -P $PARALLEL_VAL -I {} bash -c 'curler_C "$1" ' _   "{}"
else
    echo "ERROR 111"
    exit 1
fi

    


 
if [[ "$TITLE" -eq 1 ]]; then
    TESTURL1=$(curl -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" --max-filesize 5000 -s "$URL/$(tr -dc 'a-z0-9' < /dev/urandom | head -c 24)"  | grep -iPo '(?<=<title>).*?(?=</title>)')
    TESTURL2=$(curl -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" --max-filesize 5000 -s "$URL/$(tr -dc 'a-z0-9' < /dev/urandom | head -c 24)"  | grep -iPo '(?<=<title>).*?(?=</title>)')
    TESTURL3=$(curl -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" --max-filesize 5000 -s "$URL/$(tr -dc 'a-z0-9' < /dev/urandom | head -c 24)"  | grep -iPo '(?<=<title>).*?(?=</title>)')
elif [[ "$BODY" -eq 1 ]]; then
    TESTURL1=$(curl -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" --max-filesize 5000 -s "$URL/$(tr -dc 'a-z0-9' < /dev/urandom | head -c 24)"  | sed -e '/<style[^>]*>/,/<\/style>/d' -e 's/<[^>]*>//g' -e 's/{[^}]*}//g' -e 's/[[:space:]]//g' | tr -d '\n\r')
    TESTURL2=$(curl -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" --max-filesize 5000 -s "$URL/$(tr -dc 'a-z0-9' < /dev/urandom | head -c 24)"  | sed -e '/<style[^>]*>/,/<\/style>/d' -e 's/<[^>]*>//g' -e 's/{[^}]*}//g' -e 's/[[:space:]]//g' | tr -d '\n\r')
    TESTURL3=$(curl -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" --max-filesize 5000 -s "$URL/$(tr -dc 'a-z0-9' < /dev/urandom | head -c 24)"  | sed -e '/<style[^>]*>/,/<\/style>/d' -e 's/<[^>]*>//g' -e 's/{[^}]*}//g' -e 's/[[:space:]]//g' | tr -d '\n\r')
elif [[ "$WORD" -eq 1 ]]; then
    TESTURL1=$(curl -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" --max-filesize 5000 -s "$URL/$(tr -dc 'a-z0-9' < /dev/urandom | head -c 24)"  | sed -e '/<style[^>]*>/,/<\/style>/d' -e 's/<[^>]*>//g' -e 's/{[^}]*}//g' | tr -d '\n\r')
    TESTURL2=$(curl -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" --max-filesize 5000 -s "$URL/$(tr -dc 'a-z0-9' < /dev/urandom | head -c 24)"  | sed -e '/<style[^>]*>/,/<\/style>/d' -e 's/<[^>]*>//g' -e 's/{[^}]*}//g' | tr -d '\n\r')
    TESTURL3=$(curl -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" --max-filesize 5000 -s "$URL/$(tr -dc 'a-z0-9' < /dev/urandom | head -c 24)"  | sed -e '/<style[^>]*>/,/<\/style>/d' -e 's/<[^>]*>//g' -e 's/{[^}]*}//g' | tr -d '\n\r') 
elif [[ "$CODE" -eq 1 ]]; then
    TESTURL1=$(curl -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" --max-filesize 5000 -sI -o /dev/null -w "%{http_code}\n" "$URL/$(tr -dc 'a-z0-9' < /dev/urandom | head -c 24)")
    TESTURL2=$(curl -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" --max-filesize 5000 -sI -o /dev/null -w "%{http_code}\n" "$URL/$(tr -dc 'a-z0-9' < /dev/urandom | head -c 24)")
    TESTURL3=$(curl -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" --max-filesize 5000 -sI -o /dev/null -w "%{http_code}\n" "$URL/$(tr -dc 'a-z0-9' < /dev/urandom | head -c 24)")
    echo $TESTURL1
    echo $TESTURL2


else
    echo "ERROR 112"
    exit 1
fi
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
((TESTURL1AVE /= "${#smallest}"))
((TESTURL2AVE /= "${#smallest}"))
((TESTURL3AVE /= "${#smallest}"))

if awk "BEGIN {exit !($TESTURL1AVE > $TESTURL2AVE && $TESTURL1AVE > $TESTURL3AVE)}"; then
    greatest=$TESTURL1
elif awk "BEGIN {exit !($TESTURL2AVE > $TESTURL1AVE && $TESTURL2AVE > $TESTURL3AVE)}"; then
    greatest=$TESTURL2
else
    greatest=$TESTURL3
fi

if [[ "$TITLE" -eq 1 ]] || [[ "$BODY" -eq 1 ]] || [[ "$CODE" -eq 1 ]]  ; then
    while IFS= read -r DATALINE; do
        TITLESTR="${DATALINE%%>*}"
        DATALINE="${DATALINE#*>}"
        DATAAVE=0
        for (( i=0; i<${#smallest}; i++ )); do
            KEYCHAR="${greatest:$i:1}"
            TESTCHAR="${DATALINE:$i:1}"
            if [[ "$TESTCHAR" != "$KEYCHAR" ]]; then
                ((DATAAVE++))
            fi

        done
        LENGTH="${#smallest}"
        if [ "$LENGTH" -gt 0 ]; then
            DATAAVE=$(awk -v sum="$DATAAVE" -v len="$LENGTH" \
                'BEGIN { printf "%.2f\n", sum / len }')
        else
            echo "LENGTH is zero"
        fi
        if awk "BEGIN {exit !($DATAAVE > 0.5)}"; then
            echo "$TITLESTR : UNIQUE VALUE : $DATAAVE" >> out.txt
        fi
    done < CURLOUT_TEMP.txt
elif [[ "$WORD" -eq 1 ]]; then


    #build key map
    declare -A KEY_MAP
    KEY_MAP=()
    for word in $greatest; do
        if  [[ -v KEY_MAP["$word"] ]]; then
            ((KEY_MAP[$word]++))
        else
            KEY_MAP[$word]=1
        fi
    done

    while IFS= read -r DATALINE; do
        TITLESTR="${DATALINE%%>*}"
        DATALINE="${DATALINE#*>}"

        declare -A DATA_MAP
        DATA_MAP=()

        for word in $DATALINE; do
            
            ((DATA_MAP["$word"]++))
        done
        DATAAVE=0
        TOTAL=0
        for key in "${!DATA_MAP[@]}"; do
            
            if  [[ -v "KEY_MAP["$key"]" ]]; then
                MIN=$(( "${DATA_MAP["$key"]}" < "${KEY_MAP["$key"]}" ? "${DATA_MAP["$key"]}" : "${KEY_MAP["$key"]}" ))
                MAX=$(( "${DATA_MAP["$key"]}" > "${KEY_MAP["$key"]}" ? "${DATA_MAP["$key"]}" : "${KEY_MAP["$key"]}" ))
                
                DATAAVE=$(awk -v total="$DATAAVE" -v min="$MIN" -v max="$MAX" \
                    'BEGIN { printf "%.2f", total + (min / max) }')
                ((TOTAL++))
            else
                ((TOTAL+="${DATA_MAP["$word"]}"))
            fi
        done


        if [ "$TOTAL" -gt 0 ]; then
            DATAAVE=$(awk -v sum="$DATAAVE" -v len="$TOTAL" \ 'BEGIN { printf "%.2f\n", sum / len }')
        else
            echo "TOTAL is zero"
        fi
        DATAAVE=$(awk -v sum="$DATAAVE" \
                'BEGIN { printf "%.2f\n", 1 - sum }')
        #if awk "BEGIN {exit !($DATAAVE > 0.5)}"; then
            echo "$TITLESTR : UNIQUE VALUE : $DATAAVE" >> out.txt
        #fi
    done < CURLOUT_TEMP.txt
else
    echo "ERROR 114"
    exit 1
fi



echo "--- PROGRAM END ---"
exit 0