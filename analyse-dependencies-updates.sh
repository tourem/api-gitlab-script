#!/bin/bash


red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`

###########################################################################################
###########################################################################################
##                                                                                       ##
##  #######  ##   ##  ###     ##   ###### ########  ##   #######   ###     ##   ######   ##
##  ##       ##   ##  ####    ##  ##         ##     ##  ##     ##  ####    ##  ##    ##  ##
##  ##       ##   ##  ## ##   ##  ##         ##     ##  ##     ##  ## ##   ##   ##       ##
##  #####    ##   ##  ##  ##  ##  ##         ##     ##  ##     ##  ##  ##  ##     ##     ##
##  ##       ##   ##  ##   ## ##  ##         ##     ##  ##     ##  ##   ## ##       ##   ##
##  ##       ##   ##  ##    ####  ##         ##     ##  ##     ##  ##    ####  ##    ##  ##
##  ##        #####   ##     ###   ######    ##     ##   #######   ##     ###   ######   ##
##                                                                                       ##
###########################################################################################
###########################################################################################

function affiche(){
# $1: type de message ERROR, INFO, OK, SUCCESS, ...
# $2: Message

  local VERT="\\033[1;32m"
  local NORMAL="\\033[0;39m"
  local ROUGE="\\033[1;31m"
  local ROSE="\\033[1;35m"
  local BLEU="\\033[1;34m"
  local BLANC="\\033[0;02m"
  local BLANCLAIR="\\033[1;08m"
  local JAUNE="\\033[1;33m"
  local JAUNECLAIR="\\033[0;33m"
  local CYAN="\\033[1;36m"

  case "$1" in
    "ERROR")
      echo -ne "[${ROUGE}ERROR  ${NORMAL}] - " && echo "${2}"
    ;;
    "WARNING")
      echo -ne "[${JAUNE}WARNING${NORMAL}] - " && echo "${2}"
    ;;
    "SKIP")
      echo -ne "[${JAUNECLAIR}SKIP   ${NORMAL}] - " && echo "${2}"
    ;;
    "DEBUG")
      [ ${debug} ] && echo -ne "[${ROSE}DEBUG  ${NORMAL}] - " && echo "${2}"
    ;;
    "INFO")
      echo -ne "[${BLEU}INFO   ${NORMAL}] - " && echo "${2}"
    ;;
    "OK")
      echo -ne "[${VERT}OK     ${NORMAL}] - " && echo "${2}"
    ;;
    "SUCCESS")
      echo -ne "[${CYAN}SUCCESS${NORMAL}] - " && echo "${2}"
    ;;
    *)
      echo -e "${2}"
    ;;
  esac
}
RESULT_DIR=/c/Users/mtoure/audit-program
#PROJECTS=("projet1" "project2" "project-api")

nb_oc=0


saveDependenciesUpdates () {
  affiche "INFO" "clone projet $1 for $2" 
  git clone $1
  cd $2
  if [ -f "$POM" ]
  then
	mvn -e org.codehaus.mojo:versions-maven-plugin:2.11.0:display-dependency-updates > ${RESULT_DIR}/$2.txt
  fi
  
  cd ..
  rm -rf $2
}


POM="pom.xml"
tmp_dir=$(mktemp -d -t ci-$(date +%Y-%m-%d-%H-%M-%S)-XXXXXXXXXX)

echo $tmp_dir

TOKEN=token
GROUP_NAME=larbotech


cd $tmp_dir

if [ -z "$PROJECTS" ]; 
then 
	GROUP_ID=$(curl -k --header "Private-Token: $TOKEN" -X GET https://gitlab-larbotech.gao/api/v4/groups?search=${GROUP_NAME} | jq -r -c --arg GROUP_NAME "$GROUP_NAME" '[ .[] | select( .name==$GROUP_NAME)] | .[].id')
	
	echo "goupe id : $GROUP_ID"
	PROJECTS=$(curl -k --header "Private-Token: $TOKEN" -X GET https://gitlab-larbotech.gao/api/v4/groups/${GROUP_ID}/projects | jq -M '[.[] | {http_url_to_repo,name}]');
	
	 count=`echo $PROJECTS | jq '. | length'`

	for ((i=0; i<$count; i++)); do
		project=`echo $PROJECTS | jq -r '.['$i'].name'`
		http_url_to_repo=`echo $PROJECTS | jq -r '.['$i'].http_url_to_repo'`
		saveDependenciesUpdates "${http_url_to_repo}" "${project}"
	done
else
  for project in ${PROJECTS[@]}; do
  
	  http_url_to_repo=$(curl -k --header "Private-Token: $TOKEN" -X GET https://gitlab-larbotech.gao/api/v4/projects?search=$project | jq -r -c --arg project "$project" '[ .[] | select( .name==$project)] | .[].http_url_to_repo')
	 
	  saveDependenciesUpdates "${http_url_to_repo}" "${project}"
  done
fi





echo "####################### nombre total de la lib $ARTIFACTTD : $nb_oc ################################## " 

echo "Deleted temp working directory $tmp_dir"
rm -rf $tmp_dir
