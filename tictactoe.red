Red [
    Title:  "Tic Tac Toe"
    Author: "Jonathan Huston"
    Needs:  'View
]

#include %/usr/local/lib/red/window.red

FIRST-PLAYER: "X"

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


update-board: function [
    "Given board, player, and move, updates board"
    board player move
] [
    col: (move - 1) % 3 + 1
    row: (move - 1) / 3 + 1
    board/:row/:col: player
]


opponent: function [
    "Returns other player"
    player
] [
    either player = "X" [return "O"] [return "X"]
]


next-player: function [
    "Switches to next player, updating display"
    player
] [
    player: opponent player
    dialogue/text: rejoin ["Player " player "'s turn"]
    player
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
    again/enabled?: true
    computer-move/enabled?: false
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


find-empty-squares: function [
    "Given board, returns array of empty square numbers"
    board
] [
    empty-squares: copy []
    repeat row 3 [repeat col 3 [if board/:row/:col = "" [append empty-squares get-square-num row col]]]
    empty-squares
]


evaluate: function [
    "Generates score for a given board"
    board player count maximizing
] [
    either maximizing [win: 1] [win: -1]
    if ((winner? board player) <> []) [return win]
    if count = 9 [return 0]
    score: second minimax board (opponent player) count (not maximizing)
]


minimax: function [
    "Given board, finds best move using minimax"
    board player count 
    maximizing  "is this the maximizing player?"
] [
    possible-moves: find-empty-squares board
    either maximizing [best-score: -10] [best-score: 10]
    foreach move possible-moves [
        test-board: copy/deep board
        update-board test-board player move
        score: evaluate test-board player (count + 1) maximizing
        if any [all [maximizing (score > best-score)] all [(not maximizing) (score < best-score)]] [
            best-move: move
            best-score: score
        ]
    ]
    reduce [best-move best-score]
]


computer-turn: function [
    "Generates computer move"
    /extern board player count
] [
    move: first minimax board player count true
    square: get to-word rejoin ["square" form move]
    play-square square
]


play-square: function [
    "Places player's mark on selected square and checks for winner"
    square  
    /extern board player count
] [
    if all [(square/text = "") (not again/enabled?)] [
        square/text: player
        update-board board player square/extra
        count: count + 1
        winning-line: winner? board player
        either any [(count = 9) (winning-line <> [])] [
            end-game winning-line player
        ] [
            player: next-player player
        ]
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
        append ttt reduce [square-set-word 'button 100x100 'bold 'font-size 48 "" 'extra square-num [play-square face]]
        if square-num % 3 = 0 [append ttt 'return]
    ]

    append ttt reduce [to-set-word "computer-move" 'button "Computer Move" [if face/enabled? [computer-turn]]]
    append ttt reduce [to-set-word "again" 'button 'disabled "Again?" [if face/enabled? [window.update face unview]]
    
    ]
    append ttt reduce ['button "Quit" [quit]]
]


random/seed now/time
forever [
    board: copy/deep empty-board
    player: FIRST-PLAYER
    count: 0
    ttt: layout init-ttt
    view/options ttt [offset: window.offset]
]
