Red [
    Title:  "Tic Tac Toe"
    Author: "Jonathan Huston"
    Needs:  'View
]

forever [
    is-x?: true
    count: 0
    view [ 
        title "Tic Tac Toe"
        backdrop silver
        style t: button 100x100 bold font-size 48 "" [
            if (face/text = "") and (not again/enabled?) [
                either is-x? [
                    face/text: "X"
                ] [
                    face/text: "O"
                ]
                count: count + 1
                is-x?: not is-x?
                if count = 9 [again/enabled?: true]
            ]
        ] 
        t t t return
        t t t return
        t t t return
        again: button disabled "Again" [if face/enabled? [unview]]
        button "Quit" [quit]
    ]
]
