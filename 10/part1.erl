-module(part1).

-export([main/0]).

read_file_to_2d_array(FilePath) ->
    case file:read_file(FilePath) of
        {ok, BinaryContent} ->
            Lines = binary:split(BinaryContent, <<"\n">>, [global, trim]),
            lists:map(fun line_to_row/1, Lines);
        {error, Reason} ->
            io:format("Error reading file: ~p~n", [Reason]),
            []
    end.

line_to_row(Line) ->
    lists:map(fun char_to_number/1, binary_to_list(Line)).

char_to_number(Char) when Char >= $0, Char =< $9 ->
    Char - $0.

get_cell(Grid, X, Y) when X > 0, Y > 0, X =< length(Grid), Y =< length(Grid) ->
    case lists:nth(Y, Grid) of
        undefined -> undefined;
        Row -> lists:nth(X, Row)
    end;
get_cell(_, _, _) ->
    undefined.

get_directions(X, Y) ->
    [{X - 1, Y}, {X + 1, Y}, {X, Y - 1}, {X, Y + 1}].

process_row({Row, Y}, Acc) ->
    Acc ++ find_zeros_in_row(Row, Y, 1).

find_zeros_in_row([], _, _) ->
    [];
find_zeros_in_row([0 | Rest], Y, X) ->
    [{X, Y} | find_zeros_in_row(Rest, Y, X + 1)];
find_zeros_in_row([_ | Rest], Y, X) ->
    find_zeros_in_row(Rest, Y, X + 1).

find_trailheads(Grid) ->
    lists:foldl(fun process_row/2, [], lists:zip(Grid, lists:seq(1, length(Grid)))).

find_trails(Grid, X, Y) ->
    Trails = find_trails(Grid, X, Y, get_cell(Grid, X, Y)),
    ordsets:from_list(Trails).

find_trails(Grid, X, Y, 9) ->
    case get_cell(Grid, X, Y) of
        9 ->
            [{X, Y}];
        _ ->
            []
    end;
find_trails(Grid, X, Y, Val) ->
    NextVal = Val + 1,
    case get_cell(Grid, X, Y) of
        Val ->
            Directions = get_directions(X, Y),
            lists:flatmap(
                fun({NextX, NextY}) ->
                    find_trails(Grid, NextX, NextY, NextVal)
                end,
                Directions
            );
        _ ->
            []
    end.

find_trails(Grid, Trailheads) ->
    lists:map(fun({X, Y}) -> find_trails(Grid, X, Y) end, Trailheads).

main() ->
    Grid = read_file_to_2d_array("input"),
    Trailheads = find_trailheads(Grid),
    Trails = find_trails(Grid, Trailheads),
    Score = lists:foldl(fun(T, Acc) -> Acc + length(T) end, 0, Trails),
    % io:format("~p~n", [Trailheads]),
    % io:format("~p~n", [Trails]),
    io:format("~p~n", [Score]).
