#!/bin/bash

profiles=(
    "XXX"
    # Add more profiles if needed
)

clusters=(
    "XX"
    "XX"
    # Add more clusters if needed
)

region="XXX"
SNS_ARN="XXXX"

for profile in "${profiles[@]}"; do
    for cluster in "${clusters[@]}"; do
        # Get the list of service names in the cluster
        service_names=$(aws ecs list-services --cluster "$cluster" --profile "$profile" --query "serviceArns" | sed 's:.*/::' | tr -d "[]\"," | sed '/^[[:space:]]*$/d')

        for service_name in $service_names; do
            # Get the desired task count for the service
            desired_tasks=$(aws ecs describe-services --cluster "$cluster" --services "$service_name" --profile "$profile" --query "services[0].desiredCount")

            # Check if the desired task count is greater than 0
            if [ "$desired_tasks" -gt 0 ]; then
                # Create the CloudWatch alarm
                aws cloudwatch put-metric-alarm \
                    --profile "$profile" \
                    --alarm-name "$cluster/$service_name/Task-Count-Zero" \
                    --alarm-description "Alarm for RunningTaskCount in ECS service $service_name" \
                    --metric-name "RunningTaskCount" \
                    --namespace "ECS/ContainerInsights" \
                    --statistic Maximum \
                    --period 60 \
                    --threshold 0 \
                    --comparison-operator LessThanOrEqualToThreshold \
                    --dimensions Name=ClusterName,Value="$cluster" Name=ServiceName,Value="$service_name" \
                    --evaluation-periods 1 \
                    --alarm-actions "$SNS_ARN"
            else
                echo "Desired task count is 0 for service $service_name in cluster $cluster. Skipping alarm creation."
            fi
        done
    done
done
