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

winner?: does [
    foreach row tiles [
        if all [(row/1 = player) (row/2 = player) (row/3 = player)] [winner: player]
    ]
    foreach col [1 2 3] [
        if all [(tiles/1/:col = player) (tiles/2/:col = player) (tiles/3/:col = player)] [winner: player]
    ]
    if all [(tiles/1/1 = player) (tiles/2/2 = player) (tiles/3/3 = player)] [winner: player]
    if all [(tiles/1/3 = player) (tiles/2/2 = player) (tiles/3/1 = player)] [winner: player]
    winner <> none
]

end-game: does [
    again/enabled?: true
    either winner [
        result/data: rejoin ["Player " winner " won!"]
    ] [
        result/data: "It's a tie!"
    ]
]

next-turn: does [
    either player = "X" [player: "O"] [player: "X"]
    result/text: rejoin ["Player " player "'s turn"]
]

tile: func [face] [
    if (face/text = "") and (not again/enabled?) [
        face/text: player
        col: ((face/offset/x) / x-offset) + 1
        row: ((face/offset/y) / y-offset) + 1
        tiles/:row/:col: face/text
        count: count + 1
        either (count = 9) or winner? [end-game] [next-turn]
    ]
]

forever [
    tiles: empty
    player: "X"
    count: 0
    winner: none
    tictactoe-gui: [ 
        title "Tic Tac Toe"
        backdrop silver
        pad 5x0
        result: text 328x30 center font-color red bold font-size 16 "Player X's turn"
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
