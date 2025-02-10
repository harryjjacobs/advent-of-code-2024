module linked_list
implicit none

type, public :: linked_list_node_t
    class(*), pointer :: value => null()
    type(linked_list_node_t), pointer :: next => null()
contains
    procedure :: insert
end type

type, public :: linked_list_t
private
    integer(8) :: size = 0
    type(linked_list_node_t), pointer :: head => null()
    type(linked_list_node_t), pointer :: tail => null()
contains
    procedure :: length
    procedure :: traverse
    procedure :: append
    procedure :: search
end type

abstract interface
    subroutine traverse_callback(node)
        import :: linked_list_node_t
        class(linked_list_node_t), pointer, intent(inout) :: node
    end subroutine
end interface

abstract interface
    function search_callback(node, data) result(success)
        import :: linked_list_node_t
        class(linked_list_node_t), pointer, intent(inout) :: node
        class(*), pointer, intent(in) :: data
        logical :: success
    end function
end interface

contains

function length(this) result(size)
    class(linked_list_t), intent(in) :: this
    integer(8) :: size

    size = this%size
end function

! insert a new node after the current one
subroutine insert(this, list, val)
    class(linked_list_node_t), intent(inout) :: this
    class(linked_list_t), intent(inout) :: list
    class(*), pointer, intent(in) :: val
    
    class(linked_list_node_t), pointer :: new

    allocate(new)
    new%value => val

    if (associated(this%next)) then
        new%next => this%next
    end if

    this%next = new

    list%size = list%size + 1
end subroutine

subroutine append(this, val)
    class(linked_list_t), intent(inout) :: this
    class(*), pointer, intent(in) :: val

    class(linked_list_node_t), pointer :: new

    allocate(new)
    new%value => val

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
    class(linked_list_t), intent(inout) :: this
    procedure(traverse_callback) :: callback

    class(linked_list_node_t), pointer :: current, tmp => null()
    
    current => this%head
    do while (associated(current))
        tmp => current%next
        call callback(current)
        current => tmp
        nullify(tmp)
    end do
end subroutine

function search(this, callback, data) result(val)
    class(linked_list_t), intent(inout) :: this
    class(*), pointer, intent(in) :: data
    procedure(search_callback) :: callback

    class(*), pointer :: val

    class(linked_list_node_t), pointer :: current, tmp => null()
    logical :: found = .false.

    current => this%head
    do while (associated(current))
        tmp => current%next
        found = callback(current, data)
        if (found) then
            val => current%value
            return
        end if
        current => tmp
        nullify(tmp)
    end do

    val => null()

end function

end module linked_list

module part2
    implicit none

    type, public :: keyvalue_t
        integer(8) :: key
        integer(8) :: value
    end type
end module part2

program part2_program
    use linked_list
    use part2

    implicit none ! without this, variables will be implicitly typed according to their first letter
    
    type(linked_list_t) :: input_list
    type(linked_list_t) :: cache

    integer(8) :: n = 75
    integer(8) :: sum = 0

    ! just store the input in the code directly rather than reading in a file
    ! example: 125 17
    ! call append_integer(input_list, 125_8)
    ! call append_integer(input_list, 17_8)

    ! input: 2701 64945 0 9959979 93 781524 620 1
    call append_integer(input_list, 2701_8)
    call append_integer(input_list, 64945_8)
    call append_integer(input_list, 0_8)
    call append_integer(input_list, 9959979_8)
    call append_integer(input_list, 93_8)
    call append_integer(input_list, 781524_8)
    call append_integer(input_list, 620_8)
    call append_integer(input_list, 1_8)

    call input_list%traverse(process)
    
    print *, sum

contains
    subroutine append_keyvalue(list, val)
        class(linked_list_t), intent(inout) :: list
        type(keyvalue_t), intent(in) :: val
        class(*), pointer :: val_ptr

        allocate(val_ptr, source=val)

        call list%append(val_ptr)
    end subroutine

    subroutine append_integer(list, val)
        class(linked_list_t), intent(inout) :: list
        integer(8), intent(in) :: val
        class(*), pointer :: val_ptr

        allocate(val_ptr, source=val)

        call list%append(val_ptr)
    end subroutine

    function pointer_to_int(ptr) result(res)
        class(*), pointer, intent(in) :: ptr
        integer(8) :: res

        select type(ptr)
        type is (integer(8))
            res = ptr
        class default
            print *, "Error: Unexpected type!"
        end select
    end function

    function pointer_to_keyvalue(ptr) result(res)
        class(*), pointer, intent(in) :: ptr
        type(keyvalue_t) :: res

        select type(ptr)
        type is (keyvalue_t)
            res = ptr
        class default
            print *, "Error: Unexpected type!"
        end select
    end function

    function cache_search_callback(node, data) result(success)
        class(linked_list_node_t), pointer, intent(inout) :: node
        class(*), pointer, intent(in) :: data
        logical :: success

        class(*), pointer :: kv_ptr
        type(keyvalue_t) :: kv
        integer(8) key

        kv_ptr => node%value
        kv = pointer_to_keyvalue(kv_ptr)
        key = pointer_to_int(data)

        if (kv%key == key) then
            success = .true.
        else
            success = .false.
        end if
    end function

    function hash(val1, val2) result(hashed)
        integer(8), intent(in) :: val1
        integer(8), intent(in) :: val2
        integer(8) :: hashed
        
        ! http://szudzik.com/ElegantPairing.pdf
        if (val1 >= val2) then
            hashed = val1 * val1 + val1 + val2
        else
            hashed = val1 + val2 * val2
        end if
    end function

    subroutine process(stone)
        class(linked_list_node_t), pointer, intent(inout) :: stone
        integer(8) :: val

        val = pointer_to_int(stone%value)
        sum = sum + process_recurse(val, n)
    end subroutine

    recursive function process_recurse(val, remaining) result(count)
        integer(8), intent(in) :: val
        integer(8), intent(in) :: remaining
        class(*), pointer :: cached_ptr, search_key_ptr
        type(keyvalue_t) :: cached
        integer(8) :: count, digits, divisor, left_val, right_val

        allocate(search_key_ptr, source=hash(val, remaining))
        cached_ptr => cache%search(cache_search_callback, search_key_ptr)
        if (associated(cached_ptr)) then
            cached = pointer_to_keyvalue(cached_ptr)
            count = cached%value
            return
        end if

        if (remaining == 0) then
            count = 1
            return
        end if

        digits = floor(log10(real(val))) + 1

        if (val == 0) then
            count = process_recurse(1_8, remaining - 1)
        else if (mod(digits, 2) == 0) then
            divisor = 10**(digits/2)
            left_val = val / divisor
            right_val = mod(val, divisor)
            count = process_recurse(right_val, remaining - 1) + &
                    process_recurse(left_val, remaining - 1)
        else
            count = process_recurse(val * 2024, remaining - 1)
        end if

        if (.not. associated(cached_ptr)) then
            cached%key = hash(val, remaining)
            cached%value = count
            allocate(cached_ptr, source=cached)
            call cache%append(cached_ptr)
        end if
    end function

end program part2_program
