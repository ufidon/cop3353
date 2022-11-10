#!/bin/bash 

# Game description:
# bidders bid on any of the three famous paintings:
# 1) Mona Lisa
# 2) The Starry Night
# 3) The birth of Venus
# each bidder can bid at most 3 times on each painting
# the bidding results are saved in a csv file

declare -A PAINTINGS=([mona]='Mona Lisa' [star]='The Starry Night' [venus]='The birth of Venus')
declare -a PAINTINGINDEXES=([1]=mona star venus)

# global variables
gBIDDERID=123456
gTOTALBIDS=6
gNUMBIDS=0
gBIDDERNAME=Trump
gPAINTINGINDEX=mona
gBIDDINGPRICEPRICE=32.453


# symbol names
MAXIMUMBIDS=3
DBFOLDER=./data
DBFILE="${DBFOLDER}/bidding.csv"
# data fields in bidding.csv
# bidderId,bidderName,painting index,bid

# functions
function showSplash()
{
    cat <<_SPLASH_
╔╦═╦╦╦╦╦╦╦╦════╦═╦═══════╦═╦═╦╦══╦╦╦╦════╗
║║░╩╬╬╝╠╝╠╬═╦═╗║╩╬═╦═╗╔═╗║░╠═╬╬═╦╣╠╬╬═╦═╗║
║║░░║║║║║║║║║║║║╦╣║║╠╝╠╝║║╔╬╝║║║╠╗╔╣║║║║║║
║╚══╩╩═╩═╩╩╩╬═║╚╝╚═╩╝..╚═╝╚╝╚═╩╩╩╝╚═╩╩╩╬═║║
╚═══════════╩═╩═══════════════════════╩═╩╝
_SPLASH_
}

function createDatabase()
{
    printf "\n"
    if [[ ! -d "$DBFOLDER" ]]; then
        printf "$DBFOLDER not exist, creating it...\n"
        mkdir "$DBFOLDER" &>/dev/null
        printf "$DBFOLDER created.\n"
    fi

    if [[ ! -f "${DBFILE}" ]]; then
        printf "${DBFILE} not exist, creating it...\n"
        touch "$DBFILE" &>/dev/null
        printf "$DBFILE created.\n"
    fi

    printf "Loading bidding data\n\n"
}

function showHelp()
{
    cat <<_help_
    Usage: use single letter command to play bidding
    h - help, show this command list
    q - quit
    b - bid for a painting
    s - show my bidding in descending order on bid
    l - show my place in all bidders for a painting
_help_
}


function quitGame()
{
	echo "Are you sure to quit this game? "
    local oldps3="$PS3"
    PS3="Type 1 for yes 2 for no: "
    local yorn='N'
	select yorn in Y N
	do
		if [ "$yorn" = "Y" ]; then 
            PS3="$oldps3"
            exit 0
        else
            PS3="$oldps3"
            break
        fi
	done	
}

function getBidderID()
{
    local reg6digits='^[0-9]{6}$'
    while : ; do
        read -p "Please enter your UNIQUE 6 digits bidder ID: " gBIDDERID
        if egrep "$reg6digits" <<<"$gBIDDERID"  &>/dev/null ; then
            break
        else
            echo "Your bidder ID ${gBIDDERID} is NOT 6 digits!"
        fi
    done
}

function getBidderName()
{
    # enter name
    while : ; do
        read -p "Please enter your name: " gBIDDERNAME
        if [[ ! "$gBIDDERNAME" =~ ^[a-zA-Z]+$ ]]; then
            echo "Your name can contain only letters!"
        else
            break
        fi
    done    
}


function selectPaiting()
{
    echo "Paitings for bidding:"
    local oldps3="$PS3"
    PS3="Please select a painting: "
    select s in "${PAINTINGS[@]}"; do
        case "$REPLY" in
            [1-3])
                gPAINTINGINDEX="${PAINTINGINDEXES[$REPLY]}"
                #gPAINTING="$s";
                gPAINTING="${PAINTINGS[$gPAINTINGINDEX]}"
                break
                ;;
            *) echo "You did't make your choice!" >&2
            ;;
        esac
    done
    PS3="$oldps3"
    #echo $gPAINTING
}

function getBidsOnPainting()
{
    local id="$1"
    local paintingindex="$2"  

    # get bidder's name if gTOTALBIDS>0
    gTOTALBIDS=$( egrep $id "$DBFILE" | wc -l )
    if [[ $gTOTALBIDS -gt 0 ]]; then
        gBIDDERNAME="$( egrep $gBIDDERID "$DBFILE"  | head -n 1 | cut -d ","  -f 2 )"
    fi    

    # number of bids on a given painting
    gNUMBIDS=$( egrep $id "$DBFILE" | egrep  "$paintingindex" | wc -l )
}

function getBid()
{
    # enter a bid
    while : ; do
        read -p "Please make your bid: " gBIDDINGPRICE
        if [[ ! "$gBIDDINGPRICE" =~ ^[1-9][0-9]*\.?[0-9]*$ ]]; then
            echo "Your bid can only be a number!"
        else
            break
        fi
    done 
}

