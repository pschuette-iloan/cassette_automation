#!/bin/bash

#
# Script variables
#
output="$(pwd)/.output"
temp="$(pwd)/.temp"
cookies="$temp/cookies.txt"
session_dir="$(pwd)/session"
endpoints_dir="$(pwd)/endpoints"
headers_cfg="$(pwd)/headers"
baseurl="https://mobile.onemain.financial"

# TODO: Check dependencies

#
# Create directory or remove contents
#
function clean_dir() {
    echo "Cleaning Directory: $1"
    if [ ! -d $1 ]
    then mkdir $1
    else
        rm -rf "$1"/*
    fi
}

#
# Read a file into an array
#
function read_scenarios() {
    echo "reading scenarios from: $1"
    scenarios=( )
    while IFS= read value
    do
        scenarios+=($value)
    done < $1
}

#
# Read all endpoint files into an array
#
function read_endpoint_configs() {
    echo "reading endpoint configs from: $1"
    endpoints=($(ls -d "$1"/*))
}

#
# Read the standard headers from header file
#
function read_standard_headers() {
    echo "reading standard headers from: $1"
    source $1
    # Print the headers
    echo "Standard Headers:"
    for header in "${headers[@]}"
    do
    echo $header
    done
}

#
# Setup the headers into a header file
#
function setup_args() {
    args="-H \"DISCO: $1\""
    for header in "${headers[@]}"
    do
    args="$args -H \"$header\""
    done
    echo "Args: $args"
}

function setup_auth_args() {
    setup_args $1
    echo adding auth token to args
    # Add the auth token to args
    args="$args -H \"Authorization: Token token=$token\""
    echo "Args: $args"
}

#
# Call the session URL to create a new session
#
function prepare_session() {
# $1 = scenario
# $2 = endpoint config file
# $3 = output directory

    # source function variables
    source $2

    setup_args 'success'
    cmd="curl -X $method $baseurl$endpoint_destination $args --cookie $cookies --cookie-jar $cookies -o $3/$output_file --verbose -u blah:blah"
    echo "Calling: $cmd"
    eval $cmd

    # Setup the session args
    token=$(cat $3/$output_file | jq -r '.data.attributes."access-token"')
    challenge_type=$(cat $3/$output_file | jq -r '.data.attributes."device-challenge-type"')
    challenge_id=$(cat $3/$output_file | jq -r '.data.relationships."device-challenges".data[0]."id"')
    echo "Token: $token"
    echo "Challenge Type: $challenge_type"
    echo "Challenge ID: $challenge_id"

    # Source arguments for challenge questions
    source "$session_dir"/challenges_verification
    # Answer challenge question
    setup_auth_args $1
    echo "date: $data"
    cmd="curl -X $method $baseurl$endpoint_destination $args --data $data --cookie $cookies --cookie-jar $cookies -o $3/$output_file"
    echo "Calling: $cmd"
    eval $cmd

}

#
# Call the endpoint and dump the output
#
function call_endpoint() {
# $1 = scenario
# $2 = endpoint config file
# $3 = output directory
    source $2

    setup_args $1
# Might need to switch between method types here
    cmd="curl -i $args -X $method --data $data $baseurl$endpoint_destination -o $3/$output_file"
    echo "Calling: $cmd"
    eval $cmd

}

#
# Main program function
#
function main()
{
    #
    # 1. get a list of all the scenarios
    #
    read_scenarios "$(pwd)/scenarios.txt"

    #
    # 2. get a list of all the mobile endpoints
    #
    read_endpoint_configs $endpoints_dir

    #
    # 3. get the standard headers as variables
    # Store a list of all standard headers in array
    #
    read_standard_headers $headers_cfg

    #
    # 4. Make the output directory
    # Hidden during creation
    #
    clean_dir $output

    for scenario in "${scenarios[@]}"
    do
        # Print out the scenario
        echo "Building scenario: $scenario"

        clean_dir $temp

        # Make a directory for the scenario in the output
        scenario_dir="$(pwd)/.output/$scenario"

        mkdir $scenario_dir

        prepare_session $scenario "$session_dir"/login $scenario_dir

        # Loop through the endpoints, pump into output directory
        for endpoint in "${endpoints[@]}"
        do
            echo "Would be Preparing endpoint: $endpoint"
# call_endpoint $scenario $endpoint $scenario_dir
        done

        # TODO: end session (delete)
    done

    # Remove the temp directory
    # rm -rf $temp
}


# Run the program
main
