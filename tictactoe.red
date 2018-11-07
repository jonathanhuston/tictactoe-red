Red [
    Title:  "Tic Tac Toe"
    Author: "Jonathan Huston"
    Needs:  'View
]

#include %/usr/local/lib/red/window.red

x-offset: 114
y-offset: 115

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
            either (count = 9) [end-game none] [next-turn]
        ]
    ]
]

forever [
    tiles: empty
    player: "X"
    count: 0
    tictactoe-gui: [ 
        title "Tic Tac Toe"
        backdrop silver
        pad 5x0
        dialogue: text 328x30 center font-color red bold font-size 16 "Player X's turn"
        return
        style t: button 100x100 bold font-size 48 "" [tile face]
        t t t return
        t t t return
        t t t return
        again: button disabled "Again" [if face/enabled? [window.update face unview]
        ]
        button "Quit" [quit]
    ]
    view/options tictactoe-gui [offset: window.offset]
]
