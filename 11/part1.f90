module stones

implicit none

type, public :: stone_t
    integer(8) :: value = 0
    type(stone_t), pointer :: next => null()
contains
    procedure :: insert
end type

type, public :: stones_list_t
private
    integer(8) :: size = 0
    type(stone_t), pointer :: head => null()
    type(stone_t), pointer :: tail => null()
contains
    procedure :: length
    procedure :: traverse
    procedure :: append
end type

abstract interface
    subroutine traverse_callback(stone, stones_list)
        import :: stone_t
        import :: stones_list_t
        class(stone_t), pointer, intent(inout) :: stone
        class(stones_list_t), intent(inout) :: stones_list
    end subroutine
end interface

contains

function length(this) result(size)
    class(stones_list_t), intent(in) :: this
    integer(8) :: size

    size = this%size
end function

! insert a new stone after the current one
subroutine insert(this, stones, val)
    class(stone_t), intent(inout) :: this
    class(stones_list_t), intent(inout) :: stones
    integer(8), intent(in) :: val
    
    class(stone_t), pointer :: new

    allocate(new)
    new%value = val

    if (associated(this%next)) then
        new%next => this%next
    end if

    this%next = new

    stones%size = stones%size + 1
end subroutine

subroutine append(this, val)
    class(stones_list_t), intent(inout) :: this
    integer(8), intent(in) :: val

    class(stone_t), pointer :: new

    allocate(new)
    new%value = val

    if (associated(this%tail)) then
        this%tail%next => new
    else
        ! head and tail are null
        this%head => new
    end if

    this%tail => new
    this%size = this%size + 1

end subroutine

subroutine traverse(this, callback)
    class(stones_list_t), intent(inout) :: this
    procedure(traverse_callback) :: callback

    class(stone_t), pointer :: current, tmp => null()
    
    current => this%head
    do while (associated(current))
        tmp => current%next
        call callback(current, this)
        current => tmp
        nullify(tmp)
    end do
end subroutine

end module stones

program part1_program
    use stones

    implicit none ! without this, variables will be implicitly typed according to their first letter

    integer :: n = 25
    type(stones_list_t) :: list
    integer :: i

    ! just store the input in the code directly rather than reading in a file
    ! example: 125 17
    ! input: 2701 64945 0 9959979 93 781524 620 1
    call list%append(2701_8)
    call list%append(64945_8)
    call list%append(0_8)
    call list%append(9959979_8)
    call list%append(93_8)
    call list%append(781524_8)
    call list%append(620_8)
    call list%append(1_8)

    do i = 1, n
        call list%traverse(process)
    end do
    
    print *, list%length()

contains
    subroutine process(stone, stones_list)
        class(stone_t), pointer, intent(inout) :: stone
        class(stones_list_t), intent(inout) :: stones_list
        integer(8) :: digits, left_value, right_value, divisor
        
        digits = floor(log10(real(stone%value))) + 1

        if (stone%value == 0) then
            stone%value = 1
        else if (mod(digits, 2) == 0) then
            divisor = 10**(digits/2)
            left_value = stone%value / divisor
            right_value = mod(stone%value, divisor)
            stone%value = left_value
            call stone%insert(stones_list, right_value)
        else
            stone%value = stone%value * 2024
        end if
    end subroutine

end program part1_program
