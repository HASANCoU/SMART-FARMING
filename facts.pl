% ---------- facts.pl ----------
% Month -> Season mapping (Bangladesh-oriented)
:- discontiguous crop_soil/2.
:- discontiguous crop_water/2.
:- discontiguous crop_season/2.

month_to_season(november, rabi).
month_to_season(december, rabi).
month_to_season(january,  rabi).
month_to_season(february, rabi).
month_to_season(march,    rabi).

month_to_season(april,  kharif1).
month_to_season(may,    kharif1).
month_to_season(june,   kharif1).

month_to_season(july,      kharif2).
month_to_season(august,    kharif2).
month_to_season(september, kharif2).
month_to_season(october,   kharif2).

% -----------------------------
% Crop suitability facts
% crop_season(Crop, Season).
% crop_soil(Crop, Soil).   Soil: loamy/clay/sandy
% crop_water(Crop, Water). Water: low/medium/high

% RABI crops
crop_season(wheat,   rabi).
crop_season(potato,  rabi).
crop_season(tomato,  rabi).
crop_season(mustard, rabi).
crop_season(lentil,  rabi).
crop_season(boro_rice, rabi).   % Boro (transplanted Jan-Feb)

crop_soil(wheat,   loamy).
crop_soil(wheat,   clay).
crop_water(wheat,  medium).

crop_soil(potato,  loamy).
crop_soil(potato,  sandy).
crop_water(potato, medium).

crop_soil(tomato,  loamy).
crop_soil(tomato,  sandy).
crop_water(tomato, medium).

crop_soil(mustard, loamy).
crop_soil(mustard, sandy).
crop_water(mustard, low).

crop_soil(lentil,  loamy).
crop_soil(lentil,  clay).
crop_water(lentil, low).

crop_soil(boro_rice, clay).
crop_soil(boro_rice, loamy).
crop_water(boro_rice, high).

% KHARIF-1 crops
crop_season(aus_rice, kharif1).
crop_season(jute,     kharif1).
crop_season(maize,    kharif1).
crop_season(mungbean, kharif1).
crop_season(sesame,   kharif1).

crop_soil(aus_rice, clay).
crop_soil(aus_rice, loamy).
crop_water(aus_rice, high).

crop_soil(jute, loamy).
crop_soil(jute, clay).
crop_water(jute, high).

crop_soil(maize, loamy).
crop_soil(maize, sandy).
crop_water(maize, medium).

crop_soil(mungbean, sandy).
crop_soil(mungbean, loamy).
crop_water(mungbean, low).

crop_soil(sesame, sandy).
crop_soil(sesame, loamy).
crop_water(sesame, low).

% KHARIF-2 crops
crop_season(aman_rice, kharif2).
crop_season(chili,     kharif2).
crop_season(brinjal,   kharif2).   % eggplant
crop_season(cauliflower, kharif2). % winter veg (late kharif2 -> rabi edge)

crop_soil(aman_rice, clay).
crop_soil(aman_rice, loamy).
crop_water(aman_rice, high).

crop_soil(chili, loamy).
crop_soil(chili, sandy).
crop_water(chili, medium).

crop_soil(brinjal, loamy).
crop_soil(brinjal, clay).
crop_water(brinjal, medium).

crop_soil(cauliflower, loamy).
crop_soil(cauliflower, sandy).
crop_water(cauliflower, medium).

% -----------------------------
% Yield ranges per acre (kg/acre) as rough estimates
% yield_range(Crop, low(L), medium(M), high(H)).
yield_range(wheat,     low(800),  medium(1100), high(1400)).
yield_range(potato,    low(6000), medium(9000), high(12000)).
yield_range(tomato,    low(4000), medium(6500), high(9000)).
yield_range(mustard,   low(300),  medium(450),  high(650)).
yield_range(lentil,    low(250),  medium(400),  high(550)).
yield_range(boro_rice, low(1500), medium(2200), high(3000)).

yield_range(aus_rice,  low(1200), medium(1700), high(2300)).
yield_range(jute,      low(900),  medium(1200), high(1500)).
yield_range(maize,     low(1500), medium(2200), high(3000)).
yield_range(mungbean,  low(250),  medium(400),  high(600)).
yield_range(sesame,    low(180),  medium(280),  high(400)).

yield_range(aman_rice, low(1300), medium(1900), high(2600)).
yield_range(chili,     low(800),  medium(1300), high(2000)).
yield_range(brinjal,   low(3000), medium(5000), high(7500)).
yield_range(cauliflower, low(2000), medium(3500), high(5500)).

