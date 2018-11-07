Red [
    Title:  "Tic Tac Toe"
    Author: "Jonathan Huston"
    Needs:  'View
]

#include %/usr/local/lib/red/window.red

players: 1

x-offset: 114
y-offset: 115

; creates internal represenation of empty board
empty: does [
    reduce [copy ["" "" ""] 
            copy ["" "" ""] 
            copy ["" "" ""]]
]

; given tiles, has player won?
winner?: function [tiles player] [
    result: false
    foreach row tiles [
        if all [(row/1 = player) (row/2 = player) (row/3 = player)] [result: true]
    ]
    foreach col [1 2 3] [
        if all [(tiles/1/:col = player) (tiles/2/:col = player) (tiles/3/:col = player)] [result: true]
    ]
    if all [(tiles/1/1 = player) (tiles/2/2 = player) (tiles/3/3 = player)] [result: true]
    if all [(tiles/1/3 = player) (tiles/2/2 = player) (tiles/3/1 = player)] [result: true]
    result
]

; displays end-of-game dialogue
end-game: func [winner] [
    again/enabled?: true
    either winner [
        dialogue/data: rejoin ["Player " winner " won!"]
    ] [
        dialogue/data: "It's a tie!"
    ]
]

next-turn: does [
    either player = "X" [player: "O"] [player: "X"]
    dialogue/text: rejoin ["Player " player "'s turn"]
]

; given row and column, returns tile number
get-tile: function [row col] [
    (row - 1) * 3 + col
]

; returns array of empty tiles
find-empty: function [tiles] [
    result: copy []
    foreach row [1 2 3] [
        foreach col [1 2 3] [
            if tiles/:row/:col = "" [append result get-tile row col]
        ]
    ]
    result
]

; generates computer turn
computer-turn: does [
    possible-moves: find-empty tiles
    move: pick possible-moves random length? possible-moves
    switch move [
        1 [face: t1]
        2 [face: t2]
        3 [face: t3]
        4 [face: t4]
        5 [face: t5]
        6 [face: t6]
        7 [face: t7]
        8 [face: t8]
        9 [face: t9]
    ]
    tile face
]

tile: func [face] [
    if (face/text = "") and (not again/enabled?) [
        face/text: player
        col: ((face/offset/x) / x-offset) + 1
        row: ((face/offset/y) / y-offset) + 1
        tiles/:row/:col: face/text
        count: count + 1
        either winner? tiles player [
            end-game player
        ] [
            either (count = 9) [
                end-game none
            ] [
                next-turn
                if (players = 1) and (player = "O") [computer-turn]
            ]
        ]
    ]
]

forever [
    tiles: empty
    player: "X"
    count: 0
    ttt: [ 
        title "Tic Tac Toe"
        backdrop silver
        pad 5x0
        dialogue: text 328x30 center font-color red bold font-size 16 "Player X's turn"
        return
        style t: button 100x100 bold font-size 48 "" [tile face]
        t1: t t2: t t3: t return
        t4: t t5: t t6: t return
        t7: t t8: t t9: t return
        again: button disabled "Again" [if face/enabled? [window.update face unview]
        ]
        button "Quit" [quit]
    ]
    view/options ttt [offset: window.offset]
]
