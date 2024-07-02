#!/bin/bash

# List of AWS CLI profiles
profiles=("***" "****" "****")




# Function to update IMDSv2 for all Linux instances in a specific profile
update_imdsv2_for_profile() {
  local profile=$1
  echo "Processing profile: $profile"

  # Fetch all running instances for the specified profile
  echo "Fetching all running instances for profile $profile..."
  instance_ids=$(aws ec2 describe-instances \
    --profile $profile \
    --filters "Name=instance-state-name,Values=running" \
    --query "Reservations[*].Instances[?Platform!='windows'].InstanceId" \
    --output text)

  # Check if instance IDs were found
  if [ -z "$instance_ids" ]; then
    echo "No running Linux instances found for profile $profile."
    return
  fi

  # Loop through each instance ID and modify the instance metadata options
  for instance_id in $instance_ids; do
    echo "Updating instance metadata options for Linux instance ID: $instance_id in profile $profile"
    aws ec2 modify-instance-metadata-options \
      --profile $profile \
      --instance-id $instance_id \
      --http-tokens required \
      --http-endpoint enabled \
      --http-put-response-hop-limit 1
  done

  echo "All Linux instances for profile $profile have been updated to require IMDSv2."
}

# Loop through each profile and update IMDSv2 for all Linux instances
for profile in "${profiles[@]}"; do
  update_imdsv2_for_profile $profile
done

echo "All specified profiles have been processed."