% -----------------------------
% Market price (BDT per kg) - demo values (you can update easily)
price_per_kg(wheat,      45).
price_per_kg(potato,     25).
price_per_kg(tomato,     35).
price_per_kg(mustard,    120).
price_per_kg(lentil,     140).
price_per_kg(boro_rice,  38).

price_per_kg(aus_rice,   36).
price_per_kg(jute,       55).
price_per_kg(maize,      32).
price_per_kg(mungbean,   120).
price_per_kg(sesame,     160).

price_per_kg(aman_rice,  40).
price_per_kg(chili,      180).
price_per_kg(brinjal,    45).
price_per_kg(cauliflower, 40).

% -----------------------------
% Cost estimate per acre (BDT/acre) - demo values
cost_per_acre(wheat,       22000).
cost_per_acre(potato,      75000).
cost_per_acre(tomato,      65000).
cost_per_acre(mustard,     18000).
cost_per_acre(lentil,      17000).
cost_per_acre(boro_rice,   60000).

cost_per_acre(aus_rice,    45000).
cost_per_acre(jute,        50000).
cost_per_acre(maize,       42000).
cost_per_acre(mungbean,    20000).
cost_per_acre(sesame,      24000).

cost_per_acre(aman_rice,   48000).
cost_per_acre(chili,       70000).
cost_per_acre(brinjal,     60000).
cost_per_acre(cauliflower, 55000).

% -----------------------------
% SMART FEATURE 1: Crop Rotation Logic
% crop_family(Crop, Family).
% Families: cereal, legume, tuber, oilseed, vegetable, fiber

crop_family(wheat, cereal).
crop_family(boro_rice, cereal).
crop_family(aus_rice, cereal).
crop_family(aman_rice, cereal).
crop_family(maize, cereal).

crop_family(lentil, legume).
crop_family(mungbean, legume).

crop_family(potato, tuber).

crop_family(mustard, oilseed).
crop_family(sesame, oilseed).

crop_family(tomato, vegetable).
crop_family(chili, vegetable).
crop_family(brinjal, vegetable).
crop_family(cauliflower, vegetable).

crop_family(jute, fiber).

% rotation_good(PreviousFamily, NextFamily).
% Good rotations based on agronomic principles:
% - Legumes fix nitrogen -> good for cereals
% - Cereals -> tubers (different nutrient demand)
% - Tubers -> legumes (soil restoration)
% - Oilseeds -> cereals

rotation_good(legume, cereal).
rotation_good(legume, vegetable).
rotation_good(cereal, tuber).
rotation_good(cereal, legume).
rotation_good(tuber, legume).
rotation_good(tuber, cereal).
rotation_good(oilseed, cereal).
rotation_good(fiber, legume).
rotation_good(vegetable, cereal).

% -----------------------------
% SMART FEATURE 2: Fertilizer Calculator
% nutrient_req(Crop, UreaKg, TSPKg, MoPKg) per acre
% Urea (Nitrogen), TSP (Phosphate), MoP (Potash)

nutrient_req(wheat, 120, 80, 60).
nutrient_req(potato, 150, 100, 120).
nutrient_req(tomato, 100, 90, 80).
nutrient_req(mustard, 80, 60, 40).
nutrient_req(lentil, 40, 50, 30).
nutrient_req(boro_rice, 140, 90, 70).

nutrient_req(aus_rice, 110, 70, 60).
nutrient_req(jute, 100, 60, 50).
nutrient_req(maize, 130, 85, 75).
nutrient_req(mungbean, 35, 45, 25).
nutrient_req(sesame, 60, 50, 35).

nutrient_req(aman_rice, 120, 75, 65).
nutrient_req(chili, 110, 95, 85).
nutrient_req(brinjal, 105, 80, 70).
nutrient_req(cauliflower, 95, 75, 65).

% fertilizer_price(Type, PricePerKg) in BDT
fertilizer_price(urea, 22).
fertilizer_price(tsp, 25).
fertilizer_price(mop, 20).

% -----------------------------
% SMART FEATURE 3: Pest & Disease Diagnosis
% symptom(Crop, SymptomAtom, Disease).
:- discontiguous symptom/3.
:- discontiguous treatment/2.

% Wheat symptoms
symptom(wheat, yellow_rust, wheat_rust).
symptom(wheat, leaf_spots, wheat_blight).
symptom(wheat, stunted_growth, aphid_infestation).

% Potato symptoms
symptom(potato, brown_spots, late_blight).
symptom(potato, curled_leaves, potato_virus).
symptom(potato, wilting, bacterial_wilt).

% Tomato symptoms
symptom(tomato, yellow_leaves, tomato_mosaic_virus).
symptom(tomato, black_spots, early_blight).
symptom(tomato, fruit_rot, fungal_infection).

