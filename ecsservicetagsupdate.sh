#!/bin/bash

# Replace these with your actual AWS profile and region
AWS_PROFILE="XXXX"
AWS_REGION="XXXX"

#column names as ClusterName,ServiceName,Team,Environment,Owner,Purpose,BitbucketRepoName


# Replace this with the path to your CSV file
CSV_FILE="service-sample.csv"

# Read the CSV file and update tags for each row
tail -n +2 "$CSV_FILE" | awk -v aws_profile="$AWS_PROFILE" -v aws_region="$AWS_REGION" '
    function update_tags(cluster, service, team, env, owner, purpose, bitbucket_repo) {
        cmd = "aws ecs describe-services --profile " aws_profile " --region " aws_region \
              " --cluster " cluster " --services " service \
              " --query '\''services[0].serviceArn'\'' --output text"
        cmd | getline resource_arn
        close(cmd)

        if (resource_arn == "") {
            print "Service \x27" service "\x27 in cluster \x27" cluster "\x27 not found or no ARN available."
            return 1
        }

        print "Updating tags for Service: " service " in Cluster: " cluster
        print "Environment " env
        print "Owner " owner
        print "Purpose " purpose
        print "Team " team
        print "Bitbucketreponame " bitbucket_repo

        cmd = "aws ecs tag-resource --profile " aws_profile " --resource-arn " resource_arn \
              " --tags \"key=Team,value=" team "\" \"key=Environment,value=" env "\" \"key=Purpose,value=" purpose "\" \"key=Owner,value=" owner "\" \"key=Bitbucketreponame,value=" bitbucket_repo "\""
        ret = system(cmd)
        close(cmd)

        if (ret == 0) {
            print "Service: " service " tags updated successfully."
        } else {
            print "Failed to update tags for Service: " service " in Cluster: " cluster
        }
    }

    BEGIN { FS = OFS = "," }
    {
        for (i=1; i<=NF; i++) {
            gsub(/^[[:blank:]]+|[[:blank:]]+$/, "", $i)
        }
        update_tags($1, $2, $3, $4, $5, $6, $7)
    }
'

echo "Tags update process completed."
