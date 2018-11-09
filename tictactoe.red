Red [
    Title:  "Tic Tac Toe"
    Author: "Jonathan Huston"
    Needs:  'View
]

#include %/usr/local/lib/red/window.red

players: 1
human-player: "X"

; offsets for displaying tiles on board
x-offset: 114
y-offset: 115

; internal representation of empty board
empty-board: [["" "" ""] 
              ["" "" ""] 
              ["" "" ""]]


winner?: function [
    "Given board, returns winning player, else none"
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


get-tile: function [
    "Given row and column, returns tile number"
    row col
] [
    (row - 1) * 3 + col
]


find-empty-tiles: function [
    "Given board, returns array of empty tiles"
    board
] [
    result: copy []
    repeat row 3 [repeat col 3 [if board/:row/:col = "" [append result get-tile row col]]]
    result
]


computer-turn: function [
    "Given board, generates random computer move"
    board
] [
    possible-moves: find-empty-tiles board
    move: pick possible-moves random length? possible-moves
    tile: get to-word rejoin ["tile" form move]
    play-tile tile
]


play-tile: function [
    "Places player's mark on selected tile"
    "Gives computer a turn if only one human playing"
    tile    "Selected tile"
    /extern count
    /extern player
] [
    if all [(tile/text = "") (not again/enabled?)] [
        tile/text: player
        col: ((tile/offset/x) / x-offset) + 1
        row: ((tile/offset/y) / y-offset) + 1
        board/:row/:col: tile/text
        count: count + 1
        winner: winner? board player
        either any [(count = 9) winner] [
            end-game winner
        ] [
            player: next-player player
            if all [(players = 1) (player <> human-player)] [computer-turn board]
        ]
    ]
]


random/seed now/time
first-dialogue: rejoin ["Player " human-player "'s turn"]
ttt: [ 
    title "Tic Tac Toe"
    backdrop silver
    pad 5x0
    dialogue: text 328x30 center font-color red bold font-size 16 first-dialogue
    return
    style tile: button 100x100 bold font-size 48 "" [play-tile face]
    tile1: tile tile2: tile tile3: tile return
    tile4: tile tile5: tile tile6: tile return
    tile7: tile tile8: tile tile9: tile return
    again: button disabled "Again" [if face/enabled? [window.update face unview]
    ]
    button "Quit" [quit]
]

forever [
    board: copy/deep empty-board
    player: human-player
    count: 0
    view/options ttt [offset: window.offset]
]
