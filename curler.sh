#SCRIPT FOR FINDING HTML PAGES
#MY CODE NO STEALING - FISCHEEY
echo $1

if [ $# -lt 3 ]; then 
        echo "You must enter a url, dictionary location, and depth level in the format ./script.sh https://www.example.com /path/to/dictionary  1"
        exit
fi

if [ ! -f "$2" ]; then
    echo "Error: Dictionary file not found at $2."
    echo "On Debian/Ubuntu, install it using: sudo apt install wamerican"
    exit 1
fi
DICT=$(cat $2)

PREFIX=$1
touch out.txt
echo "" > out.txt
#touch temp.txt
#echo "" > temp.txt
curler(){

        echo "${1}/${2}" 
        touch out.txt 
        if curl -s  "${1}/${2}" | grep -iPo '(?<=<title>).*?(?=</title>)'; then
                echo "${1}/${2}" >> out.txt
        fi
}
export -f curler
cat "$2" | xargs -P 64 -I {} bash -c 'curler "$1" "$2"' _  "$PREFIX" "{}"
#xargs -a "$2"  -P 4 -n 1  bash -c 'curler "$1"' _ 
#echo"$DICT" | xargs -n 1 -P 4 bash -c 'curler "$0"'

echo "printing"

