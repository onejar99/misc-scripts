#!/bin/bash

#############################
# ECS (Elastic Container Service)
#############################
# Resources:
# - Clusters (including services, tasks)
# - (TBC) Task Definitions
#############################

# "[ECS] Cluster Count: "
# "[ECS] Task Def Count: "
## .clusterArns[]
#aws ecs list-clusters
#aws ecs list-tasks --cluster xxx
#aws ecs list-services --cluster MyCluster
#aws ecs delete-cluster --cluster MyCluster
# aws ecs list-task-definition-families
# aws ecs list-task-definitions
# task-def-family 和 task-def 的差別：一個 task-def-family 會有很多 revision 版本(task-def)
# "families": [
#         "mytestweb-task",
#         "mywebsocket-task",
#{
#         "taskDefinitionArns": [
#         "arn:aws:ecs:us-east-1:123xxxxxxxxx:task-definition/mytestweb-task:1",
#         "arn:aws:ecs:us-east-1:123xxxxxxxxx:task-definition/mytestweb-task:2",
#         "arn:aws:ecs:us-east-1:123xxxxxxxxx:task-definition/mywebsocket-task3000:1",

AWSF_FULL_NAME="ECS (Elastic Container Service)"
AWSF_SHORT_NAME="ECS"
LOG_PREFIX="* [${AWSF_SHORT_NAME}]"

function log() {
    echo "$LOG_PREFIX $1"
}

function check() {
    clusterCount=$(aws ecs list-clusters | jq '.["clusterArns"]|length')
    if [ "0" = clusterCount ]; then
        log "Clear!"
        return
    fi

    log "Cluster Count: $clusterCount"
}

function checkVerbosely() {
    clusterStatus=$(aws ecs list-clusters)
    clusterCount=$(echo $clusterStatus | jq '.["clusterArns"]|length')
    if [ "0" = clusterCount ]; then
        log "Clear!"
        return
    fi

    log "Cluster Count: $clusterCount"
    echo $clusterStatus | jq '.["clusterArns"]'
}

function deleteAll() {
    clusterStatus=$(aws ecs list-clusters)
    clusterCount=$(echo $clusterStatus | jq '.["clusterArns"]|length')
    if [ "0" = clusterCount ]; then
        log "Clear!"
        return
    fi

    log "Cluster Count: $clusterCount"
    clusterStr=$(echo $clusterStatus | jq '.["clusterArns"]' | jq '.|join(",")' | sed 's/"//g')
    clusters=(${clusterStr//,/ })
    for(( i=0; i<${#clusters[@]}; i++ ))
    do
        clusterArn=${clusters[$i]}

        deleteService $clusterArn

        aws ecs delete-cluster --cluster $clusterArn
        log "Deleted cluster ${clusterArn}"
    done
}

function deleteService() {
    clusterArn=$1

    serviceStr=$(aws ecs list-services --cluster $clusterArn | jq '.["serviceArns"]' | jq '.|join(",")' | sed 's/"//g')
    services=(${serviceStr//,/ })
    for(( i=0; i<${#services[@]}; i++ ))
    do
        serviceArn=${services[$i]}
        aws ecs delete-service --cluster $clusterArn --service $serviceArn --force
        log "Deleted service ${serviceArn}"
    done
}

function showMenu() {
  echo "================================================"
  echo "    ${AWSF_FULL_NAME}"
  echo "================================================"
  echo "(1|check|c) Check"
  echo "(2|checkv|cv) Check Verbosely"
  echo "------------------------------------------------"
  echo "(delete) Delete All Resources"
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
