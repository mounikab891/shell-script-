###fetch the list of servicename , cpu , memory , desiredcount , running count , ######

#!/bin/bash
profile=*****
region=*****
#profile=****
cluster=*****
start_time=$(date -u -v-2w +%Y-%m-%d)
end_time=$(date -u +%Y-%m-%d)

list=$(aws ecs list-services --cluster $cluster  --region $region --profile $profile --query "serviceArns" | sed 's:.*/::' | tr -d "[]\","| sed '/^[[:space:]]*$/d')
echo "----------------------------------------------"
echo services: $list
echo "----------------------------------------------"
echo "No of services: $(echo $list |wc -w)"
echo "----------------------------------------------"
c=0

echo "services,cpu,memory,desiredCount,runningCount,RunningTaskDefination,CPUMaxUtilization,MemoryMaxUtilization" > serviceinfo.csv

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

echo "---------------" > CPUMaxUtilization
echo "CPUMaxUtilization" >> CPUMaxUtilization
echo "---------------" >> CPUMaxUtilization

echo "---------------" > MemoryMaxUtilization
echo "MemoryMaxUtilization" >> MemoryMaxUtilization
echo "---------------" >> MemoryMaxUtilization

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
aws ecs describe-task-definition --task-definition $i  --region $region --profile $profile| jq -r '.taskDefinition.taskDefinitionArn' | cut -d "/" -f2 | sed "s/$/,/g"  >> s-RunningTaskDefination
 echo "---------------" >> RunningTaskDefination

cpumax_util=$(aws cloudwatch get-metric-statistics --profile $profile --namespace "AWS/ECS" --metric-name "CPUUtilization" --start-time "$start_time" --end-time "$end_time" --period 3600 --statistics Maximum --dimensions "Name=ClusterName,Value=$cluster" "Name=ServiceName,Value=$service"  --query 'max(Datapoints[].Maximum)' --output text)
    printf "%.1f\n" "$cpumax_util" >> CPUMaxUtilization
cpumax_util=$(aws cloudwatch get-metric-statistics --profile $profile --namespace "AWS/ECS" --metric-name "CPUUtilization" --start-time "$start_time" --end-time "$end_time" --period 3600 --statistics Maximum --dimensions "Name=ClusterName,Value=$cluster" "Name=ServiceName,Value=$service"  --query 'max(Datapoints[].Maximum)' --output text)
    printf "%.1f\n" "$cpumax_util" | sed "s/$/,/g" >> s-CPUMaxUtilization
echo "---------------" >> CPUMaxUtilization

cpumax_util=$(aws cloudwatch get-metric-statistics --profile $profile --namespace "AWS/ECS" --metric-name "MemoryUtilization" --start-time "$start_time" --end-time "$end_time" --period 3600 --statistics Maximum --dimensions "Name=ClusterName,Value=$cluster" "Name=ServiceName,Value=$service"  --query 'max(Datapoints[].Maximum)' --output text)
    printf "%.1f\n" "$cpumax_util" >> MemoryMaxUtilization
cpumax_util=$(aws cloudwatch get-metric-statistics --profile $profile --namespace "AWS/ECS" --metric-name "MemoryUtilization" --start-time "$start_time" --end-time "$end_time" --period 3600 --statistics Maximum --dimensions "Name=ClusterName,Value=$cluster" "Name=ServiceName,Value=$service"  --query 'max(Datapoints[].Maximum)' --output text)
    printf "%.1f\n" "$cpumax_util" >> s-MemoryMaxUtilization
echo "---------------" >> MemoryMaxUtilization

#aws ecs describe-task-definition --task-definition $i --region $region --profile $profile | jq -r '.taskDefinition.containerDefinitions[].logConfiguration.options."awslogs-group"'| cut -d "/" -f3 >> service
#aws ecs describe-task-definition --task-definition $i --region $region --profile $profile | jq -r '.taskDefinition| .family + "," + .cpu + "," + .memory' >> test.csv
((c += 1 ))
done
done
#pr -mts' ' service cpu memory | column -t > sri.csv

pr -mts' ' s-service s-cpu s-memory  s-desiredCount s-runningCount s-RunningTaskDefination s-CPUMaxUtilization s-MemoryMaxUtilization | column -t >> serviceinfo.csv
pr -mts' ' service cpu memory desiredCount runningCount RunningTaskDefination CPUMaxUtilization MemoryMaxUtilization | column -t
rm -f service cpu memory desiredCount runningCount RunningTaskDefination CPUMaxUtilization MemoryMaxUtilization s-service s-cpu s-memory s-desiredCount s-runningCount s-RunningTaskDefination s-CPUMaxUtilization s-MemoryMaxUtilization
