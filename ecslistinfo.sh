###fetch the list of servicename , cpu , memory , desiredcount , running count , ######

#!/bin/bash
profile=default
region=****
profile=****
cluster=*****

list=$(aws ecs list-services --cluster $cluster  --region $region --profile $profile --query "serviceArns" | sed 's:.*/::' | tr -d "[]\","| sed '/^[[:space:]]*$/d')
echo "----------------------------------------------"
echo services: $list
echo "----------------------------------------------"
echo "No of services: $(echo $list |wc -w)"
echo "----------------------------------------------"
c=0

echo "services,cpu,memory,desiredCount,runningCount,RunningTaskDefination" > serviceinfo.csv

echo "---------------" > service
echo "service" >> service
echo "---------------" >> service

echo "---------------" >> cpu
echo "cpu" >> cpu
echo "---------------" >> cpu

echo "---------------" >> memory
echo "memory" >> memory
echo "---------------" >> memory

echo "---------------" >>desiredCount
echo "desiredCount" >> desiredCount
echo "----------------" >> desiredCount

echo "---------------" >> runningCount
echo "runningCount" >> runningCount
echo "---------------" >> runningCount

echo "---------------" >> RunningTaskDefination
echo "RunningTaskDefination" >> RunningTaskDefination
echo "---------------" >> RunningTaskDefination

#list="bifrost-prod mb-nodevacciantionmaster-prod"
for service in $list
do
#cluster=retool-prod-ecs
#echo $list >> service
TD=$(aws ecs describe-services --services $service --cluster $cluster --region $region --profile $profile | jq -r '.[] | .[] | .taskDefinition'| cut -d "/" -f2 | tr -d ",\"[]{}" | sed '/^[[:space:]]*$/d' | cut -d ":" -f1 | sort -u)
echo "$TD"

for i in $TD 
do
echo "Please Wait, We Are Working on It...!: $c"
aws ecs describe-services --services $service  --cluster $cluster --region $region --profile $profile | jq -r '.services[].serviceArn' | cut -d "/" -f3 |  >> service
aws ecs describe-services --services $service  --cluster $cluster --region $region --profile $profile | jq -r '.services[].serviceArn'| cut -d "/" -f3 |  sed "s/$/,/g" >>s-service
echo "---------------" >> service

aws ecs describe-task-definition --task-definition $i  --region $region --profile $profile | jq -r '.taskDefinition.containerDefinitions[].cpu, .taskDefinition.cpu' | grep -v null | grep -vw 0  >> cpu
aws ecs describe-task-definition --task-definition $i  --region $region --profile $profile | jq -r '.taskDefinition.containerDefinitions[].cpu, .taskDefinition.cpu' | grep -v null | grep -vw 0 | sed "s/$/,/g" >>s-cpu

 echo "---------------" >> cpu

aws ecs describe-task-definition --task-definition $i  --region $region --profile $profile | jq -r '.taskDefinition.containerDefinitions[].memory, .taskDefinition.memory' | grep -v null | grep -vw 0  >> memory
aws ecs describe-task-definition --task-definition $i  --region $region --profile $profile | jq -r '.taskDefinition.containerDefinitions[].memory, .taskDefinition.memory' | grep -v null |  grep -vw 0 | sed "s/$/,/g"  >> s-memory

 echo "---------------" >> memory

aws ecs describe-services --services $service  --cluster $cluster --region $region --profile $profile | jq -r '.services[].desiredCount'  >> desiredCount
aws ecs describe-services --services $service  --cluster $cluster --region $region --profile $profile | jq -r '.services[].desiredCount'| sed "s/$/,/g" >>s-desiredCount
echo "---------------" >> desiredCount

aws ecs describe-services --services $service  --cluster $cluster --region $region --profile $profile | jq -r '.services[].runningCount'  >> runningCount
aws ecs describe-services --services $service  --cluster $cluster --region $region --profile $profile | jq -r '.services[].runningCount' | sed "s/$/,/g" >> s-runningCount
echo "---------------" >> runningCount

aws ecs describe-task-definition --task-definition $i  --region $region --profile $profile | jq -r '.taskDefinition.taskDefinitionArn' | cut -d "/" -f2   >> RunningTaskDefination
aws ecs describe-task-definition --task-definition $i  --region $region --profile $profile| jq -r '.taskDefinition.taskDefinitionArn' | cut -d "/" -f2   >> s-RunningTaskDefination
 echo "---------------" >> RunningTaskDefination



#aws ecs describe-task-definition --task-definition $i --region $region --profile $profile | jq -r '.taskDefinition.containerDefinitions[].logConfiguration.options."awslogs-group"'| cut -d "/" -f3 >> service
#aws ecs describe-task-definition --task-definition $i --region $region --profile $profile | jq -r '.taskDefinition| .family + "," + .cpu + "," + .memory' >> test.csv
((c += 1 ))
done
done
#pr -mts' ' service cpu memory | column -t > sri.csv

pr -mts' ' s-service s-cpu s-memory  s-desiredCount s-runningCount s-RunningTaskDefination | column -t >> serviceinfo.csv
pr -mts' ' service cpu memory desiredCount runningCount RunningTaskDefination | column -t
rm -f service cpu memory desiredCount runningCount RunningTaskDefination s-service s-cpu s-memory s-desiredCount s-runningCount s-RunningTaskDefination
