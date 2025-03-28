#!/usr/bin/env bash
# ${cblue}Edit$cend cheatsheet (Subcmd)


dashboard(){
  : 'EC2 Dashboard'
  aws ec2 describe-instances | 
    jq -r '
      .Reservations[].Instances[] |
      {InstanceId: .InstanceId, State: .State.Name, InstanceType: .InstanceType, Name: (.Tags[] | select(.Key == "Name") | .Value)} |
    "| \(.InstanceId) | \(.State) | \(.InstanceType) | \(.Name // "N/A") |"'

}

main "$@"

# vim:sw=2:ts=2:
