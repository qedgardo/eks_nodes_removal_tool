#!/bin/bash

# Function to list Kubernetes nodes and their versions
function list_kubernetes_nodes() {
  echo "Listing Kubernetes nodes and versions:"
  echo "  0. Exit"

  # Fetch nodes and versions and store them in an array
  local NODES=()
  while IFS= read -r NODE; do
    NODES+=("$NODE")
  done < <(kubectl get nodes -o=jsonpath='{range .items[*]}{"  "}{.metadata.name} {.status.nodeInfo.kubeletVersion}{"\n"}{end}')

  # Display nodes with index numbers
  local INDEX=1
  for NODE in "${NODES[@]}"; do
    echo "  $INDEX. $NODE"
    INDEX=$((INDEX + 1))
  done
}

# Function to drain the selected node
function drain_and_remove_node() {
  read -p "Enter the index number of the node you want to drain and remove from the cluster (or '0' to quit): " SELECTED_INDEX

  if [ "$SELECTED_INDEX" == "0" ]; then
    echo "Exiting the script."
    exit 0
  fi

  # Adjust the index to match the actual node index (since the options start at 1)
  ADJUSTED_INDEX=$((SELECTED_INDEX - 1))

  # Get the name of the selected node based on the index
  NODE_NAME=$(kubectl get nodes -o=jsonpath="{.items[$ADJUSTED_INDEX].metadata.name}")

  # Drain the pods of the selected node
  kubectl drain --ignore-daemonsets --force --delete-emptydir-data $NODE_NAME

  # Delete the empty node
  kubectl delete node $NODE_NAME
  echo "Cluster node $NODE_NAME removed"

  # Get the instance ID from the node name
  INSTANCE_ID=$(aws ec2 describe-instances --filters "Name=private-dns-name,Values=$NODE_NAME" --query 'Reservations[*].Instances[*].InstanceId' --output text)

  # Terminate the instance
  read -p "Are you sure you want to terminate instance $INSTANCE_ID? (y/n): " CONFIRMATION
  if [ "$CONFIRMATION" == "y" ]; then
    # Terminate the instance
    aws ec2 terminate-instances --instance-ids $INSTANCE_ID
    echo "Instance $INSTANCE_ID terminated"
  else
    echo "Instance $INSTANCE_ID not terminated"
  fi
}

# Main script execution starts here
cat << "EOF"
    ___        ______    _____ _  ______    _   _           _           
   / \ \      / / ___|  | ____| |/ / ___|  | \ | | ___   __| | ___  ___ 
  / _ \ \ /\ / /\___ \  |  _| | ' /\___ \  |  \| |/ _ \ / _` |/ _ \/ __|
 / ___ \ V  V /  ___) | | |___| . \ ___) | | |\  | (_) | (_| |  __/\__ \
/_/   \_\_/\_/  |____/  |_____|_|\_\____/  |_| \_|\___/ \__,_|\___||___/
                                                                        
 ____                                _   ____            _       _   
|  _ \ ___ _ __ ___   _____   ____ _| | / ___|  ___ _ __(_)_ __ | |_ 
| |_) / _ \ '_ ` _ \ / _ \ \ / / _` | | \___ \ / __| '__| | '_ \| __|
|  _ <  __/ | | | | | (_) \ V / (_| | |  ___) | (__| |  | | |_) | |_ 
|_| \_\___|_| |_| |_|\___/ \_/ \__,_|_| |____/ \___|_|  |_| .__/ \__|
                                                          |_|        
EOF

while true; do
  # List Kubernetes nodes with index numbers, including the "Exit" option at index 0
  list_kubernetes_nodes

  # Prompt the user to select a node by index number
  drain_and_remove_node
done
