% Padding zeros at left to make two lists the same length
addZeros(L, 0, L).
addZeros(L, 1, [0|L]).
addZeros(L, N, [0|FL]) :-
        N2 is N - 1,
        addZeros(L, N2, FL).

paddingZeros(L, N, FL) :-
        length(L, S),
        S < N,
        N2 is N - S,
        addZeros(L, N2, FL).
paddingZeros(L, _, L).


% Helper predicate to split a float into integer and fractional parts as strings.
split_float(Number, IntPart, FracPart) :-
    number_codes(Number, Codes),
    ( append(IntCodes, [0'.|FracCodes], Codes) ->
        IntPart = IntCodes,
        FracPart = FracCodes
    ; IntPart = Codes,
      FracPart = []
    ).

% Helper predicate to add two integer lists and handle carry.
add_frac_lists([], [], 0, [], 0).
add_frac_lists([], [], 1, [], 1).
add_frac_lists([A|As], [B|Bs], Carry, [Sum|Sums], NextCarry) :-
    TempSum is A + B + Carry,
    (
        TempSum >= 10 ->
        Sum is TempSum - 10,
        add_frac_lists(As, Bs, 1, Sums, NextCarry)
    ;   TempSum < 10 ->
        Sum is TempSum,
        add_frac_lists(As, Bs, 0, Sums, NextCarry)
    ).

add_lists([], [], 0, []).
add_lists([], [], 1, [1]).
add_lists([A], [], Carry, [Sum]) :-
    Sum is A + Carry.
add_lists([], [B], Carry, [Sum]) :-
    Sum is B + Carry.
add_lists([A|As], [B|Bs], Carry, [Sum|Sums]) :-
    TempSum is A + B + Carry,
    (
        TempSum >= 10 ->
        Sum is TempSum - 10,
        NewCarry is 1, 
        add_lists(As, Bs, NewCarry, Sums)
    ;   TempSum < 10 ->
        Sum is TempSum,
        NewCarry is 0, 
        add_lists(As, Bs, NewCarry, Sums)
    ).


% Predicate to convert a single code to a number
code_to_number(Code, Number) :-
    Number is Code - 48.

% Predicate to convert a list of ASCII codes to a list of numbers
codes_to_numbers(Codes, Numbers) :-
    maplist(code_to_number, Codes, Numbers).


% Add two floats by treating them as strings of digits.
add_floats_by_decimal_places(Float1, Float2, Result) :-
    split_float(Float1, IntPart1, FracPart1),
    split_float(Float2, IntPart2, FracPart2),
    codes_to_numbers(IntPart1, IntNums1),
    codes_to_numbers(IntPart2, IntNums2),
    codes_to_numbers(FracPart1, FracNums1),
    codes_to_numbers(FracPart2, FracNums2),
    
    % Add fractional parts
    % Step 1 reverse
    reverse(FracNums1, RevFracNums1),
    reverse(FracNums2, RevFracNums2),
    % Step 2 padding zeros at left make the same length
    length(FracNums1, FracLen1),
    length(FracNums2, FracLen2),
    paddingZeros(RevFracNums1, FracLen2, PaddedRevFracNums1) -> write(PaddedRevFracNums1), nl,
    paddingZeros(RevFracNums2, FracLen1, PaddedRevFracNums2) -> write(PaddedRevFracNums2), nl,
    % add up at decimal places
    add_frac_lists(PaddedRevFracNums1, PaddedRevFracNums2, 0, RevFracSum, IntCarry) -> write(RevFracSum), nl,
    reverse(RevFracSum, FracSum) -> write(FracSum), nl,

    % Add integer parts and carry from fractional addition
    % Step 1 padding zeros at left make the same length
    length(IntNums1, IntLen1),
    length(IntNums2, IntLen2),
    paddingZeros(IntNums1, IntLen2, PaddedIntNums1),
    paddingZeros(IntNums2, IntLen1, PaddedIntNums2),
    % Step 2 reverse
    reverse(PaddedIntNums1, RevIntNums1),
    reverse(PaddedIntNums2, RevIntNums2),
    add_lists(RevIntNums1, RevIntNums2, IntCarry, RevIntSum) -> write(RevIntSum), nl,
    reverse(RevIntSum, IntSum) -> write(IntSum), nl,
    
    % Combine integer part and fractional part
    atomics_to_string(IntSum, '', IntStr),
    atomics_to_string(FracSum, '', FracStr),
    atomics_to_string([IntStr, '.', FracStr], '', ResultStr),
    atom_number(ResultStr, Result).

    % test samples

    %?- add_floats_by_decimal_places(850.86, 356.9999, Sum).
    %Sum = 1207.8599.

    %?- add_floats_by_decimal_places(0.850, 0.9999, Sum).
    %Sum = 1.8499.

    %?- add_floats_by_decimal_places(850, 9999.0, Sum).
    %Sum = 10849.0.

