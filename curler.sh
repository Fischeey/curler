#SCRIPT FOR FINDING HTML PAGES
#MY CODE NO STEALING - FISCHEEY
MODESET=0
DICTIONARY=0
NESTED=0
URLSET=0 
COUNTER=0
RAW=0
PARALLEL=0

ANALYSISSET=0
TITLE=0
UNIQUE=0

touch out.txt
: > out.txt
touch TEMP_URLS.txt
: > TEMP_URLS.txt
touch UNIQUE_TEMP.txt
: > UNIQUE_TEMP.txt


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
        echo "activating DICTIONARY mode"
        DICTIONARY=$COUNTER
        MODESET=1
    elif [[ "$arg" == "-D" ]] && [[ "$MODESET" == 1 ]]; then
        echo "error - can only set one input mode"
        exit 1
    elif [[ "$arg" == "-R" ]]  && [[ "$MODESET" == 0 ]]; then
        echo "entering RAW mode"
        RAW=$COUNTER
        MODESET=1
    elif [[ "$arg" == "-R" ]]  && [[ "$MODESET" == 1 ]]; then
        echo "error - can only set one input mode"
        exit 1

    
    elif [[ "$arg" == "-N" ]]; then
        echo "activating NESTED mode"
        NESTED=$COUNTER
    elif [[ "$arg" == *"https://"* ]] || [[ $arg == *"https://"* ]]; then
        echo "setting url"
        URLSET=$COUNTER
        URL=$arg
    elif [[ "$arg" == "-P" ]]; then 
        echo "entering PARALLEL mode"
        PARALLEL=$COUNTER
    

    #
    #ANALYSIS MODE
    #
    elif [[ "$arg" == "-T" ]] && [[ "$ANALYSISSET" == 0 ]]; then 
        echo "entering TITLE mode"
        TITLE=1
    elif [[ "$arg" == "-T" ]] && [[ "$ANALYSISSET" == 1 ]]; then 
        echo "ERROR - can only enter one analysis mode"
        exit 1
    elif [[ "$arg" == "-U" ]] && [[ "$ANALYSISSET" == 0 ]]; then 
        echo "entering UNIQUE mode"
        UNIQUE=1
    elif [[ "$arg" == "-U" ]] && [[ "$ANALYSISSET" == 1 ]]; then 
        echo "ERROR - can only enter one analysis mode"
        exit 1
    fi
    ((COUNTER++))
done 









#dictionary setup
if [[ "$DICTIONARY" -gt 0 ]]; then
    echo "dictionary non nested"
    TEMP=$((2 + "$DICTIONARY"))
    DICTIONARY_VAL=${!TEMP}
    echo $DICTIONARY_VAL
    if [[ "$NESTED" -gt 0 ]]; then
        TEMP=$((2 + "$NESTED"))
        NESTED_VAL=${!TEMP}
        echo $NESTED_VAL
        echo "dictionary nested"
        if [[ "$PARALLEL" = 0 ]]; then
            while IFS= read -r NEST; do
                while IFS= read -r LINE; do
                    echo "url = $URL/$NEST/$LINE" >> TEMP_URLS.txt
                done < "$DICTIONARY_VAL"
            done < "$NESTED_VAL"
        else
            while IFS= read -r NEST; do
                while IFS= read -r LINE; do
                    echo "$URL/$NEST/$LINE" >> TEMP_URLS.txt
                done < "$DICTIONARY_VAL"
            done < "$NESTED_VAL"
        fi
    else

        if [ ! -f "$DICTIONARY_VAL" ]; then
            echo "Error: Dictionary file not found at $DICTIONARY_VAL."
            echo "On Debian/Ubuntu, install it using: sudo apt install wamerican"
            exit 1
        fi
        if [[ "$PARALLEL" = 0 ]]; then
            echo "url = $URL" >> TEMP_URLS.txt
            while IFS= read -r LINE; do
                echo "url = $URL/$LINE" >> TEMP_URLS.txt
            done < "$DICTIONARY_VAL"
        else
            echo "$URL" >> TEMP_URLS.txt
            while IFS= read -r LINE; do
                echo "$URL/$LINE" >> TEMP_URLS.txt
            done < "$DICTIONARY_VAL"
        fi
    fi
fi

if [[ "$RAW" -gt 0 ]]; then
    TEMP=$((2 + "$RAW"))
    RAW_VAL=${!TEMP}
    echo $RAW_VAL
    
fi





