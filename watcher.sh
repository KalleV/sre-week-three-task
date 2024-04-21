#!/bin/bash

# Define Variables
namespace="sre"
deployment="swype-app"
max_restarts=5

while true; do
    # Get the number of restarts for the pods associated with the deployment
    restarts=$(kubectl get pods -n $namespace -l app=$deployment -o jsonpath='{.items[*].status.containerStatuses[*].restartCount}' | awk '{s+=$1} END {print s}')
    
    if [ -z "$restarts" ]; then
        restarts=0
    fi

    echo "Current number of restarts: $restarts"

    # Check if the number of restarts exceeds the maximum allowed
    if [[ $restarts -gt $max_restarts ]]; then
        echo "Maximum number of restarts exceeded. Scaling down the deployment..."
        # Scale down the deployment to zero replicas
        kubectl scale deployment $deployment --replicas=0 -n $namespace
        break
    else
        # Pause for 60 seconds before the next check
        sleep 60
    fi
done

echo "Restart threshold exceeded. The deployment of $deployment in namespace $namespace has been scaled down."
