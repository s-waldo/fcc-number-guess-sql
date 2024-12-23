#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

RANDOM_NUMBER=$(( $RANDOM % 1000 + 1 ))

echo "Enter your username:"
read USER_NAME
# get user id
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USER_NAME'")
# if no exists
if [[ -z $USER_ID ]]
then
  # create user
  CREATE_USER_RESULT=$($PSQL "INSERT INTO users (username) VALUES ('$USER_NAME')")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USER_NAME'")
  echo "Welcome, $USER_NAME! It looks like this is your first time here."
else
  NUMBER_OF_GAMES=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id = $USER_ID")
  BEST_GAME=$($PSQL "SELECT MIN(score) FROM games WHERE user_id = $USER_ID")
  echo "Welcome back, $USER_NAME! You have played $NUMBER_OF_GAMES games, and your best game took $BEST_GAME guesses."
fi

# play game
echo -e "\nGuess the secret number between 1 and 1000:"
read GUESS
GUESS_COUNT=1

while [[ $GUESS != $RANDOM_NUMBER ]]
do
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo That is not an integer, guess again:
  elif [[ $GUESS > $RANDOM_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
  (( GUESS_COUNT++ ))
  else
    echo "It's higher than that, guess again:"
  (( GUESS_COUNT++ ))
  fi
  read GUESS
done

echo "You guessed it in $GUESS_COUNT tries. The secret number was $RANDOM_NUMBER. Nice job!"

# save game stats with user
SAVE_GAME_RESULT=$($PSQL "INSERT INTO games (user_id, score) VALUES ($USER_ID, $GUESS_COUNT)")
