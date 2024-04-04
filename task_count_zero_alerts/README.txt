AWS ECS Task Count Zero Alerts Script

This script automates the creation of CloudWatch alarms for monitoring the task count of AWS ECS services. The aim of these alarms is to notify when the task count of an ECS service reaches zero.

Usage

1. Clone the Repository: Clone this repository to your local machine.

git clone <repository_url>

2. Install Dependencies: Ensure you have the AWS CLI installed and configured with appropriate credentials.

3. Configure Script: Edit the script (task_count_zero_alerts.sh) to set the necessary parameters like profiles, clusters, region, and SNS_ARN. Ensure that the profiles array contains the names of the AWS CLI profiles you want to use, and the clusters array contains the names of the ECS clusters you want to monitor.

4. Run the Script: Execute the script to create the CloudWatch alarms.

./task_count_zero_alerts.sh

5. Verify Alarms: Check the AWS Management Console or use the AWS CLI to verify that the alarms have been created successfully.

Parameters

- profiles: An array containing the names of AWS CLI profiles to use.
- clusters: An array containing the names of ECS clusters to monitor.
- region: The AWS region where the ECS clusters are located.
- SNS_ARN: The ARN of the SNS topic where alarm notifications will be sent.

Aim of the Alarms

- Task Count Zero: The alarm for Task Count Zero notifies when the number of running tasks in an ECS service reaches zero.

Script Details

The script iterates through each cluster specified in the clusters array for each AWS CLI profile specified in the profiles array. It fetches the list of service names in each cluster and creates CloudWatch alarms for Task Count Zero for each service. Alarms are only created if the desired task count for the service is greater than 0.

