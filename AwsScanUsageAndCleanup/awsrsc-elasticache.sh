#!/bin/bash

#############################
# AWS ElastiCache
#############################
# Resources:
# - Replication Group (Redis Clusters level, including nodes)
# - (TBC) Subnet groups
#############################

# "replication-groups": 等於 UI 上看到的 redis cluster)
# EX:
#   ReplicationGroupId: my-redis-cluster
#   ARN: arn:aws:elasticache:us-east-1:123xxxxxxxxx:replicationgroup:my-redis-cluster
# $ aws elasticache describe-replication-groups
# $ aws elasticache delete-replication-group --replication-group-id "mygroup"

# "cache-clusters": 等於 UI 上看到的 node，而非 redis cluster
# $ aws elasticache describe-cache-clusters
# EX:
#   "ARN": "arn:aws:elasticache:us-east-1:123xxxxxxxxx:cluster:my-redis-cluster-not-clsmode-002",
#   "ReplicationGroupId": "my-redis-cluster-not-clsmode", <---- 這個才是 UI 上看到的 redis cluster
#   "CacheClusterId": "my-redis-cluster-not-clsmode-002", <---- UI 上看到的 node

# 可以直接 delete replication-group 那層，他會自己把 node level 也砍掉
# delete 是 async 進行，cli 和 UI 操作 delete 都會立刻ok，狀態變 deleting，但 async 砍得有點慢


AWSF_FULL_NAME="ElastiCache"
AWSF_SHORT_NAME="ECache"
LOG_PREFIX="* [${AWSF_SHORT_NAME}]"

function log() {
    echo "$LOG_PREFIX $1"
}

function check() {
    resCount=$(aws elasticache describe-replication-groups | jq '.["ReplicationGroups"]|length')
    if [ "0" = resCount ]; then
        log "Clear!"
        return
    fi

    log "Replication Group Count(Redis Cluster Level): $resCount"
}

function checkVerbosely() {
    resStatus=$(aws elasticache describe-replication-groups)
    resCount=$(echo $resStatus | jq '.["ReplicationGroups"]|length')
    if [ "0" = resCount ]; then
        log "Clear!"
        return
    fi

    log "Replication Group Count(Redis Cluster Level): $resCount"
    echo $resStatus | jq '.["ReplicationGroups"][]["ARN","Status"]'
}

function deleteAll() {
    resStatus=$(aws elasticache describe-replication-groups)
    resCount=$(echo $resStatus | jq '.["ReplicationGroups"]|length')
    if [ "0" = resCount ]; then
        log "Clear!"
        return
    fi

    log "Replication Group Count(Redis Cluster Level): $resCount"

    # TODO
    # clusterStr=$(echo $clusterStatus | jq '.["clusterArns"]' | jq '.|join(",")' | sed 's/"//g')
    # clusters=(${clusterStr//,/ })
    # for(( i=0; i<${#clusters[@]}; i++ ))
    # do
    #     clusterArn=${clusters[$i]}

    #     deleteService $clusterArn

    #     aws ecs delete-cluster --cluster $clusterArn
    #     log "Deleted cluster ${clusterArn}"
    # done
}

function showMenu() {
  echo "================================================"
  echo "    ${AWSF_FULL_NAME}"
  echo "================================================"
  echo "(1|check|c) Check"
  echo "(2|checkv|cv) Check Verbosely"
  echo "------------------------------------------------"
  echo "(delete) Delete All Resources (TBC)"
  echo "================================================"

  read -p "Please input choice: " choice
  runChoice
}

function runChoice() {
    case ${choice} in
        "1"|"check"|"c") check;;
        "2"|"checkv"|"cv") checkVerbosely;;
        "delete") deleteAll;;
        *)
            echo "Unsupported choice, exit."
            exit
            ;;
    esac
}


if [ "$#" == "1"  ]
then
    choice=$1
    runChoice
    exit
fi

showMenu
