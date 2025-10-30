// tictactoe.v
// A simple Tic-Tac-Toe game module
// A simple state machine to control the game flow

module tictactoe (
    input clk,               // Clock input
    input rst_n,             // Asynchronous active-low reset
    input [3:0] x_in, y_in,  // X and Y coordinates for a move (0-2)
    input make_move,         // Flag to signal a player's move
    output reg [1:0] winner, // 00: No winner, 01: Player 1 wins, 10: Player 2 wins
    output reg tie,          // 1: Game is a tie, 0: Game is not a tie
    output [17:0] board      // 3x3 board state as a packed array (2 bits per square)
);

    // States for the FSM
    localparam S_IDLE       = 3'b000;
    localparam S_P1_TURN    = 3'b001;
    localparam S_P2_TURN    = 3'b010;
    localparam S_CHECK_WIN  = 3'b011;
    localparam S_END_GAME   = 3'b100;

    reg [2:0] state;
    reg [1:0] player_turn; // 01 for Player 1, 10 for Player 2
    reg [3:0] moves_count; // Tracks the number of moves

    // Internal representation of the board as row-major [row][col]
    reg [1:0] unpacked_board [0:2][0:2];

    integer i, j;

    // Initialize loop variables to avoid X states in simulation
    initial begin
        i = 0;
        j = 0;
    end

    // Initialize board on reset and update game state
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= S_IDLE;
            player_turn <= 2'b01;
            winner <= 2'b00;
            tie <= 1'b0;
            moves_count <= 4'b0000;
            // Clear the board
            for (i = 0; i < 3; i = i + 1) begin
                for (j = 0; j < 3; j = j + 1) begin
                    unpacked_board[i][j] <= 2'b00;
                end
            end
        end else begin
            case(state)
                S_IDLE: begin
                    state <= S_P1_TURN;
                end

                S_P1_TURN: begin
                    if (make_move) begin
                        if (unpacked_board[y_in][x_in] == 2'b00) begin
                            unpacked_board[y_in][x_in] <= 2'b01; // Player 1
                            moves_count <= moves_count + 1;
                            state <= S_CHECK_WIN;
                            player_turn <= 2'b10;
                        end
                    end
                end

                S_P2_TURN: begin
                    if (make_move) begin
                        if (unpacked_board[y_in][x_in] == 2'b00) begin
                            unpacked_board[y_in][x_in] <= 2'b10; // Player 2
                            moves_count <= moves_count + 1;
                            state <= S_CHECK_WIN;
                            player_turn <= 2'b01;
                        end
                    end
                end

                S_CHECK_WIN: begin
                    if (check_win(2'b01)) begin
                        winner <= 2'b01;
                        state <= S_END_GAME;
                    end else if (check_win(2'b10)) begin
                        winner <= 2'b10;
                        state <= S_END_GAME;
                    end else if (moves_count == 9) begin
                        tie <= 1'b1;
                        state <= S_END_GAME;
                    end else begin
                        state <= (player_turn == 2'b01) ? S_P1_TURN : S_P2_TURN;
                    end
                end

                S_END_GAME: begin
                    // Game is over, wait for reset
                end
            endcase
        end
    end

    // Assign the unpacked board to the packed output (row-major order)
    assign board = {
        unpacked_board[0][0], unpacked_board[0][1], unpacked_board[0][2],
        unpacked_board[1][0], unpacked_board[1][1], unpacked_board[1][2],
        unpacked_board[2][0], unpacked_board[2][1], unpacked_board[2][2]
    };

    // Function to check for a winner
    function check_win;
        input [1:0] player;
        reg temp_winner;
        integer x, y;  // Local loop variables
        begin
            temp_winner = 1'b0;
            // Check rows
            for (y = 0; y < 3; y = y + 1) begin
                if (unpacked_board[y][0] == player && unpacked_board[y][1] == player && unpacked_board[y][2] == player) begin
                    temp_winner = 1'b1;
                end
            end
            // Check columns
            for (x = 0; x < 3; x = x + 1) begin
                if (unpacked_board[0][x] == player && unpacked_board[1][x] == player && unpacked_board[2][x] == player) begin
                    temp_winner = 1'b1;
                end
            end
            // Check diagonals
            if (unpacked_board[0][0] == player && unpacked_board[1][1] == player && unpacked_board[2][2] == player) begin
                temp_winner = 1'b1;
            end
            if (unpacked_board[0][2] == player && unpacked_board[1][1] == player && unpacked_board[2][0] == player) begin
                temp_winner = 1'b1;
            end
            check_win = temp_winner;
        end
    endfunction
endmodule
