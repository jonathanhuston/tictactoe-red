Red [
    Title:  "Tic Tac Toe"
    Author: "Jonathan Huston"
    Needs:  'View
]

#include %/usr/local/lib/red/window.red

players: 1
human-player: "X"
delay: 0.5

; internal representation of empty board
empty-board: [["" "" ""] 
              ["" "" ""] 
              ["" "" ""]]


get-square-num: function [
    "Given row and column, returns square number"
    row col
] [
    (row - 1) * 3 + col
]


winner?: function [
    "Given board, returns winning line if winner, else []"
    board   "Current board"
    player  "Current player"
] [
    winning-line: copy []
    repeat row 3 [
        if all [(board/:row/1 = player) (board/:row/2 = player) (board/:row/3 = player)] [
            append winning-line reduce [get-square-num row 1 get-square-num row 2 get-square-num row 3]
        ]
    ]
    repeat col 3 [
        if all [(board/1/:col = player) (board/2/:col = player) (board/3/:col = player)] [
            append winning-line reduce [get-square-num 1 col get-square-num 2 col get-square-num 3 col]
        ]
    ]
    if all [(board/1/1 = player) (board/2/2 = player) (board/3/3 = player)] [append winning-line [1 5 9]]
    if all [(board/1/3 = player) (board/2/2 = player) (board/3/1 = player)] [append winning-line [3 5 7]]
    winning-line
]


end-game: function [
    "Displays end-of-game dialogue"
    winning-line "Winning line, [] if tie"
    player       "Last player"
] [
    zero/enabled?: true
    one/enabled?: true
    two/enabled?: true
    dialogue/font/color: red
    either (winning-line <> []) [
        foreach square-num winning-line [
            square: get to-word rejoin ["square" form square-num]
            square/font/color: red
        ]
        dialogue/text: rejoin ["Player " player " won!"]
    ] [
        dialogue/text: "It's a tie!"
    ]
]


next-player: function [
    "Switches to next player"
    player
] [
    either player = "X" [player: "O"] [player: "X"]
    dialogue/text: rejoin ["Player " player "'s turn"]
    player
]


find-empty-squares: function [
    "Given board, returns array of empty square numbers"
    board
] [
    empty-squares: copy []
    repeat row 3 [repeat col 3 [if board/:row/:col = "" [append empty-squares get-square-num row col]]]
    empty-squares
]


computer-turn: function [
    "Given board, generates random computer move"
    board
] [
    possible-moves: find-empty-squares board
    move: pick possible-moves random length? possible-moves
    square: get to-word rejoin ["square" form move]
    play-square square
]


play-square: function [
    "Places player's mark on selected square and checks for winner"
    square  
    /extern board player count
] [
    if all [(square/text = "") (not zero/enabled?)] [
        square/text: player
        col: ((square/offset/x) / (square/size/x + 10)) + 1
        row: ((square/offset/y) / (square/size/y + 10)) + 1
        board/:row/:col: player
        count: count + 1
        winning-line: winner? board player
        either any [(count = 9) (winning-line <> [])] [
            end-game winning-line player
        ] [
            player: next-player player
        ]
    ]
]


next-turn: function [
    "Gives next turn to human [and then computer]"
    board
    square
] [
    play-square square
    if all [(players <> 2) (player <> human-player) (not zero/enabled?)] [
        view ttt
        wait delay
        computer-turn board
    ]
]


init-ttt: does [
    ttt: copy [ 
        title "Tic Tac Toe"
        backdrop silver
        pad 5x0
        do [dialogue-text: rejoin ["Player " player "'s turn"]]
        dialogue: text 328x30 center font-color black bold font-size 16 dialogue-text
        return
    ]

    repeat square-num 9 [
        square-set-word: to-set-word rejoin ["square" form square-num ":"]
        append ttt reduce [square-set-word 'button 100x100 'bold 'font-size 48 "" [next-turn board face]]
        if square-num % 3 = 0 [append ttt 'return]
    ]

    append ttt reduce [to-set-word "zero" 'button 'disabled "0 players" [if face/enabled? [window.update face unview]]
                       to-set-word "one"  'button 'disabled "1 player"  [if face/enabled? [window.update face unview]]
                       to-set-word "two"  'button 'disabled "2 players" [if face/enabled? [window.update face unview]]
    
    ]
    append ttt reduce ['button "Quit" [quit]]
]


random/seed now/time
forever [
    board: copy/deep empty-board
    player: human-player
    count: 0
    ttt: layout init-ttt
    view/options ttt [offset: window.offset]
]
