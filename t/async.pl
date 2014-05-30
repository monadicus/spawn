:- use_module(library(spawn)).

delayed_unify(X,Y) :-
    sleep(1),
    X = Y.

one_solution(foo).

two_solutions(foo).
two_solutions(bar).

exceptional :-
    throw(oh_no).

:- use_module(library(tap)).

% two async goals actually happen in parallel
goes_faster :-
    get_time(Start),
    async(delayed_unify(A,a), TokenA),
    async(delayed_unify(B,b), TokenB),
    get_time(Mid),

    % getting here takes way less than one second
    % so these should both still be variables
    var(A),
    var(B),

    % wait for the computations to finish
    await(TokenA),
    await(TokenB),
    get_time(End),
    A == a,
    B == b,

    % make sure the timings are reasonable
    Mid - Start < 0.1, % async/1 returns quickly
    End - Start < 1.1. % sleep calls happened in parallel


% await/1 with a single solution leaves no choicepoints
single :-
    async(one_solution(X),T),
    await(T),
    X == foo.


% await/1 with two solutions finds them both
double :-
    async(two_solutions(X), T),
    findall(X,await(T),Xs),
    Xs == [foo,bar].

% await/1 fails when there are no solutions
zero(fail) :-
    async(fail,T),
    await(T).


% TODO what if Goal throws an exception?