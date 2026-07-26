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
echo "" > out.txt
touch TEMP_URLS.txt
echo "" > TEMP_URLS.txt



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
        echo "url = $URL" > TEMP_URLS.txt
        if [[ "$PARALLEL" = 0 ]]; then
            while IFS= read -r LINE; do
                echo "url = $URL/$LINE" >> TEMP_URLS.txt
            done < "$DICTIONARY_VAL"
        else
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
         if curl -s  "${1}" | grep -iPo '(?<=<title>).*?(?=</title>)'; then
            echo "${1}" >> out.txt
        fi
    }
    curler_U(){
        curl -s  "${1}" | sed -e 's/<[^>]*>//g' -e 's/{[^}]*}//g' >> UNIQUE_TEMP.txt
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
            title=$(curl -Ls "$url" | grep -oP '(?<=<title>).*?(?=</title>)')
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
TESTSTR1=$(tr -dc 'a-z0-9' < /dev/urandom | head -c 24)
TESTSTR2=$(tr -dc 'a-z0-9' < /dev/urandom | head -c 24)
TESTSTR3=$(tr -dc 'a-z0-9' < /dev/urandom | head -c 24)
TESTSTR4=$(tr -dc 'a-z0-9' < /dev/urandom | head -c 24)
echo "$TESTSTR1"
echo "$TESTSTR2"
echo "$TESTSTR3"
echo "$TESTSTR4"
fi


rm -rf TEMP_URLS.txt
echo "end of program"
exit 0