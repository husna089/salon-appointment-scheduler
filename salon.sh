
#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only --no-align -q -c"

echo -e "\n~~~~~ Salon Appointment Scheduler ~~~~~\n"

# Display services
SHOW_SERVICES() {
  echo "Here are the services we offer:"
  $PSQL "SELECT service_id, name FROM services ORDER BY service_id" | while IFS='|' read SERVICE_ID SERVICE
  do
    echo "$SERVICE_ID) $SERVICE"
  done
}

# Select service
while true
do
  SHOW_SERVICES

  echo -e "\nWhat would you like to book?"
  read SERVICE_ID_SELECTED

  # Check service
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    continue
  fi

  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

  if [[ -z $SERVICE_NAME ]]
  then
    continue
  fi

  break
done

# Get customer phone
echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE

# Find customer
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

# Register new customer
if [[ -z $CUSTOMER_ID ]]
then
  echo -e "\nWhat's your name?"
  read CUSTOMER_NAME

  $PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')"

  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
else
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
fi

# Get appointment time
echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
read SERVICE_TIME

# Insert appointment
INSERT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

# Confirmation
echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."