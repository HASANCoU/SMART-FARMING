:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_json)).
:- use_module(library(http/http_parameters)).

:- consult('rules.pl').

% ---------------------------
% CORS headers (simple)
cors :-
    format('Access-Control-Allow-Origin: *~n'),
    format('Access-Control-Allow-Methods: GET, OPTIONS~n'),
    format('Access-Control-Allow-Headers: Content-Type~n').

% ---------------------------
% Handlers

ping_handler(_Request) :-
    cors,
    reply_json(json([status=ok])).

crops_handler(Request) :-
    cors,
    http_parameters(Request, [month(Month, [atom])]),
    ( season_from_month(Month, Season)
    -> ( available_crops_for_month(Month, Crops)
       -> reply_json(json([month=Month, season=Season, crops=Crops]))
       ;  reply_json(json([month=Month, season=Season, crops=[]]))
       )
    ;  reply_json(json([error='Unknown month. Use january..december.']))
    ).

item_to_json(
    item(Crop, Score, Yield, Revenue, Cost, Profit, Risk, Reasons),
    AreaAcre,
    json([
        crop=Crop,
        score=Score,
        yield_per_acre_kg=Yield,
        revenue_bdt=Revenue,
        cost_bdt=Cost,
        profit_bdt=Profit,
        risk=Risk,
        reasons=Reasons,
        fertilizer=FertJson
    ])
) :-
    ( calculate_fertilizer(Crop, AreaAcre, UreaCost, TSPCost, MoPCost, TotalFertCost)
    -> FertJson = json([urea_cost=UreaCost, tsp_cost=TSPCost, mop_cost=MoPCost, total=TotalFertCost])
    ;  FertJson = json([error='Fertilizer data not available'])
    ).

recommend_handler(Request) :-
    cors,
    http_parameters(Request, [
        month(Month, [atom]),
        soil(Soil, [atom]),
        water(Water, [atom]),
        budget(Budget, [atom]),
        area(Area, [float]),
        previous_crop(PrevCropRaw, [atom, optional(true)]),
        district(DistrictRaw, [atom, optional(true)])
    ]),
    % Handle optional parameters
    (var(PrevCropRaw) -> PreviousCrop = none ; PreviousCrop = PrevCropRaw),
    (var(DistrictRaw) -> District = none ; District = DistrictRaw),
    
    recommend_top3(Month, Soil, Water, Budget, Area, PreviousCrop, District, Top3),
    maplist(item_to_json_with_area(Area), Top3, JsonItems),
    season_from_month(Month, Season),
    reply_json(json([
        input=json([
            month=Month, 
            season=Season, 
            soil=Soil, 
            water=Water, 
            budget=Budget, 
            area=Area,
            previous_crop=PreviousCrop,
            district=District
        ]),
        top3=JsonItems
    ])).

% Helper to curry the area parameter
item_to_json_with_area(Area, Item, Json) :-
    item_to_json(Item, Area, Json).

% SMART FEATURE 3: Pest & Disease Diagnosis
diagnose_handler(Request) :-
    cors,
    http_parameters(Request, [
        crop(Crop, [atom]),
        symptom(Symptom, [atom])
    ]),
    ( symptom(Crop, Symptom, Disease)
    -> ( treatment(Disease, Treatment)
       -> reply_json(json([
              crop=Crop,
              symptom=Symptom,
              disease=Disease,
              treatment=Treatment,
              status=success
          ]))
       ;  reply_json(json([
              crop=Crop,
              symptom=Symptom,
              disease=Disease,
              treatment='Treatment information not available',
              status=partial
          ]))
       )
    ;  reply_json(json([
           crop=Crop,
           symptom=Symptom,
           error='No matching disease found for this crop and symptom',
           status=not_found
       ]))
    ).

% ---------------------------
% Routes
:- http_handler(root(api/ping), ping_handler, []).
:- http_handler(root(api/crops), crops_handler, []).
:- http_handler(root(api/recommend), recommend_handler, []).
:- http_handler(root(api/diagnose), diagnose_handler, []).

% ---------------------------
% Start/Stop helpers
server(Port) :-
    http_server(http_dispatch, [port(Port)]).

stop_server(Port) :-
    http_stop_server(Port, []).
