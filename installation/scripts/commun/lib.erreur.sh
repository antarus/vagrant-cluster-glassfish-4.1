lib_name='gestErreur'
lib_version=20150810

stderr_log="/vagrant/installation/scripts/stderr.log"

#
# Pour être reférencé une seule fois
#
###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~##

if test "${g_libs[$lib_name]+_}"; then
    return 0
else
    if test ${#g_libs[@]} == 0; then
        declare -A g_libs
    fi
    g_libs[$lib_name]=$lib_version
fi




# Gestion des erreurs

#source $BASE_SCRIPT_PROVISION/lib.trap.sh

#
# MAIN CODE:
#
###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~##

set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   ## set -u : exit the script if you try to use an uninitialised variable
set -o errexit   ## set -e : exit the script if any statement returns a non-true return value

exec 2>"$stderr_log"

## code couleur
RED='\033[0;31m'
ORANGE='\033[0;33m'
BLANC='\033[1;37m'
PAS_COULEUR='\033[0m'


function erreur ()
{
    local error_code="$?"

    test $error_code == 0 && return;

    #
    # VARIABLES:
    # ------------------------------------------------------------------
    #
    local i=0
    local regex=''
    local mem=''

    local error_FICHIER=''
    local error_lineno=''
    local error_message='Inconnu'

    local lineno=''


    #
    # ENTETE:
    # ------------------------------------------------------------------
    #
    # Colorize le terminal si c'est possible
    test -t 1 && tput setf 6                                 ## red
    test -f "$stderr_log"
    echo -e "\n${RED}****************************"
    echo -e "${RED}****************************"
    echo -e "${RED}***     (!) ERREUR       ***"
    echo -e "${RED}****************************"
    echo -e "${RED}****************************\n "


    #
    # Récupere la dernière erreur
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

    #
    # Lit le dernier fichier
    # ------------------------------------------------------------------
    #

    if test -f "$stderr_log"
        then
            stderr=$( tail -n 1 "$stderr_log" )
                #rm "$stderr_log"
    fi
    #
    # Managing the line to extract information:
    # ------------------------------------------------------------------
    #

    if test -n "$stderr"
        then
            # Exploding stderr on :
            mem="$IFS"
            local shrunk_stderr=$( echo "$stderr" | sed 's/\: /\:/g' )
            IFS=':'
            local stderr_parts=( $shrunk_stderr )
            IFS="$mem"

            # Storing information on the error
            error_FICHIER="${stderr_parts[0]}"
            #if test -n "$${stderr_parts[1]}"
            #then
              error_lineno="${stderr_parts[1]}"
           # fi
            error_message=""
            for (( i = 3; i <= ${#stderr_parts[@]}; i++ ))
                do
                    error_message="$error_message "${stderr_parts[$i-1]}": "
            done

            # Removing last ':' (colon character)
            error_message="${error_message%:*}"

            # Trim
            error_message="$( echo "$error_message" | sed -e 's/^[ \t]*//' | sed -e 's/[ \t]*$//' )"
    fi
    #
    # GETTING BACKTRACE:
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

    _backtrace=$( backtrace 2 )


    #
    # MANAGING THE OUTPUT:
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

    local lineno=""
    regex='^([a-z]{1,}) ([0-9]{1,})$'

    if [[ $error_lineno =~ $regex ]]

        # The error line was found on the log
        # (e.g. type 'ff' without quotes wherever)
        # --------------------------------------------------------------
        then
            local LIGNE="${BASH_REMATCH[1]}"
            lineno="${BASH_REMATCH[2]}"

            echo -e "${ORANGE}FICHIER:${PAS_COULEUR}\t\t${error_FICHIER}"
            echo -e "${ORANGE}${LIGNE^^}:${PAS_COULEUR}\t\t${lineno}\n"

            echo -e "${ORANGE}CODE ERREUR:${PAS_COULEUR}\t${error_code}"
            test -t 1 && tput setf 6                                    ## white yellow
            echo -e "${ORANGE}MESSAGE D'ERREUR:${PAS_COULEUR}\n$error_message"


        else
            regex="^${error_FICHIER}\$|^${error_FICHIER}\s+|\s+${error_FICHIER}\s+|\s+${error_FICHIER}\$"
            if [[ "$_backtrace" =~ $regex ]]

                # The FICHIER was found on the log but not the error line
                # (could not reproduce this case so far)
                # ------------------------------------------------------
                then
                    echo -e "${ORANGE}FICHIER:${PAS_COULEUR}\t\t$error_FICHIER"
                    echo -e "${ORANGE}LIGNE:${PAS_COULEUR}\t\tInconnue\n"

                    echo -e "${ORANGE}CODE ERREUR:${PAS_COULEUR}\t${error_code}"
                    test -t 1 && tput setf 6                            ## white yellow
                    echo -e "${ORANGE}MESSAGE D'ERREUR:${PAS_COULEUR}\n${stderr}"

                # Neither the error line nor the error FICHIER was found on the log
                # (e.g. type 'cp ffd fdf' without quotes wherever)
                # ------------------------------------------------------
                else
                    #
                    # The error FICHIER is the first on backtrace list:

                    # Exploding backtrace on newlines
                    mem=$IFS
                    IFS='
                    '
                    #
                    # Substring: I keep only the carriage return
                    # (others needed only for tabbing purpose)
                    IFS=${IFS:0:1}
                    local lines=( $_backtrace )

                    IFS=$mem

                    error_FICHIER=""

                    if test -n "${lines[1]}"
                        then
                            array=( ${lines[1]} )

                            for (( i=2; i<${#array[@]}; i++ ))
                                do
                                    error_FICHIER="$error_FICHIER ${array[$i]}"
                            done

                            # Trim
                            error_FICHIER="$( echo "$error_FICHIER" | sed -e 's/^[ \t]*//' | sed -e 's/[ \t]*$//' )"
                    fi

                    echo -e "${ORANGE}FICHIER:${PAS_COULEUR}\t\t$error_FICHIER"
                    echo -e "${ORANGE}LIGNE:${PAS_COULEUR}\t\tInconnue\n"

                    echo -e "${ORANGE}CODE ERREUR:${PAS_COULEUR}\t${error_code}"
                    test -t 1 && tput setf 6                            ## white yellow
                    if test -n "${stderr}"
                        then
                            echo -e "${ORANGE}MESSAGE D'ERREUR:${PAS_COULEUR}\n${stderr}"
                        else
                            echo -e "${ORANGE}MESSAGE D'ERREUR:${PAS_COULEUR}\n${error_message}"
                    fi
            fi
    fi

    #
    # ECRIT LE BACKTRACE:
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

    test -t 1 && tput setf 7                                            ## white bold
    echo -e "\n${BLANC}$_backtrace\n"

    #
    # SORTIE:
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

    test -t 1 && tput setf 4                                            ## red bold
    echo -e "${RED}Sortie!"
    echo -e "\n${RED}****************************"
    echo -e "${RED}****************************"
    echo -e "${RED}***  FIN MESSAGE ERREUR  ***"
    echo -e "${RED}****************************"
    echo -e "${RED}****************************\n ${PAS_COULEUR}"


    test -t 1 && tput sgr0 # Reset terminal

    exit "$error_code"
}
trap 'erreur' EXIT                                                  # ! ! ! TRAP EXIT ! ! !
trap exit ERR                                                           # ! ! ! TRAP ERR ! ! !






function backtrace
{
    local _start_from_=0

    local params=( "$@" )
    if (( "${#params[@]}" >= "1" ))
        then
            _start_from_="$1"
    fi

    local i=0
    local first=false
    while caller $i > /dev/null
    do
        if test -n "$_start_from_" && (( "$i" + 1   >= "$_start_from_" ))
            then
                if test "$first" == false
                    then
                        echo "BACKTRACE :"
                        first=true
                fi
                caller $i
        fi
        let "i=i+1"
    done
}

return 0
