#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME

# find the user in the database
USER_DATA=$($PSQL "SELECT user_id, games_played, best_game FROM users WHERE username='$USERNAME'")

# if the user doesn't exist
if [[ -z $USER_DATA ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  # insert into the database
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  GAMES_PLAYED=0
  BEST_GAME=0
else
  # take the user information
  IFS="|" read USER_ID GAMES_PLAYED BEST_GAME <<< "$USER_DATA"
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# random number generator
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
echo "Guess the secret number between 1 and 1000:"

NUMBER_OF_GUESSES=0

while true
do
  read GUESS

  # verify if it is a number
  if ! [[ $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    continue
  fi

  ((NUMBER_OF_GUESSES++))

  # compare the guess with the secret number
  if [[ $GUESS -lt $SECRET_NUMBER ]]
  then
    echo "It's higher than that, guess again:"
  elif [[ $GUESS -gt $SECRET_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
  else
    echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
    
    # Update games played and the best score
    ((GAMES_PLAYED++))
    if [[ $BEST_GAME -eq 0 || $NUMBER_OF_GUESSES -lt $BEST_GAME ]]
    then
      BEST_GAME=$NUMBER_OF_GUESSES
    fi
    UPDATE_USER_RESULT=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED, best_game=$BEST_GAME WHERE username='$USERNAME'")
    break
  fi
done
