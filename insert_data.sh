#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Truncate tables before inserting
echo "$($PSQL "TRUNCATE games, teams RESTART IDENTITY")"

# Insert unique teams
cat games.csv | tail -n +2 | cut -d',' -f3,4 | tr ',' '\n' | sort | uniq | while read TEAM
do
  if [[ -n $TEAM ]]
  then
    # Insert team if not exists
    echo "$($PSQL "INSERT INTO teams(name) VALUES('$TEAM') ON CONFLICT (name) DO NOTHING")"
  fi
done

# Insert games
cat games.csv | tail -n +2 | while IFS=',' read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # Get team ids
  WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
  OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
  # Insert game
  echo "$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")"
done
