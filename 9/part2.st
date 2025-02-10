f := FileStream open: 'input' mode: FileStream read.
line := f nextLine. "only a single line input"
f close.

Object subclass: FileBlock [
    | id size |

    FileBlock >> id [
        <category: 'accessing'>
        ^id
    ]

    FileBlock >> id: anId [
        <category: 'accessing'>
        id := anId.
        ^self
    ]

    FileBlock >> id: anId size: aSize [
        <category: 'initialization'>
        id := anId.
        size := aSize.
        ^self
    ]

    FileBlock >> size [
        <category: 'accessing'>
        ^size
    ]

    FileBlock >> swap: empty blocks: blocks [
        <category: 'public'>
        | emptyIndex |
        emptyIndex := blocks indexOf: empty.
        blocks at: (blocks indexOf: self) put: (FileBlock new id: -1 size: size).
        blocks at: emptyIndex put: (FileBlock new id: id size: size).
        (empty size - size) > 0 ifTrue: [
            blocks add: (FileBlock new id: -1 size: empty size - size) afterIndex: emptyIndex.
        ].
    ]

    printOn: stream [
        <category: 'printing'>
        super printOn: stream.
        stream nextPutAll: ' id: '.
        id printOn: stream.
        stream nextPutAll: ' size: '.
        size printOn: stream.
        stream nextPutAll: '.'.
    ]
].

Object subclass: Defrag [
    | memory blocks files |

    Defrag >> line: line [
        <category: 'initialization'>
        | id reversed |
        id := 0.
        memory := OrderedCollection new.
        blocks := OrderedCollection new.
        files := OrderedCollection new.
        1 to: line size do: [:i | 
        ((i \\ 2) ~= 0)  
            ifTrue: [
                blocks add: (FileBlock new id: id size: (line at: i) digitValue).
                files add: id.
                id := id + 1.
            ]
            ifFalse: [
                ((line at: i) digitValue) > 0 ifTrue: [
                    blocks add: (FileBlock new id: -1 size: (line at: i) digitValue).
                ].
            ]
        ].

        files := files reverse.

        ^self
    ]

    Defrag >> nextEmptyBlock: size [
        <category: 'private'>
        blocks do: [:block |
            (block id = -1 and: [block size >= size])
                ifTrue: [^block].
        ].
        ^nil
    ]

    Defrag >> nextFileBlock [
        <category: 'private'>
        | nextFileId |
        files size = 0 ifTrue: [^nil].
        nextFileId := files removeFirst.
        ^blocks detect: [:block | block id = nextFileId]
    ]

    Defrag >> defrag [
        <category: 'public'>
        | nextEmpty sum i |
        
        files do: [:fileId |
            | block |
            block := blocks detect: [:block | block id = fileId].
            nextEmpty := self nextEmptyBlock: (block size).
            (nextEmpty ~= nil and: [(blocks indexOf: nextEmpty) < (blocks indexOf: block)]) ifTrue: [
                block swap: nextEmpty blocks: blocks.
            ].
        ].

        sum := 0.
        i := 0.
        blocks do: [:block |
            1 to: block size do: [:j |
                (block id ~= -1) ifTrue: [
                    sum := sum + (block id * i).
                ].
                i := i + 1.
            ].
        ].

        ^sum
    ]
].

d := Defrag new line: line.

sum := d defrag.

sum printNl.
