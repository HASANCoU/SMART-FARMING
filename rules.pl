% ---------- rules.pl ----------
:- consult('facts.pl').

% ---------- helpers ----------
% budget multiplier impacts achievable yield level
budget_yield_factor(low,  0.80).
budget_yield_factor(medium, 1.00).
budget_yield_factor(high, 1.15).

% water mismatch penalty
water_match_factor(UserWater, Crop, 1.00) :-
    crop_water(Crop, UserWater), !.
water_match_factor(low, Crop, 0.85) :-
    crop_water(Crop, medium), !.
water_match_factor(low, Crop, 0.70) :-
    crop_water(Crop, high), !.
water_match_factor(high, Crop, 0.85) :-
    crop_water(Crop, medium), !.
water_match_factor(high, Crop, 0.75) :-
    crop_water(Crop, low), !.
water_match_factor(_, _, 0.85).

% soil bonus
soil_bonus(Crop, Soil, 1.05) :-
    crop_soil(Crop, Soil), !.
soil_bonus(_, _, 1.00).

% risk multipliers
risk_multiplier(low,    0.95).
risk_multiplier(medium, 0.85).
risk_multiplier(high,   0.70).

% ----------- suitability -----------
season_from_month(Month, Season) :-
    month_to_season(Month, Season).

suitable_crop(Month, Soil, Crop) :-
    season_from_month(Month, Season),
    crop_season(Crop, Season),
    crop_soil(Crop, Soil).

% ----------- risk rules -----------
risk_level(Crop, Month, UserWater, high, [flood_or_waterlogging_risk]) :-
    season_from_month(Month, kharif2),
    (Crop = aman_rice ; Crop = jute),
    UserWater = high, !.

risk_level(tomato, Month, _, medium, [fungal_blight_risk]) :-
    season_from_month(Month, rabi), !.

risk_level(chili, Month, _, medium, [pest_thrips_risk]) :-
    season_from_month(Month, kharif2), !.

risk_level(boro_rice, _, low, high, [water_shortage_for_boro]) :- !.

risk_level(_, _, _, low, [normal_risk]).

% ----------- yield estimate -----------
% Updated to accept optional PreviousCrop for rotation bonus
estimate_yield_per_acre(Crop, Budget, Water, Soil, PreviousCrop, Y, label(Level)) :-
    yield_range(Crop, low(L), medium(M), high(H)),
    budget_yield_factor(Budget, BF),
    water_match_factor(Water, Crop, WF),
    soil_bonus(Crop, Soil, SF),
    rotation_bonus(PreviousCrop, Crop, RF),
    Raw is M * BF * WF * SF * RF,
    (Raw < L -> Y0 = L ; Raw > H -> Y0 = H ; Y0 = Raw),
    Y is round(Y0),
    (Y < M -> Level = low ; Y > M -> Level = high ; Level = medium).

% Rotation bonus: 15% boost if rotation is good
rotation_bonus(none, _, 1.00) :- !.
rotation_bonus(PreviousCrop, CurrentCrop, 1.15) :-
    crop_family(PreviousCrop, PrevFamily),
    crop_family(CurrentCrop, CurrFamily),
    rotation_good(PrevFamily, CurrFamily), !.
rotation_bonus(_, _, 1.00).

% ----------- cost / revenue / profit -----------
estimate_cost(Crop, AreaAcre, Cost) :-
    cost_per_acre(Crop, CPA),
    Cost is round(CPA * AreaAcre).

% SMART FEATURE 2: Fertilizer Calculator
% calculate_fertilizer(Crop, Area, UreaCost, TSPCost, MoPCost, TotalFertCost)
calculate_fertilizer(Crop, AreaAcre, UreaCost, TSPCost, MoPCost, TotalFertCost) :-
    nutrient_req(Crop, UreaKg, TSPKg, MoPKg),
    fertilizer_price(urea, UreaPrice),
    fertilizer_price(tsp, TSPPrice),
    fertilizer_price(mop, MoPPrice),
    UreaCost is round(UreaKg * AreaAcre * UreaPrice),
    TSPCost is round(TSPKg * AreaAcre * TSPPrice),
    MoPCost is round(MoPKg * AreaAcre * MoPPrice),
    TotalFertCost is UreaCost + TSPCost + MoPCost.

