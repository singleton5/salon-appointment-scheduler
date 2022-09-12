#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

echo -e "Welcome to My Salon, how can I help you?\n"

MAIN_MENU() {
  if [[ $1 ]] 
  then
    echo $1
  fi

OUR_SERVICES=$($PSQL "SELECT * FROM services")
echo "$OUR_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
do
  echo -e "$SERVICE_ID) $SERVICE_NAME"
done
}

MAIN_MENU

# get service ID from cutomer
echo -e "\nPlease, pick a service."
read SERVICE_ID_SELECTED

# if customer input is not a number
if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]] 
then
  MAIN_MENU "Please, enter a valid input."
else
SERVICE_ID_RESULT=$($PSQL "SELECT * FROM services WHERE service_id=$SERVICE_ID_SELECTED")
fi

# if customer input is a number but not in the list of services
if [[ -z $SERVICE_ID_RESULT ]] 
then 
  MAIN_MENU "I could not find that service. What would you like today?"
fi

echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE

# check if customer is registered
CUSTOMER_CHECK=$($PSQL "SELECT * FROM customers WHERE phone='$CUSTOMER_PHONE'")

if [[ -z $CUSTOMER_CHECK ]] 
then
  # get customer name
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME

  # register customer
  INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
fi

CUSTOMER_NAME_RESULT=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

SERVICE_ID_SELECTED_RESULT=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

# get time for the appointment
echo -e "\nWhat time would you like your $(echo $SERVICE_ID_SELECTED_RESULT | sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME_RESULT | sed -r 's/^ *| *$//g')?"
read SERVICE_TIME

# get customer ID 
CUSTOMER_ID_RESULT=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

# record appointment
INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID_RESULT, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

echo -e "\nI have put you down for a $(echo $SERVICE_ID_SELECTED_RESULT | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME_RESULT | sed -r 's/^ *| *$//g')."
