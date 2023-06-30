#!/bin/bash

#############################
# S3 (Simple Storage Service)
#############################
# Resources:
# - Buckets (have: files)
#############################

AWSF_FULL_NAME="S3 (Simple Storage Service)"
AWSF_SHORT_NAME="S3"

G_resStatus=


function check() {

}

function checkVerbosely() {

}

function deleteAll() {

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
