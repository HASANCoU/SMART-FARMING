% ---------- main.pl ----------
:- consult('rules.pl').

% NOTE for user: In SWI-Prolog input requires a trailing dot (.)
% Example: january.  loamy.  medium.  1.5.  high.

start :-
    nl, writeln('=== Smart Farming & Earning Predictor (Prolog) ==='),
    writeln('Type values as atoms with a dot. Example: january. loamy. medium. 1.0. medium.'),
    menu.

menu :-
    nl,
    writeln('1) Get Top 3 crop recommendations'),
    writeln('2) Check profit details for a specific crop'),
    writeln('3) Show month -> season'),
    writeln('4) Diagnose pest/disease'),
    writeln('0) Exit'),
    write('Choose: '), read(Choice),
    handle(Choice).

handle(0) :- nl, writeln('Bye!'), !.
handle(1) :- input_common(Month, Soil, Water, Area, Budget, PreviousCrop, District),
             recommend_top3(Month, Soil, Water, Budget, Area, PreviousCrop, District, Top3),
             show_top3(Top3),
             menu.
handle(2) :- input_common(Month, Soil, Water, Area, Budget, PreviousCrop, District),
             write('Enter crop name (e.g., potato/tomato/wheat/aman_rice): '), read(Crop),
             show_crop_details(Crop, Month, Soil, Water, Budget, Area, PreviousCrop, District),
             menu.
handle(3) :- write('Enter month: '), read(Month),
             ( season_from_month(Month, Season)
               -> format('Season for ~w is: ~w~n', [Month, Season])
               ;  writeln('Unknown month. Try january, february, ...')
             ),
             menu.
handle(4) :- write('Enter crop name: '), read(Crop),
             write('Enter symptom (e.g., yellow_rust/brown_spots/wilting): '), read(Symptom),
             diagnose_disease(Crop, Symptom),
             menu.
handle(_) :- writeln('Invalid option!'), menu.

input_common(Month, Soil, Water, Area, Budget, PreviousCrop, District) :-
    nl,
    write('Enter month (january..december): '), read(Month),
    write('Enter soil (loamy/clay/sandy): '), read(Soil),
    write('Enter water availability (low/medium/high): '), read(Water),
    write('Enter land area in acre (e.g., 1.0): '), read(Area),
    write('Enter budget (low/medium/high): '), read(Budget),
    write('Enter previous crop (or none if first planting): '), read(PreviousCrop),
    write('Enter district (e.g., dhaka/chittagong/rajshahi or none): '), read(District).

show_top3([]) :-
    nl, writeln('No suitable crops found for these inputs.'), !.
show_top3(Top3) :-
    nl, writeln('--- Top Recommendations ---'),
    show_items(1, Top3).

show_items(_, []) :- !.
show_items(Index, [item(Crop, Score, YieldPerAcre, Revenue, Cost, ProfitAdj, Risk, RiskReasons)|T]) :-
    nl,
    format('Rank ~d: ~w~n', [Index, Crop]),
    format('  Score: ~d~n', [Score]),
    format('  Estimated yield: ~d kg/acre~n', [YieldPerAcre]),
    format('  Revenue (BDT): ~d~n', [Revenue]),
    format('  Cost (BDT): ~d~n', [Cost]),
    format('  Profit (risk-adjusted) (BDT): ~d~n', [ProfitAdj]),
    format('  Risk: ~w  Reasons: ~w~n', [Risk, RiskReasons]),
    Index2 is Index + 1,
    show_items(Index2, T).

show_crop_details(Crop, Month, Soil, Water, Budget, Area, PreviousCrop, District) :-
    nl,
    ( estimate_profit(Crop, Month, Soil, Water, Budget, Area, PreviousCrop, District,
                      YieldPerAcre, Revenue, Cost, ProfitAdj, Risk, RiskReasons, Explain)
      ->
        season_from_month(Month, Season),
        format('--- Details for ~w ---~n', [Crop]),
        format('Season: ~w  (from month ~w)~n', [Season, Month]),
        format('Soil: ~w, Water: ~w, Budget: ~w, Area: ~w acre~n', [Soil, Water, Budget, Area]),
        format('Previous Crop: ~w, District: ~w~n', [PreviousCrop, District]),
        format('Estimated yield: ~d kg/acre~n', [YieldPerAcre]),
        format('Revenue: ~d BDT~n', [Revenue]),
        format('Cost: ~d BDT~n', [Cost]),
        format('Profit (risk-adjusted): ~d BDT~n', [ProfitAdj]),
        format('Risk: ~w  Reasons: ~w~n', [Risk, RiskReasons]),
        format('Explain: ~w~n', [Explain]),
        % Show fertilizer breakdown
        ( calculate_fertilizer(Crop, Area, UreaCost, TSPCost, MoPCost, TotalFertCost)
        -> format('~nFertilizer Costs:~n'),
           format('  Urea: ~d BDT~n', [UreaCost]),
           format('  TSP: ~d BDT~n', [TSPCost]),
           format('  MoP: ~d BDT~n', [MoPCost]),
           format('  Total Fertilizer: ~d BDT~n', [TotalFertCost])
        ;  writeln('Fertilizer data not available.')
        )
      ;
        writeln('This crop is not suitable for your given month/soil (or invalid crop name).')
    ).

diagnose_disease(Crop, Symptom) :-
    nl,
    ( symptom(Crop, Symptom, Disease)
    -> format('--- Diagnosis Result ---~n'),
       format('Crop: ~w~n', [Crop]),
       format('Symptom: ~w~n', [Symptom]),
       format('Identified Disease: ~w~n', [Disease]),
       ( treatment(Disease, Treatment)
       -> format('~nTreatment Recommendation:~n~w~n', [Treatment])
       ;  writeln('Treatment information not available.')
       )
    ;  format('No disease found for crop "~w" with symptom "~w".~n', [Crop, Symptom]),
       writeln('Please check the crop name and symptom spelling.')
    ).
