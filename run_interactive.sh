#!/bin/bash
#
# Author: AppaTalks
# Description: Interactive Bash wrapper for running pre-defined GitHub GraphQL queries

# Define the log file path
log_file="/tmp/graphql_interactive-$(date +'%Y%m%d-%H%M%S').json"

# Define an array with available top-level choices
top_level_choices=("Owner Query" "Organization Query")

# Define sub-queries for each category
owner_queries=(
  "Login Check" 
  "Review Closed Issues" 
  "Get ID of Repo"
  "Find Issue ID"
  "Add Reaction to Issue"
  "Add Comment to Issue"
  "Check User Rate Limits"
  "Review Branch Protection Rules"
  "Review Branch Protection Rules for Pull Request"
  "Check Repo Disk Usage"
)
organization_queries=(
  "Login Check" 
  "Add Reaction to Issue" 
  "Add Comment to Issue"
  "List Organization Members"
  "Get Repository IDs"
  "List Repository Languages"
)

while true; do
  # Prompt the user for the initial choice
  echo "Please select the query type:"
  for ((i=0; i<${#top_level_choices[@]}; i++)); do
    echo "$i) ${top_level_choices[$i]}"
  done
  echo ""

  read -p "Your choice: " top_level_choice
  echo ""

  # Check if the top-level choice is valid
  if [[ "$top_level_choice" =~ ^[0-9]+$ ]] && [ "$top_level_choice" -ge 0 ] && [ "$top_level_choice" -lt ${#top_level_choices[@]} ]; then
    # Depending on the top-level choice, set the prefix for query_file
    if [ "$top_level_choice" -eq 0 ]; then
      query_file_prefix="u"
      sub_queries=("${owner_queries[@]}")
    else
      query_file_prefix="o"
      sub_queries=("${organization_queries[@]}")
    fi

    # Prompt the user for their sub-choice (based on the top-level choice)
    echo "Please select a sub-query (enter the corresponding number):"
    for ((i=0; i<${#sub_queries[@]}; i++)); do
      echo "$i) ${sub_queries[$i]}"
    done
    echo ""

    read -p "Your sub-choice: " user_sub_choice
    echo ""

    # Check if the user's sub-choice is valid
    if [[ "$user_sub_choice" =~ ^[0-9]+$ ]] && [ "$user_sub_choice" -ge 0 ] && [ "$user_sub_choice" -lt ${#sub_queries[@]} ]; then
      query_file="$(printf "%02d" $user_sub_choice)_${query_file_prefix}_*.json"
      QRESULTS=$(./graphql_query.sh json/$query_file)
      echo -e "$QRESULTS" | sed 's/["{}]//g' | sed '/^\s*$/d' | sed 's/,//g'

      # Log the results to the log file
      echo -e "$QRESULTS" | sed 's/["{}]//g' | sed '/^\s*$/d' | sed 's/,//g' >> "$log_file"
    else
      echo -e "\e[91mInvalid sub-choice. Please select a valid number.\e[0m"
    fi
  else
    echo -e "\e[91mInvalid top-level choice. Please select a valid number.\e[0m"
    continue
  fi

  # Ask the user if they want to run another query
  read -p "Do you want to run another query? (y)es/(n)o: " run_again
  if [ "$run_again" != "y" ]; then
    break
  fi
done

