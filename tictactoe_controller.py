#!/usr/bin/env python3
"""
Interactive Tic-Tac-Toe Controller for Verilog Simulation
Generates moves.txt file that the Verilog testbench reads
"""

import time
import os

def print_instructions():
    print("=" * 50)
    print("   INTERACTIVE TIC-TAC-TOE GAME")
    print("=" * 50)
    print("Enter moves as: x y")
    print("Example: 0 0 (for top-left corner)")
    print("Valid coordinates: 0, 1, 2")
    print("\nBoard Layout:")
    print("  0   1   2")
    print("+---+---+---+")
    print("0|   |   |   |")
    print("+---+---+---+")
    print("1|   |   |   |")
    print("+---+---+---+")
    print("2|   |   |   |")
    print("+---+---+---+")
    print("=" * 50)
    print()

def get_move(player):
    while True:
        try:
            move = input(f"Player {player} - Enter move (x y) or 'q' to quit: ").strip()
            
            if move.lower() == 'q':
                return None
            
            parts = move.split()
            if len(parts) != 2:
                print("Invalid input! Enter two numbers separated by space.")
                continue
            
            x, y = int(parts[0]), int(parts[1])
            
            if x < 0 or x > 2 or y < 0 or y > 2:
                print("Invalid coordinates! Use 0, 1, or 2.")
                continue
            
            return (x, y)
        
        except ValueError:
            print("Invalid input! Enter numbers only.")
        except KeyboardInterrupt:
            print("\nGame interrupted!")
            return None

def write_move_to_file(x, y, filename="moves.txt"):
    """Append move to file for Verilog testbench to read"""
    with open(filename, 'a') as f:
        f.write(f"{x} {y}\n")
    print(f"Move ({x}, {y}) written to {filename}")

def clear_moves_file(filename="moves.txt"):
    """Clear the moves file at start"""
    with open(filename, 'w') as f:
        f.write("")
    print(f"Cleared {filename}")

def check_winner(board, player):
    """Check if a player has won"""
    # Check rows
    for row in range(3):
        if board[row][0] == player and board[row][1] == player and board[row][2] == player:
            return True
    
    # Check columns
    for col in range(3):
        if board[0][col] == player and board[1][col] == player and board[2][col] == player:
            return True
    
    # Check diagonals
    if board[0][0] == player and board[1][1] == player and board[2][2] == player:
        return True
    if board[0][2] == player and board[1][1] == player and board[2][0] == player:
        return True
    
    return False

def check_tie(board):
    """Check if the game is a tie (board full with no winner)"""
    for row in range(3):
        for col in range(3):
            if board[row][col] == 0:
                return False
    return True

def print_current_board(board):
    """Display the current state of the board"""
    symbols = {0: ' ', 1: 'X', 2: 'O'}
    print("\nCurrent Board:")
    print("  0   1   2")
    print("+---+---+---+")
    for row in range(3):
        print(f"{row}|", end="")
        for col in range(3):
            print(f" {symbols[board[row][col]]} |", end="")
        print("\n+---+---+---+")

def main():
    print_instructions()
    
    # Clear previous moves
    clear_moves_file()
    
    print("📝 All moves will be written to moves.txt")
    print("💡 TIP: The simulation will run automatically after the game ends\n")
    
    # Initialize empty board (0 = empty, 1 = Player 1 (X), 2 = Player 2 (O))
    board = [[0, 0, 0], [0, 0, 0], [0, 0, 0]]
    
    player = 1
    move_count = 0
    moves_list = []
    game_over = False
    winner = None
    
    while not game_over:
        player_symbol = "X" if player == 1 else "O"
        
        # Show current board state
        if move_count > 0:
            print_current_board(board)
        
        move = get_move(player_symbol)
        
        if move is None:
            print("\n❌ Game cancelled by user.")
            return
        
        x, y = move
        
        # Check if position is already taken
        if board[y][x] != 0:
            print(f"❌ Position ({x}, {y}) is already taken! Try again.")
            continue
        
        # Make the move
        board[y][x] = player
        moves_list.append((x, y))
        write_move_to_file(x, y)
        move_count += 1
        
        print(f"✅ Move {move_count} saved: ({x}, {y})")
        
        # Check for winner
        if check_winner(board, player):
            game_over = True
            winner = player
            print_current_board(board)
            print("\n" + "="*50)
            if player == 1:
                print("🎉 PLAYER 1 (X) WINS! 🎉")
            else:
                print("🎉 PLAYER 2 (O) WINS! 🎉")
            print("="*50)
            break
        
        # Check for tie
        if check_tie(board):
            game_over = True
            print_current_board(board)
            print("\n" + "="*50)
            print("🤝 GAME IS A TIE! 🤝")
            print("="*50)
            break
        
        # Toggle player
        player = 2 if player == 1 else 1
    
    print("\n" + "="*50)
    print("📋 MOVES SUMMARY:")
    print("="*50)
    for i, (x, y) in enumerate(moves_list, 1):
        symbol = "X" if i % 2 == 1 else "O"
        print(f"Move {i}: Player {symbol} → ({x}, {y})")
    
    print("\n" + "="*50)
    print("✅ Game complete! Moves saved to moves.txt")
    print("="*50)

if __name__ == "__main__":
    main()
