# Control file for Vagrant configuration

# Define the number of master, worker, and load balancer nodes
NUM_MASTERS = 1
NUM_WORKERS = 2
NUM_LOADBALANCERS = 0

# Define the IP range for each type of node
MASTER_IP_START = "192.168.56.10"
WORKER_IP_START = "192.168.56.20"
LOADBALANCER_IP_START = "192.168.56.110"

# Define CPU and memory for each group of VMs
MASTER_CPU = 2
MASTER_MEMORY = 2048
WORKER_CPU = 2
WORKER_MEMORY = 3500
LOADBALANCER_CPU = 1
LOADBALANCER_MEMORY = 1024
