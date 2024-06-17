#!/bin/bash
# john the dev rocks
# chore
# test
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo -e "Enter your username: \n"
read USERNAME

# find if user exists in db already
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
if [[ -z $USER_ID ]]; then
  # insert user to users table
  INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  # find user_id from users table for building the reference in games table
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
  
  echo -e "\n Welcome, $USERNAME! It looks like this is your first time here.\n"
else
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id=$USER_ID")
  BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games WHERE user_id=$USER_ID")

  echo -e "\n Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses.\n"
fi

# 1 game per script run, basically every run starts here
RANDOM_NUMBER=$((RANDOM % 1000 + 1))

echo -e "\n Guess the secret number between 1 and 1000:\n"
read GUESS

NUMBER_OF_TRIES=0
MAIN_GAME_LOOP() {
  #check if this a recursive call (basically check that it is not the first run)
  if [[ $1 == "TRUE" ]]; then
    read GUESS
  fi

  if [[ "$GUESS" == $RANDOM_NUMBER ]];then
    NUMBER_OF_TRIES=$((NUMBER_OF_TRIES + 1))
    echo -e "\nYou guessed it in $NUMBER_OF_TRIES tries. The secret number was $RANDOM_NUMBER. Nice job!\n"
  else
    if [[ "$GUESS" =~ ^[0-9]+$ ]]; then
      if [[ $GUESS > $RANDOM_NUMBER ]]; then
        echo -e "\nIt's lower than that, guess again:\n"
        NUMBER_OF_TRIES=$((NUMBER_OF_TRIES + 1))
        MAIN_GAME_LOOP "TRUE"
      else
        echo -e "\nIt's higher than that, guess again:\n"
        NUMBER_OF_TRIES=$((NUMBER_OF_TRIES + 1))
        MAIN_GAME_LOOP "TRUE"
      fi
    else
      echo -e "\nThat is not an integer, guess again:\n"
    fi
  fi
}
MAIN_GAME_LOOP # FIRST RUN - INITIATE

# insert user to games table and guess in one swoop
INSERT_GAME=$($PSQL "INSERT INTO games(guesses, user_id) VALUES($NUMBER_OF_TRIES, $USER_ID)")