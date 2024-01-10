#!/bin/bash

# Define the profiles
profiles=("XXX" "XXX" "XXX")

# Calculate start time (3 months ago) and end time (current time)
start_time=$(date -u -v-3m '+%Y-%m-%dT%H:%M:%SZ')
end_time=$(date -u '+%Y-%m-%dT%H:%M:%SZ')

# Iterate through profiles
for profile in "${profiles[@]}"; do
    echo "Checking Lambda functions for profile: $profile"

    # Get a list of Lambda functions
    functions=$(aws lambda list-functions --profile $profile --output json | jq -r '.Functions[].FunctionName')

    # Iterate through functions
    for function in $functions; do
        # Get invocation details using CloudWatch Metrics
        invocations=$(aws cloudwatch get-metric-data \
          --profile $profile \
          --metric-data-queries '[
            {
              "Id": "m1",
              "MetricStat": {
                "Metric": {
                  "Namespace": "AWS/Lambda",
                  "MetricName": "Invocations",
                  "Dimensions": [
                    {
                      "Name": "FunctionName",
                      "Value": "'$function'"
                    }
                  ]
                },
                "Period": 86400,
                "Stat": "Sum"
              },
              "ReturnData": true
            }
          ]' \
          --start-time $start_time \
          --end-time $end_time \
          --output json | jq -r '.MetricDataResults[0].Values | @csv' | tr ',' '\n')

        # Check if the function hasn't been invoked in the last 3 months
        if [ -z "$invocations" ]; then
            echo "$function"
        fi
    done
done
