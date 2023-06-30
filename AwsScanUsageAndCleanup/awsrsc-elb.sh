#!/bin/bash

#############################
# ELB (Elastic Load Balancing)
#############################
# Resources:
# - Load Balancers
# - Target Groups
#############################

# $ aws elbv2 describe-load-balancers
# EX:
#   "LoadBalancerArn": "arn:aws:elasticloadbalancing:us-east-1:123xxxxxxxxx:loadbalancer/app/my-web-alb/f4df558c357fe644",
#   "LoadBalancerName": "my-web-alb",
#   "DNSName": "my-web-alb-236538282.us-east-1.elb.amazonaws.com"
# $ aws elbv2 delete-load-balancer --load-balancer-arn arn:aws:elasticloadbalancing:us-west-2:123xxxxxxxxx:loadbalancer/app/my-load-balancer/50dc6c495c0c9188

# $ aws elbv2 describe-target-groups
# EX:
#   "TargetGroupArn": "arn:aws:elasticloadbalancing:us-east-1:123xxxxxxxxx:targetgroup/target-alb-ecs/1a4438e793a76bec",
#   "TargetGroupName": "target-alb-ecs",



AWSF_FULL_NAME="ELB (Elastic Load Balancing)"
AWSF_SHORT_NAME="ELB"

G_resStatus=


function check_resLoadBalancer() {
    G_resStatus=$(aws elbv2 describe-load-balancers)
    resCount=$(echo $G_resStatus | jq '.["LoadBalancers"]|length')
    if [ "0" = $resCount ]; then
        log "Load Balancer Clear!"
        return
    fi

    log "Load Balancer Count: $resCount"
}

function checkVerbosely_resLoadBalancer() {
    echo $G_resStatus | jq '.["LoadBalancers"][]["LoadBalancerArn"]'
}

function deleteAll_resLoadBalancer() {
    resStr=$(echo $G_resStatus | jq '[.["LoadBalancers"][]["LoadBalancerArn"]]' | jq '.|join(",")' | sed 's/"//g')
    resources=(${resStr//,/ })
    for(( i=0; i<${#resources[@]}; i++ ))
    do
        arn=${resources[$i]}

        aws elbv2 delete-load-balancer --load-balancer-arn ${arn}
        log "Deleted load-balancer ${arn}"
    done
}

function check_resTargetGroup() {
    G_resStatus=$(aws elbv2 describe-target-groups)
    resCount=$(echo $G_resStatus | jq '.["TargetGroups"]|length')
    if [ "0" = $resCount ]; then
        log "Target Group: Clear!"
        return
    fi

    log "Target Group Count: $resCount"
}

function checkVerbosely_resTargetGroup() {
    echo $G_resStatus | jq '.["TargetGroups"][]["TargetGroupArn"]'
}

function deleteAll_resTargetGroup() {
    resStr=$(echo $G_resStatus | jq '[.["TargetGroups"][]["TargetGroupArn"]]' | jq '.|join(",")' | sed 's/"//g')
    resources=(${resStr//,/ })
    for(( i=0; i<${#resources[@]}; i++ ))
    do
        arn=${resources[$i]}

        aws elbv2 delete-target-group --target-group-arn ${arn}
        log "Deleted target-group ${arn}"
    done
}



function check() {
    check_resLoadBalancer
    check_resTargetGroup
}

function checkVerbosely() {
    check_resLoadBalancer
    checkVerbosely_resLoadBalancer

    check_resTargetGroup
    checkVerbosely_resTargetGroup
}

function deleteAll() {
    check_resLoadBalancer
    deleteAll_resLoadBalancer

    check_resTargetGroup
    deleteAll_resTargetGroup
}


function log() {
    echo "* [${AWSF_SHORT_NAME}] $1"
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
