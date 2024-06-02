#!/bin/bash

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Install grpcurl using go install
install_grpcurl() {
  echo "Installing grpcurl using go install..."
  go install github.com/fullstorydev/grpcurl/cmd/grpcurl@latest || { echo "Error: Failed to install grpcurl using go install. Please install it manually." >&2; exit 1; }
}

# Check if grpcurl is installed, if not, attempt to install it
if ! command_exists grpcurl; then
  if ! install_grpcurl; then
    echo "Error: Failed to install grpcurl. Please install it manually." >&2
    exit 1
  fi
fi

# Check if jq is installed, if not, install it
if ! command_exists jq; then
  echo "jq is not installed. Installing..."
  sudo apt-get update && sudo apt-get install -y jq || { echo "Error: Failed to install jq. Please install it manually." >&2; exit 1; }
fi

# Retrieve the network information from the node
network_info=$(grpcurl -plaintext localhost:8337 quilibrium.node.node.pb.NodeService.GetNetworkInfo)

# Extract peerIds and peerScores
peer_ids=$(echo "$network_info" | jq -r '.networkInfo[].peerId')
peer_scores=$(echo "$network_info" | jq -r '.networkInfo[] | select(.peerScore) | .peerScore')

# Count the total number of peers
peer_count=$(echo "$peer_ids" | wc -l)

# Count the number of peers with a peerScore of -10000
peer_score_count=$(echo "$peer_scores" | grep -c '-10000' || true)

# Debugging output
echo "Debugging Output:"
echo "peer_score_count: $peer_score_count"

# Output the results
echo ""
echo "You are connected to $peer_count peers on the network"
if [ -n "$peer_score_count" ] && [ "$peer_score_count" -gt 0 ]; then
  echo "$peer_score_count peers have a peerScore of -10000"
fi
echo ""
