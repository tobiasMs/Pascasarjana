nationality(englishman).
nationality(spaniard).
nationality(norwegian).
nationality(ukrainian).
nationality(japanese).

color(red).
color(green).
color(ivory).
color(blue).
color(yellow).

drink(coffee).
drink(milk).
drink(orange_juice).
drink(tea).

food(hershey).
food(kitkat).
food(smarties).
food(snickers).
food(milky_ways).

pet(dog).
pet(snails).
pet(fox).
pet(horse).
pet(zebra).

zebra_puzzle(Solution) :-
    % Mendefinisikan 5 rumah
    % Masing-masing rumah adalah sebuah list yang berisi properti-properti
    length(Solution, 5),

    % Petunjuk 1: Englishman lives in the red house
    member([englishman, red, _, _, _], Solution),

    % Petunjuk 2: The Spaniard owns the dog
    member([spaniard, _, _, _, dog], Solution),

    % Petunjuk 3: The Norwegian lives in the first house on the left
    Solution = [[norwegian, _, _, _, _] | _],

    % Petunjuk 4: The green house is immediately to the right of the ivory house
    next_to([_, green, _, _, _], [_, ivory, _, _, _], Solution),

    % Petunjuk 5: The man who eats Hershey bars lives in the house next to the man with the fox
    next_to([_, _, _, hershey, _], [_, _, _, _, fox], Solution),

    % Petunjuk 6: Kit Kats are eaten in the yellow house
    member([_, yellow, _, kitkat, _], Solution),

    % Petunjuk 7: The Norwegian lives next to the blue house
    next_to([norwegian, _, _, _, _], [_, blue, _, _, _], Solution),

    % Petunjuk 8: The Smarties eater owns snails
    member([_, _, _, smarties, snails], Solution),

    % Petunjuk 9: The Snickers eater drinks orange juice
    member([_, _, orange_juice, snickers, _], Solution),

    % Petunjuk 10: The Ukrainian drinks tea
    member([ukrainian, _, tea, _, _], Solution),

    % Petunjuk 11: The Japanese eats Milky Ways
    member([japanese, _, _, milky_ways, _], Solution),

    % Petunjuk 12: Kit Kats are eaten in a house next to the house where the horse is kept
    next_to([_, _, _, kitkat, _], [_, _, _, _, horse], Solution),

    % Petunjuk 13: Coffee is drunk in the green house
    member([_, green, coffee, _, _], Solution),

    % Petunjuk 14: Milk is drunk in the middle house
    nth1(3, Solution, [_, _, milk, _, _]),

    % Petunjuk tersembunyi/tambahan dari teka-teki asli
    % Ini diperlukan untuk menemukan solusi unik

    % Petunjuk 15: The man who smokes Chesterfields lives in the house next to the man with the fox.
    % Petunjuk 16: The man who smokes Kools lives in the yellow house.
    % Petunjuk 17: The man who smokes Lucky Strike drinks orange juice.
    % Petunjuk 18: The man who smokes Parliament owns the zebra.
    % Petunjuk 19: The man who drinks water lives in the house next to the man who smokes Camel.
    
    % Kita akan menggunakan petunjuk dari teks aslinya
    
    % Petunjuk 15 (versi Anda): Snickers eater drinks orange juice
    member([_, _, orange_juice, snickers, _], Solution),

    % Petunjuk 16 (versi Anda): Kit Kats are eaten in the yellow house.
    member([_, yellow, _, kitkat, _], Solution),

    % Petunjuk 17 (versi Anda): Snickers eater drinks orange juice
    member([_, _, orange_juice, snickers, _], Solution),
    
    % Petunjuk 18 (versi Anda): The Japanese eats Milky Ways
    member([japanese, _, _, milky_ways, _], Solution),
    
    % Final clues from original puzzle
    member([_, _, water, _, _], Solution),
    member([_, _, _, _, zebra], Solution),
    
    % Pastikan semua item unik terisi di setiap rumah
    member([norwegian, _, _, _, _], Solution),
    member([englishman, _, _, _, _], Solution),
    member([ukrainian, _, _, _, _], Solution),
    member([spaniard, _, _, _, _], Solution),
    member([japanese, _, _, _, _], Solution),

    member([red, _, _, _, _], Solution),
    member([blue, _, _, _, _], Solution),
    member([green, _, _, _, _], Solution),
    member([ivory, _, _, _, _], Solution),
    member([yellow, _, _, _, _], Solution),

    member([_, _, milk, _, _], Solution),
    member([_, _, coffee, _, _], Solution),
    member([_, _, tea, _, _], Solution),
    member([_, _, orange_juice, _, _], Solution),
    member([_, _, water, _, _], Solution),

    member([_, _, _, kitkat, _], Solution),
    member([_, _, _, hershey, _], Solution),
    member([_, _, _, smarties, _], Solution),
    member([_, _, _, snickers, _], Solution),
    member([_, _, _, milky_ways, _], Solution),
    
    member([_, _, _, _, dog], Solution),
    member([_, _, _, _, fox], Solution),
    member([_, _, _, _, snails], Solution),
    member([_, _, _, _, horse], Solution),
    member([_, _, _, _, zebra], Solution).


% Aturan untuk menemukan tetangga (next_to)
next_to(A, B, List) :- 
    append(_, [A, B | _], List).
next_to(A, B, List) :-
    append(_, [B, A | _], List).

% Aturan untuk menemukan di sebelah kanan (right_of)
right_of(A, B, List) :-
    append(_, [B, A | _], List).
