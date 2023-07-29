# AWS EKS Node Removal Script

This Bash script is designed to facilitate the removal of Kubernetes nodes from a cluster running on AWS EC2 instances. It automates the process of draining the pods, deleting the node from the cluster, and terminating the associated EC2 instance.


## Description

The script will prompt you to choose a Kubernetes node for removal by entering the index number. The list of nodes will be displayed with an "Exit" option at index 0.
It will then drain the node's pods, delete the node from the cluster, and terminate the associated EC2 instance.
If you enter "0" as the index number, the script will exit gracefully without removing any nodes.
The script will repeat the process and prompt you for another node to remove or exit.


## Prerequisites

- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [AWS CLI](https://aws.amazon.com/cli/)
- Properly configured AWS CLI with necessary permissions to describe and terminate EC2 instances.


## Usage

1. Clone the repository or download the script to your local machine.

2. Make the script executable:
   ```bash
   chmod +x eks_node_removal.sh
3. Run the script:
   ```bash
   ./eks_node_removal.sh


## Note
Be cautious when using this script, as removing a node will impact the availability and performance of the services running on that node.
The script assumes that the EC2 instances are part of an AWS Kubernetes cluster and that the kubectl and aws commands are available in your system's PATH.
Ensure that you have the necessary permissions and credentials configured for the AWS CLI to describe and terminate EC2 instances.
Use this script at your own risk.