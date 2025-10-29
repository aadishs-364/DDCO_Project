// simple_tictactoe_tb.v
// Simpler testbench that reads all moves at once and displays the game

module simple_tictactoe_tb;

    localparam CLK_PERIOD = 10;

    reg clk;
    reg rst_n;
    reg [3:0] x_in;
    reg [3:0] y_in;
    reg make_move;

    wire [1:0] winner;
    wire tie;
    wire [17:0] board;

    reg [1:0] tb_board [0:2][0:2];
    integer i, j;
    integer input_file;
    integer scan_result;
    reg [3:0] temp_x, temp_y;
    integer move_num;

    tictactoe mut (
        .clk(clk),
        .rst_n(rst_n),
        .x_in(x_in),
        .y_in(y_in),
        .make_move(make_move),
        .winner(winner),
        .tie(tie),
        .board(board)
    );

    // Unpack row-major board
    always @(board) begin
        tb_board[0][0] = board[17:16];
        tb_board[0][1] = board[15:14];
        tb_board[0][2] = board[13:12];
        tb_board[1][0] = board[11:10];
        tb_board[1][1] = board[9:8];
        tb_board[1][2] = board[7:6];
        tb_board[2][0] = board[5:4];
        tb_board[2][1] = board[3:2];
        tb_board[2][2] = board[1:0];
    end

    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    initial begin
        $dumpfile("tictactoe.vcd");
        $dumpvars(0, simple_tictactoe_tb);
        
        $display("========================================");
        $display("   INTERACTIVE TIC-TAC-TOE GAME");
        $display("========================================");
        $display("Reading moves from 'moves.txt'...\n");

        // Initialize game
        rst_n = 0; make_move = 0; x_in = 0; y_in = 0;
        #(CLK_PERIOD*2);
        rst_n = 1;
        #(CLK_PERIOD*2);

        $display("Initial Board:");
        print_board();

        // Open input file
        input_file = $fopen("moves.txt", "r");
        if (input_file == 0) begin
            $display("ERROR: Could not open moves.txt");
            $display("Please create moves.txt with your moves!");
            $finish;
        end

        move_num = 0;

        // Read and play moves
        while (!$feof(input_file) && winner == 2'b00 && !tie && move_num < 9) begin
            scan_result = $fscanf(input_file, "%d %d\n", temp_x, temp_y);
            
            if (scan_result == 2) begin
                if (temp_x <= 2 && temp_y <= 2) begin
                    move_num = move_num + 1;
                    $display("\n========================================");
                    $display("Move %0d: Player %s - (%0d, %0d)", 
                             move_num, 
                             (move_num % 2 == 1) ? "X" : "O",
                             temp_x, temp_y);
                    $display("========================================");
                    
                    make_move_at(temp_x, temp_y);
                    print_board();
                    
                    // Check game status
                    if (winner == 2'b01) begin
                        $display("\n========================================");
                        $display("   PLAYER 1 (X) WINS!");
                        $display("========================================\n");
                        $fclose(input_file);
                        $finish;
                    end else if (winner == 2'b10) begin
                        $display("\n========================================");
                        $display("   PLAYER 2 (O) WINS!");
                        $display("========================================\n");
                        $fclose(input_file);
                        $finish;
                    end else if (tie) begin
                        $display("\n========================================");
                        $display("   GAME IS A TIE!");
                        $display("========================================\n");
                        $fclose(input_file);
                        $finish;
                    end
                end else begin
                    $display("ERROR: Invalid coordinates (%0d, %0d)! Use 0-2.", temp_x, temp_y);
                end
            end
        end

        $fclose(input_file);
        
        if (winner == 2'b00 && !tie) begin
            $display("\n========================================");
            $display("Game incomplete. Add more moves to continue!");
            $display("========================================");
        end
        
        $finish;
    end

    // Task to make a move
    task make_move_at(input [3:0] x, input [3:0] y);
        begin
            @(posedge clk);
            x_in = x;
            y_in = y;
            make_move = 1;
            @(posedge clk);
            make_move = 0;
            @(posedge clk);
            @(posedge clk); // Extra cycles for FSM
            @(posedge clk);
        end
    endtask

    // Print task
    task print_board;
        begin
            $display("\n  0   1   2");
            $display("+---+---+---+");
            for (i = 0; i < 3; i = i + 1) begin
                $write("%0d|", i);
                for (j = 0; j < 3; j = j + 1) begin
                    if (tb_board[i][j] == 2'b01) $write(" X |");
                    else if (tb_board[i][j] == 2'b10) $write(" O |");
                    else $write("   |");
                end
                $display("\n+---+---+---+");
            end
        end
    endtask

endmodule