% SMART FEATURE 4: Regional Dynamic Pricing
% Updated to accept District for regional price multiplier
estimate_revenue(Crop, AreaAcre, YieldPerAcre, District, Revenue) :-
    price_per_kg(Crop, BasePrice),
    district_price_factor(District, Factor),
    AdjustedPrice is BasePrice * Factor,
    Revenue is round(YieldPerAcre * AreaAcre * AdjustedPrice).

district_price_factor(none, 1.00) :- !.
district_price_factor(District, Factor) :-
    district_multiplier(District, Factor), !.
district_price_factor(_, 1.00).

estimate_profit(Crop, Month, Soil, Water, Budget, AreaAcre, PreviousCrop, District,
                YieldPerAcre, Revenue, Cost, ProfitAdj, Risk, RiskReasons, Explain) :-

    suitable_crop(Month, Soil, Crop),
    estimate_yield_per_acre(Crop, Budget, Water, Soil, PreviousCrop, YieldPerAcre, _),
    estimate_revenue(Crop, AreaAcre, YieldPerAcre, District, Revenue),
    estimate_cost(Crop, AreaAcre, Cost),

    ProfitRaw is Revenue - Cost,

    risk_level(Crop, Month, Water, Risk, RiskReasons),
    risk_multiplier(Risk, RM),
    ProfitAdj is round(ProfitRaw * RM),

    season_from_month(Month, Season),
    crop_water(Crop, Req),

    Explain = [
        season(Season),
        soil(Soil),
        water(user_water=Water, required_for_crop=Req)
    ].

% ----------- ranking -----------
risk_penalty(low,  0).
risk_penalty(medium, 8000).
risk_penalty(high,  18000).

crop_score(ProfitAdj, Risk, Score) :-
    risk_penalty(Risk, RP),
    Score is ProfitAdj - RP.

% ----------- top recommendations (SWI-Prolog safe) -----------
recommend_top3(Month, Soil, Water, Budget, AreaAcre, PreviousCrop, District, Top3) :-
    findall(
        item(Crop, Score, Yield, Revenue, Cost, Profit, Risk, Reasons),
        (
            suitable_crop(Month, Soil, Crop),
            estimate_profit(Crop, Month, Soil, Water, Budget, AreaAcre, PreviousCrop, District,
                            Yield, Revenue, Cost, Profit, Risk, Reasons, _),
            crop_score(Profit, Risk, Score)
        ),
        Items
    ),
    predsort(compare_score_desc, Items, Sorted),
    take(3, Sorted, Top3).

compare_score_desc(Delta,
    item(_,S1,_,_,_,_,_,_),
    item(_,S2,_,_,_,_,_,_)) :-
    compare(Delta, S2, S1).

take(0, _, []) :- !.
take(_, [], []) :- !.
take(N, [H|T], [H|R]) :-
    N1 is N - 1,
    take(N1, T, R).

% --- list all available crops for a given month ---
available_crops_for_month(Month, Crops) :-
    season_from_month(Month, Season),
    setof(Crop, crop_season(Crop, Season), Crops), !.

available_crops_for_month(Month, []) :-
    \+ season_from_month(Month, _).

% --- pretty print ---
show_available_crops(Month) :-
    ( season_from_month(Month, Season)
    ->  available_crops_for_month(Month, Crops),
        format('Month: ~w  -> Season: ~w~n', [Month, Season]),
        format('Available crops: ~w~n', [Crops])
    ;   writeln('Unknown month. Use january..december.')
    ).
