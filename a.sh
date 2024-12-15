#!/bin/bash

# List of groups to process
groups=(
  "Core"
  "Desktop accessibility"
  "Dial-up Networking Support"
  "Fonts"
  "Guest Desktop Agents"
  "Hardware Support"
  "Input Methods"
  "LXDE"
  "Multimedia"
  "Printing Support"
  "Standard"
  "base-x"
  "3D Printing"
  "Applications for the LXDE Desktop"
  "Cloud Management Tools"
  "LXDE Office"
)

# Initialize variables
first_package=true

# Start building the dnf command
echo -n "dnf install -y"

# Extract package names and append them to the command
for group in "${groups[@]}"; do
  dnf group info "$group" 2>/dev/null | awk -v first="$first_package" '
  /Mandatory Packages:/, /^[^ ]/ { 
    if ($1 !~ /^(Mandatory|Optional|Default|Conditional|Packages:|$)/) {
      if (first == "true") {
        printf " %s", $1
        first = "false"
      } else {
        printf " \\\n%s", $1
      }
    }
  }' first_package=false
done

