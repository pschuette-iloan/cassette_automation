#!/bin/bash

#
# Script variables
#
output="$(pwd)/.output"

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


function setup_output() {
    echo "Ouput directory: $output"
    if [ ! -d $output ]
    then mkdir $output
    else
    echo removing contents of output directory
    rm -rf "$output"/*
    fi
    # clear the output directory
    rm -rf $pwd/.output/*
}

function main()
{
    #
    # 1. get a list of all the scenarios
    #
    read_scenarios "$(pwd)/scenarios.txt"

    #
    # 2. get a list of all the mobile endpoints
    #
    endpoints=(
            /api/v1/accounts
            /api/v1/configurations/global
        )

    #
    # 3. Make the output directory
    # Hidden during creation
    #
    setup_output


    for scenario in "${scenarios[@]}"
    do
        # Print out the scenario
        echo "Building scenario: $scenario"
        # Make a directory for the scenario in the output
        scenario_dir="$(pwd)/.output/$scenario"
        mkdir $scenario_dir
        # Loop through the endpoints, pump into output directory
        for endpoint in "${endpoints[@]}"
        do
        echo "Preparing endpoint: $endpoint"
        done
    done
}


# Run the program
main
