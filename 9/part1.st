f := FileStream open: 'input' mode: FileStream read.
line := f nextLine. "only a single line input"
f close.

id := 0.
memory := OrderedCollection new.
1 to: line size do: [:i | ((i \\ 2) ~= 0)  
    ifTrue: [
        1 to: ((line at: i) digitValue) do: [:j | memory add: id].
        id := id + 1.
    ]
    ifFalse: [
        1 to: ((line at: i) digitValue) do: [:j | memory add: -1]
    ]
].

nextEmpty := memory findFirst: [:x | x == -1 ].
nextIndex := memory findLast: [:x | x ~= -1].

[nextEmpty < (nextIndex + 1)] whileTrue: [
    memory at: nextEmpty put: (memory at: nextIndex).
    memory at: nextIndex put: -1.

    nextEmpty := memory findFirst: [:x | x == -1 ].
    nextIndex := memory findLast: [:x | x ~= -1].
].

sum := 0.
1 to: memory size do: [:i | ((memory at: i) ~= -1)
    ifTrue: [sum := sum + ((i - 1) * (memory at: i))]].

sum printNl.
