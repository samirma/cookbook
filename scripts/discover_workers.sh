#!/bin/sh


echo "Discovering workers..."
# Use the parsable format and filter for "Termux Worker"
avahi-browse -r -p -t _ssh._tcp | grep ";Termux Worker" | while IFS=';' read -r _ interface _ name _ _ host ip port txt; do
  # Ensure the name field is not empty
  if [ -n "$name" ]; then
    # Use sed to reliably extract the user from the text field
    user=$(echo "$txt" | sed -n 's/.*user=\([^"]*\).*/\1/p')
    if [ -n "$user" ]; then
      echo "ssh -p $port $user@$ip"
    fi
  fi
done
