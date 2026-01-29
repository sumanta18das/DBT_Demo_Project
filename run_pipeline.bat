@echo off
echo ------------------------------------------------
echo STEP 1: Cleaning up old artifacts...
echo ------------------------------------------------
call dbt clean

echo ------------------------------------------------
echo STEP 2: Reinstalling Packages (dbt_utils)...
echo ------------------------------------------------
call dbt deps

echo ------------------------------------------------
echo STEP 3: Running Medallion Pipeline (Build)...
echo ------------------------------------------------
call dbt build

echo ------------------------------------------------
echo STEP 4: Generating Documentation...
echo ------------------------------------------------
call dbt docs generate

echo ------------------------------------------------
echo STEP 5: Opening Browser and Starting Server...
echo ------------------------------------------------
:: This line opens your default browser to the docs page
start "" "http://localhost:8080"

echo Your documentation is loading... To stop the server, press Ctrl+C
call dbt docs serve

pause