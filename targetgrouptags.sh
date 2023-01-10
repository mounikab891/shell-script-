#!/bin/bash
profile=*****
#get list of loadbalancer ARN list
lbarnlist=$(aws elbv2 describe-load-balancers --profile $profile --query 'LoadBalancers[?(Type == `application`)].LoadBalancerArn | []' | tr -d "[]\","| sed '/^[[:space:]]*$/d')
for LARN in $lbarnlist
do
#get the list of particular loadbalancer attached target groups 
tgarnlist=$(aws elbv2 describe-target-groups --profile $profile --load-balancer-arn arn:aws:elasticloadbalancing:ap-south-1:247653494814:loadbalancer/net/stg-apm-lb/c8bceedd0dac42c5 --query 'TargetGroups[*].TargetGroupArn' | tr -d "[]\","| sed '/^[[:space:]]*$/d')

for i in $tgarnlist
do 
#adding the tags to all targetgroups
aws elbv2 add-tags --profile $profile --resource-arns $i --tags "Key=Environment,Value=Production"

    done
    done

