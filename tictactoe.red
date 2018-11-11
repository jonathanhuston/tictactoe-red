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


winner?: function [
    "Given board, returns player if winner, else none"
    board   "Current board"
    player  "Current player"
] [
    winner: none
    foreach row board [
        if all [(row/1 = player) (row/2 = player) (row/3 = player)] [winner: player]
    ]
    repeat col 3 [
        if all [(board/1/:col = player) (board/2/:col = player) (board/3/:col = player)] [winner: player]
    ]
    if all [(board/1/1 = player) (board/2/2 = player) (board/3/3 = player)] [winner: player]
    if all [(board/1/3 = player) (board/2/2 = player) (board/3/1 = player)] [winner: player]
    winner
]


end-game: function [
    "Displays end-of-game dialogue"
    winner  "Winning player, none if tie"
] [
    again/enabled?: true
    dialogue/font/color: red
    either winner [
        dialogue/text: rejoin ["Player " winner " won!"]
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


get-square-num: function [
    "Given row and column, returns square number"
    row col
] [
    (row - 1) * 3 + col
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
    /extern player count
] [
    if all [(square/text = "") (not again/enabled?)] [
        square/text: player
        col: ((square/offset/x) / (square/size/x + 10)) + 1
        row: ((square/offset/y) / (square/size/y + 10)) + 1
        board/:row/:col: player
        count: count + 1
        winner: winner? board player
        either any [(count = 9) winner] [
            end-game winner
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
    if all [(players <> 2) (player <> human-player) (not again/enabled?)] [
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

    append ttt reduce [to-set-word "again" 'button 'disabled "Again" [if face/enabled? [window.update face unview]]]
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
