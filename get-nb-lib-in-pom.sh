

projects=("larbotech-services" "larbotech_service_admin" "larbotech_starter_security")

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
