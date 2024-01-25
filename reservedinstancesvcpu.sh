#!/bin/bash

# Get the reserved instances information
reserved_instances_info=$(aws ec2 describe-reserved-instances \
    --filters "Name=product-description,Values=Linux/UNIX" "Name=state,Values=active" \
    --region ap-south-1 \
    --query "ReservedInstances[*].[InstanceType,InstanceCount]" \
    --output json)

# Process each reserved instance and get unique instance types
echo "Reserved Instances Information:"
echo "InstanceType,InstanceCount,vcpu"
echo "$reserved_instances_info" | jq -r '.[] | @tsv' | awk -F'\t' '{instance_count[$1] += $2} END {for (instance in instance_count) printf "%s,%d\n", instance, instance_count[instance]}' > out.txt
column -t -s, out.txt
echo

# Get vCPU information for each unique instance type
echo "vCPU Information for Each Instance Type:"
echo "InstanceType,InstanceCount,TotalVCPUs"
tail -n +2 out.txt | while IFS=',' read -r instance_type instance_count; do
    vcpu_count=$(aws ec2 describe-instance-types \
        --instance-types "$instance_type" \
        --query "InstanceTypes[0].VCpuInfo.DefaultVCpus" \
        --output json | jq -r '.')
    
    if [ -n "$vcpu_count" ]; then
        total_vcpus=$((instance_count * vcpu_count))
        echo "$instance_type,$instance_count,$total_vcpus"
    else
        echo "Error fetching vCPU information for $instance_type."
    fi
done

# Remove the temporary file
rm out.txt
