
projects=("bmsa-services" "bmsa_service_admin" "bmsa_starter_security" "bmsa_caps_starter_web" "bmsa_library_jwt" "bmsa_library_linker" "bmsa-library-vip-health" "bmsa_service_authorization" "bmsa_service_cnt_visa" "bmsa_service_saa" "bmsa_service_sae" "indicator_scripts_saa" "bmsa_library_batch_computer_aut" "bmsa_service_admin" "bmsa-service-extract" "bmsa_service_health_checker" "bmsa_service_seek" "bmsa_heartbeat" "bmsa-internal-doc" "bmsa_tools" "bmsa_utils" "bmsa_service_guardian" "bmsa_service_proxy" "guardian_radius" "guardian_sso" "api_security_check" "bmsa-laas" "bmsa_batch_scheduler" "bmsa_jenkins_common_library")
nb_oc=0
for project in ${projects[@]}; do
  ID=$(curl -k --header "PRIVATE-TOKEN: token-compte-perso-gitlab" "https://gitlab-larbotech.gao/api/v4/projects?search=$project" | jq '.[0].id')
  POM=$(curl -k --header "PRIVATE-TOKEN: token-compte-perso-gitlab" "https://gitlab-larbotech.gao/api/v4/projects/$ID/repository/files//pom.xml?ref=develop" | jq -r .content);
  NB=$(echo $POM | base64 -d | grep $1 | wc -l)
  if [ $NB -gt 0 ]
  then
	nb_oc=$((nb_oc+1))
	echo "Identifiant du projet : $project ==> $ID -- Nombre de $1 dans le pom.xml : $NB" >> resultat-$1.txt 
	echo "================================ $nb_oc"
  fi 
done

echo "####################### nombre total de la lib $1 : $nb_oc ################################## " >> resultat-$1.txt 

#curl -k --header "PRIVATE-TOKEN: token-compte-perso-gitlab" "https://gitlab-larbotech.gao/api/v4/projects?search=bmsa_service_admin" | jq '.[0].id'


#curl -k --header "Private-Token: tonToken" -X PUT https://gitlab-larbotech.gao/api/v4/projects/2332?visibility=internal
# L'id 2332 est celui du projet : Settings => Genral => General project settings => Project ID