function makeAbid()
{
    
    getBidderID # get bidder id
    selectPaiting # get painting index

    getBidsOnPainting "$gBIDDERID" "$gPAINTINGINDEX"

    # if new bidder
    if [[ gTOTALBIDS -eq 0 ]]; then
        getBidderName
    else
        echo "Hello $gBIDDERNAME, welcome back!"
    fi
    
    # if new bidding on the given painting
    if [[ $gNUMBIDS -eq 0 ]]; then 
        getBid
        ((gNUMBIDS++))
        echo -e "You bid it.\n\n"
        # save the result
        echo "$gBIDDERID,$gBIDDERNAME,$gPAINTINGINDEX,$gBIDDINGPRICE" >> "$DBFILE"
    elif [[ $gNUMBIDS -lt $MAXIMUMBIDS ]]; then # bid 1 or 2 times         
        echo "You've bid $gNUMBIDS times on ${PAINTINGS[$gPAINTINGINDEX]}, you still can bid $((3-gNUMBIDS)) times"
        getBid
        ((gNUMBIDS++))
        echo -e "You bid it.\n\n"
        # save the result
        echo "$gBIDDERID,$gBIDDERNAME,$gPAINTINGINDEX,$gBIDDINGPRICE" >> "$DBFILE"        
    else # bid 3 times
        echo "You've bid $gNUMBIDS times on ${PAINTINGS[$gPAINTINGINDEX]}, you can NOT bid it anymore."
    fi
}

function showBidding()
{
    getBidderID # get bidder id

    # get bidder's name if gTOTALBIDS>0
    gTOTALBIDS=$( egrep $gBIDDERID "$DBFILE" | wc -l )
    if [[ $gTOTALBIDS -eq 0 ]]; then
        echo "You did not bid on any paintings, please make your bid."  
    else
        gBIDDERNAME="$( egrep $gBIDDERID "$DBFILE"  | head -n 1 | cut -d ","  -f 2 )"

        echo "Hello $gBIDDERNAME, here are your bids in descending order:"

        echo "-----------------------------------------------------"
        printf "%-20s  %8s\n"  "Painting" "Bidding"
        echo "-----------------------------------------------------"
        # show all biddings
        egrep $gBIDDERID $DBFILE | awk 'BEGIN {FS=",";} 
        {printf("%s %s\n", $3,$4 )}
        ' | 
        sort -r -n -k 2 | 
        awk '
        BEGIN {
            # [mona]="Mona Lisa" [star]="The Starry Night" [venus]="The birth of Venus"
            paintings["mona"]="Mona Lisa"; paintings["star"]="The Starry Night"; paintings["venus"]="The birth of Venus"
            # print paintings["mona"],paintings["star"],paintings["venus"]
        }
        {
            # printf("%-20s %8.2f\n", $1,$2) 
            printf("%-20s %8.2f\n", paintings[$1],$2) 
        }
        '
        echo "-----------------------------------------------------"        
    fi    
}

function showPlace()
{
    getBidderID # get bidder id

    # get bidder's name if gTOTALBIDS>0
    gTOTALBIDS=$( egrep $gBIDDERID "$DBFILE" | wc -l )
    if [[ $gTOTALBIDS -eq 0 ]]; then
        echo "You did not bid on any paintings, please make your bid."  
    else
        local RED='\033[0;31m'
        local WHITE='\033[1;37m'
        local BLACK='\033[0;30m' # pay attention not to coincide with the background color

        gBIDDERNAME="$( egrep $gBIDDERID "$DBFILE"  | head -n 1 | cut -d ","  -f 2 )"

        echo -e "Hello ${RED} $gBIDDERNAME ${WHITE}, here are your bids highlighted:\n"

        echo "-----------------------------------------------------"
        printf "%-7s %-10s %-20s  %8s\n" "ID" "Name" "Painting" "Bidding"
        echo "-----------------------------------------------------"
        # show all biddings
        cat  $DBFILE | awk 'BEGIN {FS=",";} 
        {printf("%s %s %s %s\n", $1,$2,$3,$4 )}
        ' | 
        sort -r -n -k 4 | 
        awk -v id=$gBIDDERID -v red="$RED" -v black="$BLACK"  -v white="$WHITE" '
        BEGIN {
            paintings["mona"]="Mona Lisa"; paintings["star"]="The Starry Night"; paintings["venus"]="The birth of Venus"
        }
        {
            if($1 == id)
            {
                printf("%s%-7s %-10s %-20s %8.2f%s\n", red,$1,$2, paintings[$3],$4,white)
            }
            else
            {
                printf("%-7s %-10s %-20s %8.2f\n", $1,$2,paintings[$3],$4)
            }
        }
        '
        echo "-----------------------------------------------------"        
    fi 
}

# main logic
# show splash windows and help once at the beginning
showSplash
createDatabase
showHelp

# game main logic
while $true; do
    echo ""
    read -p 'Enter your command: ' cmd
    case "$cmd" in
        "h") # h - help, show this command list
        showHelp
        ;;
        "q") # q - quit the game
        quitGame
        ;;        
        "s") # s - show my bidding in descending order
        showBidding
        ;;
        "b") # b - bid for a painting
        makeAbid
        ;;
        "l") # l - show my place in all bidders for a painting
        showPlace
        ;;
        *) # unsupported commands
        echo "unsupported command"
        ;;
    esac
done
