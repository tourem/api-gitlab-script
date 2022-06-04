#!/bin/bash

RESULT_DIR=/c/Users/mtoure/audit-program
PROJECTS=("projet1" "projet2" "projet3")

nb_oc=0

cloneAndSearchBasePackage () {
  echo "======================= nom du projet $1  === repository : $2"
  git clone $1
  cd $2
  if [ -f "$POM" ]
  then
	NB=$(cat $POM | grep $ARTIFACTTD | wc -l)
	if [ $NB -gt 0 ]
	then
		nb_oc=$((nb_oc+1))
		
		#awk '!x[$0]++' file : supprime les lignes dupliquées du file ..... grep -R 'org.gitlab4j.api' src/main/java/ | awk '!x[$0]++'
		grep -R ${BASE_PACKAGE} src/main/java/ > ${RESULT_DIR}/$2.txt
	fi 
  
  fi

 
  cd ..
  rm -rf $2
}


BASE_PACKAGE="com.larbotech.commons"
ARTIFACTTD="project-commons"
POM="pom.xml"
tmp_dir=$(mktemp -d -t ci-$(date +%Y-%m-%d-%H-%M-%S)-XXXXXXXXXX)

echo $tmp_dir

TOKEN=tokennnnnnnnn
GROUP_NAME=intma


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
		cloneAndSearchBasePackage "${http_url_to_repo}" "${project}"
	done

fi
for project in ${PROJECTS[@]}; do
  
  http_url_to_repo=$(curl -k --header "Private-Token: $TOKEN" -X GET https://gitlab-larbotech.gao/api/v4/projects?search=$project | jq -r -c --arg project "$project" '[ .[] | select( .name==$project)] | .[].http_url_to_repo')
  
   echo "ddddddddddddddddddddddddddddddd  du projet $project dddddddddddddddddddddddddddddddddddddddddddd  repository : ${http_url_to_repo} "
  cloneAndSearchBasePackage "${http_url_to_repo}" "${project}"
 
done




echo "####################### nombre total de la lib $ARTIFACTTD : $nb_oc ################################## " 

echo "Deleted temp working directory $tmp_dir"
rm -rf $tmp_dir