% Rice symptoms (all varieties)
symptom(boro_rice, brown_spots, rice_blast).
symptom(aus_rice, brown_spots, rice_blast).
symptom(aman_rice, brown_spots, rice_blast).
symptom(boro_rice, yellowing, bacterial_leaf_blight).
symptom(aus_rice, yellowing, bacterial_leaf_blight).
symptom(aman_rice, yellowing, bacterial_leaf_blight).

% Chili symptoms
symptom(chili, leaf_curl, chili_leaf_curl_virus).
symptom(chili, white_flies, thrips_infestation).
symptom(chili, fruit_drop, anthracnose).

% Brinjal symptoms
symptom(brinjal, wilting, bacterial_wilt).
symptom(brinjal, fruit_borer, shoot_and_fruit_borer).
symptom(brinjal, leaf_spots, cercospora_leaf_spot).

% Jute symptoms
symptom(jute, stem_rot, stem_rot_disease).
symptom(jute, yellowing, nutrient_deficiency).

% Maize symptoms
symptom(maize, leaf_blight, maize_blight).
symptom(maize, ear_rot, fusarium_ear_rot).

% Treatment recommendations
treatment(wheat_rust, 'Apply fungicide (Propiconazole 25% EC @ 1ml/L). Spray 2-3 times at 10-day intervals.').
treatment(wheat_blight, 'Use Mancozeb 75% WP @ 2g/L. Ensure proper drainage and avoid waterlogging.').
treatment(aphid_infestation, 'Spray Imidacloprid 17.8% SL @ 0.5ml/L. Use neem oil as organic alternative.').

treatment(late_blight, 'Apply Metalaxyl + Mancozeb @ 2.5g/L immediately. Remove infected plants.').
treatment(potato_virus, 'No chemical cure. Remove infected plants. Control aphid vectors with insecticide.').
treatment(bacterial_wilt, 'No cure. Practice crop rotation. Use disease-free seeds. Improve drainage.').

treatment(tomato_mosaic_virus, 'Remove infected plants. Disinfect tools. Use resistant varieties. Control aphids.').
treatment(early_blight, 'Spray Chlorothalonil @ 2g/L. Maintain plant spacing for air circulation.').
treatment(fungal_infection, 'Apply Carbendazim 50% WP @ 1g/L. Avoid overhead irrigation.').

treatment(rice_blast, 'Spray Tricyclazole 75% WP @ 0.6g/L at tillering and booting stage.').
treatment(bacterial_leaf_blight, 'Use Copper Oxychloride @ 3g/L. Drain field and re-irrigate after 3 days.').

treatment(chili_leaf_curl_virus, 'Control whitefly vectors with Thiamethoxam @ 0.3g/L. Remove infected plants.').
treatment(thrips_infestation, 'Spray Fipronil 5% SC @ 2ml/L. Use blue sticky traps.').
treatment(anthracnose, 'Apply Mancozeb @ 2.5g/L. Harvest fruits timely. Improve air circulation.').

treatment(shoot_and_fruit_borer, 'Remove and destroy infected shoots/fruits. Spray Emamectin Benzoate @ 0.5g/L.').
treatment(cercospora_leaf_spot, 'Use Mancozeb 75% WP @ 2g/L. Remove infected leaves.').

treatment(stem_rot_disease, 'Apply Carbendazim @ 1g/L at base. Ensure proper drainage. Avoid dense planting.').
treatment(nutrient_deficiency, 'Apply balanced NPK fertilizer. Conduct soil test. Add organic matter.').

treatment(maize_blight, 'Spray Propiconazole @ 1ml/L. Use resistant varieties. Practice crop rotation.').
treatment(fusarium_ear_rot, 'No effective chemical control. Harvest timely. Dry properly. Use resistant hybrids.').

% -----------------------------
% SMART FEATURE 4: Regional Dynamic Pricing
% district_multiplier(District, Factor).
% Major agricultural districts in Bangladesh

district_multiplier(dhaka, 1.20).        % High urban demand
district_multiplier(chittagong, 1.15).   % Port city, high demand
district_multiplier(sylhet, 1.10).       % Tea region, moderate demand
district_multiplier(rajshahi, 1.00).     % Agricultural hub, baseline
district_multiplier(khulna, 0.98).       % Coastal, moderate
district_multiplier(barisal, 0.95).      % Rice bowl, lower prices
district_multiplier(rangpur, 0.92).      % Northern region
district_multiplier(mymensingh, 0.95).   % Agricultural area
district_multiplier(cumilla, 0.95).      % Agricultural area
district_multiplier(bogra, 0.93).        % Agricultural area
district_multiplier(jessore, 0.97).      % Border district
district_multiplier(dinajpur, 0.90).     % Remote northern area
