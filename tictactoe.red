Red [
    Title:  "Tic Tac Toe"
    Author: "Jonathan Huston"
    Needs:  'View
]

#include %/usr/local/lib/red/window.red

players: 1
human-player: "X"
delay: 0.5

; offsets for displaying squares on board
x-offset: 114
y-offset: 115

; internal representation of empty board
empty-board: [["" "" ""] 
              ["" "" ""] 
              ["" "" ""]]


winner?: function [
    "Given board, returns player if winner, else none"
    board   "Current board"
    player  "Current player"
] [
    result: none
    foreach row board [
        if all [(row/1 = player) (row/2 = player) (row/3 = player)] [result: player]
    ]
    repeat col 3 [
        if all [(board/1/:col = player) (board/2/:col = player) (board/3/:col = player)] [result: player]
    ]
    if all [(board/1/1 = player) (board/2/2 = player) (board/3/3 = player)] [result: player]
    if all [(board/1/3 = player) (board/2/2 = player) (board/3/1 = player)] [result: player]
    result
]


end-game: function [
    "Displays end-of-game dialogue"
    winner  "Winning player, none if tie"
] [
    again/enabled?: true
    either winner [
        dialogue/data: rejoin ["Player " winner " won!"]
    ] [
        dialogue/data: "It's a tie!"
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
    result: copy []
    repeat row 3 [repeat col 3 [if board/:row/:col = "" [append result get-square-num row col]]]
    result
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


update-ttt: function [
    "Updates GUI layout with player's mark"
    square-num
    player
] [
    square-set-word: to-set-word rejoin ["square" form square-num ":"]
    replace ttt reduce [square-set-word 'button 100x100 'bold 'font-size 48 ""] 
                reduce [square-set-word 'button 100x100 'bold 'font-size 48 player]
]


play-square: function [
    "Places player's mark on selected square and checks for winner"
    square    "Selected square"
    /extern count
    /extern player
] [
    if all [(square/text = "") (not again/enabled?)] [
        square/text: player
        col: ((square/offset/x) / x-offset) + 1
        row: ((square/offset/y) / y-offset) + 1
        board/:row/:col: player
        update-ttt (get-square-num row col) player
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
    "Gives next turn to human or computer"
    board
    square
] [
    play-square square
    if all [(players <> 2) (player <> human-player) (not again/enabled?)] [
        window.update square unview
        view/options ttt [offset: window.offset]
        wait delay
        computer-turn board
    ]
]


initialize: does [
    random/seed now/time
    board: copy/deep empty-board
    player: human-player
    count: 0

    ttt: copy [ 
        title "Tic Tac Toe"
        backdrop silver
        pad 5x0
        do [dialogue-text: rejoin ["Player " player "'s turn"]]
        dialogue: text 328x30 center font-color red bold font-size 16 dialogue-text
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

forever [
    initialize
    view/options ttt [offset: window.offset]
]
