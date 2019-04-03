#!/bin/bash


#
# Call and endpoint and dump the outputi
# arg1= endpoint
# arg2= destination
#
function call_endpoint() {
    echo calling into endpoint $0
    
}


function main()
{
    #
    # 1. get a list of all the scenarios
    #
    scenarios=(
            happy_path
            past_due_account_with_next_cycle
        )

    #
    # 2. get a list of all the mobile endpoints
    #
    endpoints=(
            /api/v1/accounts
            /api/v1/configurations/global
        )

    # Iterate through scenarios printing endpoints

    #
    # 3. Make the output directory
    # Hidden during creation
    #
    if [ ! -d .output ]
    then mkdir .output
    fi
    # clear the output directory
    rm -r .output/*

    for scenario in "${scenarios[@]}"
    do
        # Print out the scenario
        echo $scenario
        # Make a directory for the scenario in the output
        mkdir "$(pwd)/.output/$scenario"
        for endpoint in "${endpoints[@]}"
        do
            echo $endpoint
        done
    done
}


# Run the program
main