if [[ "$PARALLEL" -gt 0 ]]; then
    TEMP=$((2 + "$PARALLEL"))
    PARALLEL_VAL=${!TEMP}

    curler_T(){
         if curl --max-filesize 50000 -s  "${1}" | grep -iPo '(?<=<title>).*?(?=</title>)'; then
            echo "${1}" >> out.txt
        fi
    }
    curler_U()
    {
        printf "%s>%s\n" "$1" "$(curl --max-filesize 5000 -s  "${1}"  | sed -e '/<style[^>]*>/,/<\/style>/d' -e 's/<[^>]*>//g' -e 's/{[^}]*}//g'  -e 's/[[:space:]]//g' | tr -d '\n\r')">> UNIQUE_TEMP.txt
    }
    export -f curler_T
    export -f curler_U

    if [[ "$TITLE" -eq 1 ]]; then
        echo "run parallel Title"
        cat TEMP_URLS.txt | xargs -P 64 -I {} bash -c 'curler_T "$1" ' _   "{}"
    elif [[ "$UNIQUE" -eq 1 ]]; then
        touch UNIQUE_TEMP.txt
        echo "run parallel unique"
        cat TEMP_URLS.txt | xargs -P 64 -I {} bash -c 'curler_U "$1" ' _   "{}"
    else
        echo "ERROR 111"
        exit 1
    fi

    

else
    if [[ "$TITLE" -eq 1 ]]; then
    echo "run non parallel by title"
        while IFS='=' read -r _ url; do
            url=$(echo "$url" | xargs)    # trim whitespace
            title=$(curl --max-filesize 500000 -Ls "$url" | grep -oP '(?<=<title>).*?(?=</title>)')
            echo '%s\t%s\n' "$url" "$title" >> out.txt
        done < TEMP_URLS.txt
    elif [[ "$UNIQUE" -eq 1 ]]; then
        echo "run non parallel unique"
    else
        echo "ERROR 112"
        exit 1
    fi
fi

echo "run unique analysis"

if [[ "$UNIQUE" -eq 1 ]]; then
#-e 's/<style>.*<\/style>//g'
    TESTURL1=$(curl --max-filesize 5000 -s "$URL/$(tr -dc 'a-z0-9' < /dev/urandom | head -c 24)"  | sed -e '/<style[^>]*>/,/<\/style>/d' -e 's/<[^>]*>//g' -e 's/{[^}]*}//g' -e 's/[[:space:]]//g' | tr -d '\n\r')
    TESTURL2=$(curl --max-filesize 5000 -s "$URL/$(tr -dc 'a-z0-9' < /dev/urandom | head -c 24)"  | sed -e '/<style[^>]*>/,/<\/style>/d' -e 's/<[^>]*>//g' -e 's/{[^}]*}//g' -e 's/[[:space:]]//g' | tr -d '\n\r')
    TESTURL3=$(curl --max-filesize 5000 -s "$URL/$(tr -dc 'a-z0-9' < /dev/urandom | head -c 24)"  | sed -e '/<style[^>]*>/,/<\/style>/d' -e 's/<[^>]*>//g' -e 's/{[^}]*}//g' -e 's/[[:space:]]//g' | tr -d '\n\r')

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
    echo $TESTURL1
    echo $TESTURL2
    echo $TESTURL3
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


    while IFS= read -r DATALINE; do
        #echo "${DATALINE0:20}"
        TITLESTR="${DATALINE%%>*}"
        DATALINE="${DATALINE#*>}"
        #echo $DATALINE
        DATAAVE=0
        for (( i=0; i<${#smallest}; i++ )); do
            KEYCHAR="${greatest:$i:1}"
            TESTCHAR="${DATALINE:$i:1}"
            #echo "$KEYCHAR ::: $TESTCHAR"
            if [[ "$TESTCHAR" != "$KEYCHAR" ]]; then
                ((DATAAVE++))
            fi

        done
        LENGTH="${#smallest}"
        #echo $LENGTH
        #echo $DATAAVE
        if [ "$LENGTH" -gt 0 ]; then
            DATAAVE=$(awk -v sum="$DATAAVE" -v len="$LENGTH" \
                'BEGIN { printf "%.2f\n", sum / len }')
        else
            echo "LENGTH is zero"
        fi
        if awk "BEGIN {exit !($DATAAVE > 0.5)}"; then
            echo "$TITLESTR : UNIQUE VALUE : $DATAAVE" >> out.txt
        fi
    done < UNIQUE_TEMP.txt
fi






#rm -rf TEMP_URLS.txt
echo "end of program"
exit 0