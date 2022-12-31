#! /bin/bash


PSQL="psql -X --tuples-only --username=freecodecamp --dbname=number_guess -c"

echo "Enter your username:"
read USERNAME

USER_LOOKUP=$($PSQL "SELECT * FROM user_info WHERE username = '$USERNAME'")

if [[ -z $USER_LOOKUP ]]
then

  echo "Welcome, $USERNAME! It looks like this is your first time here."
  USER_INSERT=$($PSQL "INSERT INTO user_info(username,games_played) VALUES('$USERNAME',0)")

else

  echo $USER_LOOKUP | while read ID BAR NAME BAR GAMES BAR BEST
  do

    echo "Welcome back, $NAME! You have played $GAMES games, and your best game took $BEST guesses."

  done

fi

GAMES_PLAYED=$($PSQL "SELECT games_played FROM user_info WHERE username = '$USERNAME'")

RAND=$(($RANDOM % 1000))
NUM_OF_GUESSES=0

GUESS () {

  if [[ $1 ]]
  then
    echo $1
  else
    echo "Guess the secret number between 1 and 1000:"
  fi

  NUM_OF_GUESSES=$(($NUM_OF_GUESSES + 1))

  read INPUT

  if ! [[ $INPUT =~ ^[0-9]+$ ]]
  then

    GUESS "That is not an integer, guess again:"

  elif [[ $INPUT > $RAND ]]
  then

    GUESS "It's lower than that, guess again:"
  
  elif [[ $INPUT < $RAND ]]
  then
  
    GUESS "It's higher than that, guess again:"
  
  elif [[ $INPUT == $RAND ]]
  then
  
    GAME_INCREMENT=$($PSQL "UPDATE user_info SET games_played=$(($GAMES_PLAYED + 1))")

    BEST_GAME_LOOKUP=$($PSQL "SELECT best_game FROM user_info WHERE username = '$USERNAME'")

    if [[ -z $BEST_GAME_LOOKUP || $BEST_GAME_LOOKUP < $NUM_OF_GUESSES ]]; then

      BEST_GAME_INSERT=$($PSQL "UPDATE user_info SET best_game = $NUM_OF_GUESSES")

    fi

    echo "You guessed it in $NUM_OF_GUESSES tries. The secret number was $RAND. Nice job!"

  fi

}

GUESS
