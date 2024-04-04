clusters=("xxxx" "xxxx" "xxxx" "xxx")
profile="proilename"
region="region"
SNS_ARN="arn:aws:sns:XXXX"
accountid="accountid"

for cluster in "${clusters[@]}"; do
  service_names=$(aws ecs list-services --cluster "$cluster" --profile "$profile" --query "serviceArns" | sed 's:.*/::' | tr -d "[]\"," | sed '/^[[:space:]]*$/d')

  for service_name in $service_names; do
    max_tasks=$(aws application-autoscaling describe-scalable-targets --profile "$profile" --service-namespace ecs --resource-id "service/$cluster/$service_name" --query "ScalableTargets[?ResourceId == 'service/$cluster/$service_name'].MaxCapacity" --output text)

    # Skip creating alarms if max_tasks is 0
    if [ $max_tasks -eq 0 ]; then
      echo "Skipping creation of alarms for service $service_name in cluster $cluster as maximum tasks count is 0."
      continue
    fi

    max_tasks_alarm_name="$cluster/$service_name/Using-MaxRunningTaskCount"
    cpu_utilization_alarm_name="$cluster/$service_name/High-CPU-Utilization"

    max_tasks_arn=$(aws cloudwatch describe-alarms --alarm-names "$max_tasks_alarm_name" --profile "$profile" --query 'MetricAlarms[*].AlarmArn' --output text)
    cpu_utilization_arn=$(aws cloudwatch describe-alarms --alarm-names "$cpu_utilization_alarm_name" --profile "$profile" --query 'MetricAlarms[*].AlarmArn' --output text)

    echo "Maximum tasks for service $service_name in cluster $cluster with autoscaling: $max_tasks"

 

    # Create the CloudWatch alarm for CPU Utilization
    aws cloudwatch put-metric-alarm \
      --profile "$profile" \
      --alarm-name "$cpu_utilization_alarm_name" \
      --alarm-description "Alarm for High CPU Utilization in ECS service $service_name" \
      --metric-name "CPUUtilization" \
      --namespace "AWS/ECS" \
      --statistic Maximum \
      --period 300 \
      --threshold 80 \
      --comparison-operator GreaterThanOrEqualToThreshold \
      --dimensions Name=ClusterName,Value="$cluster" Name=ServiceName,Value="$service_name" \
      --evaluation-periods 2
         # Create the CloudWatch alarm for RunningTaskCount
    aws cloudwatch put-metric-alarm \
      --profile "$profile" \
      --alarm-name "$max_tasks_alarm_name" \
      --alarm-description "Alarm for RunningTaskCount in ECS service $service_name" \
      --metric-name "RunningTaskCount" \
      --namespace "ECS/ContainerInsights" \
      --statistic Maximum \
      --period 300 \
      --threshold $max_tasks \
      --comparison-operator GreaterThanOrEqualToThreshold \
      --dimensions Name=ClusterName,Value="$cluster" Name=ServiceName,Value="$service_name" \
      --evaluation-periods 2

    # Wait for 20 seconds to ensure alarms are propagated
    sleep 10
    # Construct ARNs without extra prefix
    max_tasks_arn="arn:aws:cloudwatch:ap-south-1:$accountid:alarm:$cluster/$service_name/Using-MaxRunningTaskCount"
cpu_utilization_arn="arn:aws:cloudwatch:ap-south-1:$accountid:alarm:$cluster/$service_name/High-CPU-Utilization"

    #arn:aws:cloudwatch:ap-south-1:247653494814:alarm:$cluster/$service_name/High-CPU-Utilization
    #max_tasks_arn=${max_tasks_arn##*:alarm:}
    echo $max_tasks_arn
    cpu_utilization_arn=${cpu_utilization_arn##*:alarm:}
    echo $cpu_utilization_arn

    # Create the composite alarm
    composite_alarm_name="$cluster/$service_name/composite_alaram(max cpu and taskcount)"

    # Create a composite alarm combining both CPU Utilization and Running Task Count
    aws cloudwatch put-composite-alarm \
      --profile "$profile" \
      --alarm-name "$composite_alarm_name" \
      --alarm-description "Composite Alarm for CPU Utilization and Running Task Count in ECS service $service_name" \
      --actions-enabled \
      --alarm-actions "$SNS_ARN" \
      --alarm-rule "ALARM($max_tasks_arn) AND ALARM($cpu_utilization_arn)"
  done
done

