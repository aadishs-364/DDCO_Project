@echo off
color 0A
echo ========================================
echo    TIC-TAC-TOE COMPLETE WORKFLOW
echo ========================================
echo.

:menu
echo Choose an option:
echo 1. Enter moves (Python controller)
echo 2. Run simulation with entered moves
echo 3. Both (Enter moves then run simulation)
echo 4. Exit
echo.
set /p choice="Enter choice (1-4): "

if "%choice%"=="1" goto enter_moves
if "%choice%"=="2" goto run_sim
if "%choice%"=="3" goto both
if "%choice%"=="4" goto exit
echo Invalid choice!
goto menu

:enter_moves
echo.
echo ========================================
echo    ENTERING MOVES
echo ========================================
python tictactoe_controller.py
echo.
echo Moves entered! You can now run the simulation.
pause
goto menu

:run_sim
echo.
echo ========================================
echo    RUNNING SIMULATION
echo ========================================
echo.
echo Compiling game...
iverilog -o tictactoe_sim tictactoe.v simple_tictactoe_tb.v
if errorlevel 1 (
    echo Compilation failed!
    pause
    goto menu
)
echo Compilation successful!
echo.
echo Running game...
vvp tictactoe_sim
echo.
pause
goto menu

:both
echo.
echo ========================================
echo    STEP 1: ENTER MOVES
echo ========================================
python tictactoe_controller.py
echo.
echo ========================================
echo    STEP 2: COMPILING AND RUNNING
echo ========================================
echo.
echo Compiling game...
iverilog -o tictactoe_sim tictactoe.v simple_tictactoe_tb.v
if errorlevel 1 (
    echo Compilation failed!
    pause
    goto menu
)
echo Compilation successful!
echo.
pause
echo Running game...
vvp tictactoe_sim
echo.
pause
goto menu

:exit
echo Goodbye!
exit
