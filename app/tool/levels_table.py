#!/usr/bin/env python3
"""DRAFT curriculum: every level of the learning worlds as data.

Writes assets/content/games/<world>/*.json and the off-screen challenge strings.
Run from app/:  python3 tool/levels_table.py && dart run tool/gen_lookup.dart && flutter gen-l10n

Everything here is a first draft for the educator to review and sign off in
docs/CURRICULUM.md: level order, the Albanian letter order, word choices,
age bands, and the pillar scores (estimates, 0–3 each; ≥ 2 required).
"""
import json, os, shutil

ALL = ["2-3", "4-5", "6-7"]
YOUNG = ["2-3", "4-5"]
MID = ["4-5", "6-7"]
OLD = ["6-7"]

# Default pillar estimates per engine (active, engaged, meaningful, social).
PILLARS_BOARD = (3, 3, 2, 3)

PILLARS = {
    "sound_match": (2, 2, 2, 2), "drag_to_target": (3, 3, 2, 2), "tap_count": (3, 2, 3, 2),
    "trace_path": (3, 2, 3, 2), "pairs_memory": (2, 3, 2, 2), "sequence_pattern": (2, 2, 3, 2),
    "sort_bins": (3, 2, 3, 2), "blend_tiles": (3, 3, 3, 2),
    **{k: PILLARS_BOARD for k in ["roll_and_move", "dominoes", "bingo", "tic_tac_zoo", "jigsaw", "i_spy", "feed_race"]},
}

# ARB key -> (English, Albanian). Albanian needs native review.
OFFSCREEN = {
    "moo_like_cow": ("Moo like a cow and crawl on all fours!", "Bëj mu si lopa dhe ec me katër këmbë!"),
    "wag_like_dog": ("Wag your tail like a happy dog!", "Tunde bishtin si një qen i gëzuar!"),
    "stomp_like_elephant": ("Stomp like an elephant: one, two, three!", "Shkel fort si elefanti: një, dy, tre!"),
    "swim_like_fish": ("Swim like a fish around the room!", "Noto si peshk nëpër dhomë!"),
    "walk_like_penguin": ("Waddle like a penguin and show a grown-up!", "Ec si pinguin dhe tregoja një të rrituri!"),
    "hug_grown_up": ("Give a grown-up a big bear hug!", "Përqafo fort një të rritur!"),
    "build_den": ("Build a cosy den with cushions!", "Ndërto një strofull të ngrohtë me jastëkë!"),
    "animal_charades": ("Act like an animal. Can a grown-up guess which one?", "Luaj si një kafshë. A e gjen i rrituri cila është?"),
    "jump_count": ("Jump three times and count out loud!", "Kërce tri herë dhe numëro me zë!"),
    "count_toys": ("Count five toys and line them up!", "Numëro pesë lodra dhe rreshtoji!"),
    "count_steps": ("Count your steps to the door!", "Numëro hapat deri te dera!"),
    "find_dots": ("Find something with dots on it!", "Gjej diçka me pika!"),
    "more_less_blocks": ("Make two piles of blocks. Which has more?", "Bëj dy grumbuj me kube. Cili ka më shumë?"),
    "air_write": ("Write a number in the air with your finger!", "Shkruaj një numër në ajër me gisht!"),
    "share_snack": ("Share a snack fairly with someone!", "Ndaje një ushqim në mënyrë të drejtë me dikë!"),
    "five_fingers": ("Show five fingers, then hide some. How many are hiding?", "Trego pesë gishta, pastaj fshih disa. Sa janë fshehur?"),
    "ten_fingers": ("Show ten fingers! Bend some down and count the rest.", "Trego dhjetë gishta! Palos disa dhe numëro të tjerët."),
    "add_spoons": ("Put two spoons and one more on the table. How many?", "Vendos dy lugë dhe një tjetër në tavolinë. Sa janë?"),
    "letter_hunt": ("Find something at home that starts with the same sound!", "Gjej diçka në shtëpi që fillon me të njëjtin tingull!"),
    "body_letter": ("Make the letter's shape with your body!", "Bëje formën e shkronjës me trupin tënd!"),
    "sound_walk": ("Say the sound every time you take a step!", "Thuaj tingullin sa herë që bën një hap!"),
    "read_with_grownup": ("Read a picture book with a grown-up!", "Lexo një libër me figura me një të rritur!"),
    "name_letters": ("Find the first letter of your name somewhere!", "Gjej diku shkronjën e parë të emrit tënd!"),
    "shape_hunt": ("Find something round and something square!", "Gjej diçka të rrumbullakët dhe diçka katrore!"),
    "draw_shape": ("Draw a big circle in the air!", "Vizato një rreth të madh në ajër!"),
    "colour_hunt": ("Find three red things at home!", "Gjej tri gjëra të kuqe në shtëpi!"),
    "mix_colours": ("Ask a grown-up to help you mix two paints!", "Kërkoji një të rrituri të të ndihmojë të përziesh dy bojëra!"),
    "clap_pattern": ("Clap a pattern: clap, stamp, clap, stamp!", "Duartrokit një model: duartrokit, shkel, duartrokit, shkel!"),
    "shape_walk": ("Walk around the room and name the shapes you see!", "Ec nëpër dhomë dhe thuaj emrat e formave që sheh!"),
    "real_puzzle": ("Do a real puzzle with a grown-up!", "Bëj një enigmë të vërtetë me një të rritur!"),
    "memory_objects": ("Hide three toys under cups. Where is the teddy?", "Fshih tri lodra nën gota. Ku është arushi?"),
    "hop_race": ("Have a hopping race with a grown-up. Everyone wins!", "Bëni një garë me kërcime me një të rritur. Të gjithë fitojnë!"),
    "spy_room": ("Play I Spy in your room with a grown-up!", "Luaj «Shoh diçka» në dhomën tënde me një të rritur!"),
    "feed_teddy": ("Give your teddy three pretend berries!", "Jepi arushit tënd tri kokrra për lojë!"),
    "line_up": ("Line up your shoes, matching pairs!", "Rreshto këpucët, çift pas çifti!"),
    "family_game": ("Play a real board game with your family!", "Luaj një lojë të vërtetë tavoline me familjen!"),
}

EYFS = {"board_games": ["PSED-BuildingRelationships", "M-Number"], "animals": ["UW-NaturalWorld"], "numbers": ["M-Number"], "letters": ["L-WordReading"], "shapes_colours": ["M-NumericalPatterns", "EAD-Creating"]}
AL = {"board_games": ["Fusha: Zhvillimi personal dhe shoqëror"], "animals": ["Fusha: Bota rreth nesh"], "numbers": ["Fusha: Matematika"], "letters": ["Fusha: Gjuha dhe komunikimi"], "shapes_colours": ["Fusha: Matematika", "Fusha: Arte"]}

STEPS_CHOICES = {"raiseAfter": 3, "lowerAfter": 2, "steps": [{"choices": 2}, {"choices": 3}, {"choices": 4}]}
STEPS_UP_TO_3 = {"raiseAfter": 3, "lowerAfter": 2, "steps": [{"choices": 2}, {"choices": 3}]}
STEPS_TARGETS = {"raiseAfter": 3, "lowerAfter": 2, "steps": [{"targets": 2}, {"targets": 3}]}


def g(name, game, params, bands, skills, difficulty=None, locales=None, pillars=None):
    return dict(name=name, game=game, params=params, bands=bands, skills=skills, difficulty=difficulty, locales=locales, pillars=pillars)


# world -> list of (level name, offscreen key, [games])
LEVELS = {
    "animals": [
        ("farm", "moo_like_cow", [
            g("farm_names", "sound_match", {"items": "tags:animal+farm", "rounds": 5}, YOUNG, ["vocab.animals.farm"], STEPS_CHOICES),
            g("farm_pairs", "pairs_memory", {"items": "tags:animal+farm", "pairs": 2}, YOUNG, ["vocab.animals.farm", "memory"]),
            g("farm_food", "drag_to_target", {"mode": "food", "items": "tags:animal+farm", "rounds": 4}, ALL, ["knowledge.animals.food"], STEPS_TARGETS),
            g("farm_count", "tap_count", {"items": "tags:animal+farm", "numbers": [1, 5], "rounds": 3}, MID, ["number.count.to5"]),
        ]),
        ("pets", "wag_like_dog", [
            g("pet_names", "sound_match", {"items": "tags:animal+pet", "rounds": 5}, ALL, ["vocab.animals.pets"], STEPS_CHOICES),
            g("pet_sounds", "sound_match", {"mode": "sound", "items": ["dog", "cat", "mouse", "parrot", "cow", "sheep"], "rounds": 5}, ALL, ["listening.sounds"], STEPS_CHOICES),
            g("pet_food", "drag_to_target", {"mode": "food", "items": ["dog", "cat", "rabbit", "mouse"], "rounds": 4}, ALL, ["knowledge.animals.food"], STEPS_TARGETS),
        ]),
        ("jungle", "stomp_like_elephant", [
            g("jungle_names", "sound_match", {"items": "tags:animal+jungle", "rounds": 5}, ALL, ["vocab.animals.jungle"], STEPS_CHOICES),
            g("jungle_size", "sort_bins", {"by": "size", "items": "tag:animal", "perRound": 4, "rounds": 2,
                                           "bins": [{"value": "big", "item": "elephant", "say": "binBig"}, {"value": "small", "item": "mouse", "say": "binSmall"}]}, ALL, ["concept.size"]),
            g("jungle_sound_pairs", "pairs_memory", {"pairing": "picture_sound", "items": ["lion", "elephant", "monkey", "snake", "tiger", "parrot"], "pairs": 3}, MID, ["listening.sounds", "memory"]),
        ]),
        ("ocean", "swim_like_fish", [
            g("ocean_names", "sound_match", {"items": "tags:animal+ocean", "rounds": 5}, ALL, ["vocab.animals.ocean"], STEPS_CHOICES),
            g("land_water", "sort_bins", {"by": "lives", "items": "tag:animal", "perRound": 4, "rounds": 2,
                                          "bins": [{"value": "land", "item": "tree", "say": "binLand"}, {"value": "water", "item": "habitat_sea", "say": "binWater"}]}, ALL, ["knowledge.animals.habitat"]),
            g("ocean_pairs", "pairs_memory", {"items": "tags:animal+ocean", "pairs": 3}, MID, ["vocab.animals.ocean", "memory"]),
        ]),
        ("snow", "walk_like_penguin", [
            g("snow_names", "sound_match", {"items": ["penguin", "seal", "fox", "owl", "bear", "whale"], "rounds": 5}, ALL, ["vocab.animals.snow"], STEPS_CHOICES),
            g("snow_homes", "drag_to_target", {"mode": "habitat", "items": ["penguin", "seal", "fox", "cow", "lion", "whale", "dog"], "rounds": 4}, ALL, ["knowledge.animals.habitat"], STEPS_TARGETS),
            g("snow_sounds", "sound_match", {"mode": "sound", "items": ["penguin", "seal", "fox", "owl", "bear", "whale"], "rounds": 4}, MID, ["listening.sounds"], STEPS_CHOICES),
        ]),
        ("baby_mummy", "hug_grown_up", [
            g("find_mummy", "drag_to_target", {"mode": "baby", "items": "tags:animal+farm", "rounds": 4}, ALL, ["concept.size", "vocab.animals.farm"], STEPS_TARGETS),
            g("big_small", "sort_bins", {"by": "size", "items": "tag:animal", "perRound": 5, "rounds": 2,
                                         "bins": [{"value": "big", "item": "elephant", "say": "binBig"}, {"value": "small", "item": "mouse", "say": "binSmall"}]}, ALL, ["concept.size"]),
            g("baby_pairs", "pairs_memory", {"items": "tag:animal", "pairs": 3}, MID, ["memory"]),
        ]),
        ("homes", "build_den", [
            g("where_lives", "drag_to_target", {"mode": "habitat", "items": "tag:animal", "rounds": 5}, ALL, ["knowledge.animals.habitat"], STEPS_TARGETS),
            g("homes_land_water", "sort_bins", {"by": "lives", "items": "tag:animal", "perRound": 6, "rounds": 2,
                                                "bins": [{"value": "land", "item": "tree", "say": "binLand"}, {"value": "water", "item": "habitat_sea", "say": "binWater"}]}, MID, ["knowledge.animals.habitat"]),
            g("homes_names", "sound_match", {"items": "tag:habitat", "rounds": 4}, MID, ["vocab.places"], STEPS_CHOICES),
        ]),
        ("echo", "animal_charades", [
            g("echo_sounds", "sound_match", {"mode": "sound", "items": "tag:animal", "rounds": 5}, ALL, ["listening.sounds"], STEPS_CHOICES),
            g("echo_pairs", "pairs_memory", {"pairing": "picture_sound", "items": "tag:animal", "pairs": 4}, MID, ["listening.sounds", "memory"]),
            g("echo_names", "sound_match", {"items": "tag:animal", "rounds": 5}, ALL, ["vocab.animals.all"], STEPS_CHOICES),
        ]),
    ],
    "numbers": [
        ("to3", "jump_count", [
            g("count3", "tap_count", {"numbers": [1, 3], "items": "tags:animal+farm", "rounds": 4}, YOUNG, ["number.count.to3"]),
            g("find3", "sound_match", {"mode": "number", "numbers": [1, 3], "show": "group", "rounds": 4}, YOUNG, ["number.recognise.to3"], STEPS_UP_TO_3),
            g("pairs3", "pairs_memory", {"pairing": "numeral_dots", "numbers": [1, 3], "pairs": 3}, YOUNG, ["number.recognise.to3", "memory"]),
        ]),
        ("to5", "count_toys", [
            g("count5", "tap_count", {"numbers": [2, 5], "items": "tag:food", "rounds": 4}, ALL, ["number.count.to5"]),
            g("find5", "sound_match", {"mode": "number", "numbers": [1, 5], "rounds": 5}, ALL, ["number.numerals.to5"], STEPS_CHOICES),
            g("dots5", "sound_match", {"mode": "number", "numbers": [1, 5], "show": "dots", "rounds": 4}, ALL, ["number.subitise.to5"], STEPS_CHOICES),
        ]),
        ("to10", "count_steps", [
            g("count10", "tap_count", {"numbers": [5, 10], "items": "tag:object", "rounds": 3}, MID, ["number.count.to10"]),
            g("find10", "sound_match", {"mode": "number", "numbers": [1, 10], "rounds": 5, "choices": 3}, MID, ["number.numerals.to10"], STEPS_CHOICES),
            g("pairs10", "pairs_memory", {"pairing": "numeral_dots", "numbers": [1, 10], "pairs": 4}, MID, ["number.numerals.to10", "memory"]),
        ]),
        ("subitise", "find_dots", [
            g("dots6", "sound_match", {"mode": "number", "numbers": [1, 6], "show": "dots", "rounds": 5}, MID, ["number.subitise.to6"], STEPS_CHOICES),
            g("frames", "sound_match", {"mode": "number", "numbers": [6, 10], "show": "dots", "rounds": 4}, MID, ["number.subitise.to10"], STEPS_CHOICES),
            g("dot_pairs", "pairs_memory", {"pairing": "numeral_dots", "numbers": [1, 6], "pairs": 4}, MID, ["number.subitise.to6", "memory"]),
        ]),
        ("compare", "more_less_blocks", [
            g("more", "sound_match", {"mode": "more", "numbers": [1, 8], "items": "tag:food", "rounds": 5}, ALL, ["number.compare.more"]),
            g("fewer", "sound_match", {"mode": "fewer", "numbers": [1, 8], "items": "tag:food", "rounds": 5}, MID, ["number.compare.fewer"]),
            g("more3", "sound_match", {"mode": "more", "numbers": [1, 10], "choices": 3, "items": "tag:animal", "rounds": 4}, MID, ["number.compare.more"]),
        ]),
        ("trace", "air_write", [
            g("trace0_4", "trace_path", {"glyphs": ["0", "1", "2", "3", "4"]}, MID, ["number.write"]),
            g("trace5_9", "trace_path", {"glyphs": ["5", "6", "7", "8", "9"]}, MID, ["number.write"]),
            g("trace_find", "sound_match", {"mode": "number", "numbers": [0, 9], "rounds": 4, "choices": 3}, MID, ["number.numerals.to10"]),
        ]),
        ("share", "share_snack", [
            g("share2", "sort_bins", {"by": "share", "items": ["cherry"], "perRound": 4, "rounds": 3,
                                      "bins": [{"value": "a", "item": "plate"}, {"value": "b", "item": "plate"}]}, MID, ["number.share"]),
            g("share3", "sort_bins", {"by": "share", "items": ["strawberry"], "perRound": 6, "rounds": 2,
                                      "bins": [{"value": "a", "item": "plate"}, {"value": "b", "item": "plate"}, {"value": "c", "item": "plate"}]}, MID, ["number.share"]),
            g("share_count", "tap_count", {"numbers": [4, 8], "items": ["cherry", "strawberry", "apple"], "rounds": 3}, MID, ["number.count.to10"]),
        ]),
        ("bonds5", "five_fingers", [
            g("bond5", "sound_match", {"mode": "bond", "total": 5, "rounds": 5}, MID, ["number.bonds.5"], STEPS_CHOICES),
            g("bond5b", "sound_match", {"mode": "bond", "total": 5, "rounds": 5, "choices": 3}, MID, ["number.bonds.5"]),
            g("dots_to5", "sound_match", {"mode": "number", "numbers": [0, 5], "show": "dots", "rounds": 4}, MID, ["number.subitise.to5"]),
        ]),
        ("bonds10", "ten_fingers", [
            g("bond10", "sound_match", {"mode": "bond", "total": 10, "rounds": 5}, OLD, ["number.bonds.10"], STEPS_CHOICES),
            g("bond10b", "sound_match", {"mode": "bond", "total": 10, "rounds": 5, "choices": 4}, OLD, ["number.bonds.10"]),
            g("frames10", "sound_match", {"mode": "number", "numbers": [5, 10], "show": "dots", "rounds": 4}, OLD, ["number.subitise.to10"]),
        ]),
        ("add_sub", "add_spoons", [
            g("sum", "sound_match", {"mode": "sum", "numbers": [1, 10], "items": "tag:food", "rounds": 5}, OLD, ["number.add.within10"], STEPS_CHOICES),
            g("take_away", "sound_match", {"mode": "take_away", "numbers": [1, 10], "items": "tag:food", "rounds": 5}, OLD, ["number.subtract.within10"], STEPS_CHOICES),
            g("sum4", "sound_match", {"mode": "sum", "numbers": [1, 10], "choices": 4, "rounds": 4}, OLD, ["number.add.within10"]),
        ]),
    ],
    # One board game per level; pass-and-play or with Pip (chosen at the start).
    "board_games": [
        ("jigsaw", "real_puzzle", [
            g("jigsaw4", "jigsaw", {"pieces": 4, "items": "tag:animal", "rounds": 2}, YOUNG, ["spatial.puzzle"]),
            g("jigsaw9", "jigsaw", {"pieces": 9, "items": "tag:animal", "rounds": 2}, OLD, ["spatial.puzzle"]),
        ]),
        ("memory_table", "memory_objects", [
            g("memory_table", "pairs_memory", {"pairs": 4, "players": 2, "items": "tag:animal"}, ALL, ["memory", "social.turns"], pillars=PILLARS_BOARD),
        ]),
        ("jungle_race", "hop_race", [
            g("race3", "roll_and_move", {"dice": 3, "squares": 15, "vines": {"3": 8}, "slides": {"11": 6}, "questions": [5, 13]}, YOUNG, ["number.count.to3", "social.turns"]),
            g("race6", "roll_and_move", {"dice": 6}, OLD, ["number.count.to6", "social.turns"]),
        ]),
        ("bingo", "spy_room", [
            g("bingo_animals", "bingo", {"items": "tag:animal"}, ALL, ["vocab.animals.all", "listening", "social.turns"]),
        ]),
        ("feed_race", "feed_teddy", [
            g("feed3", "feed_race", {"dice": 3, "goal": 6, "food": "cherry"}, YOUNG, ["number.count.to3", "social.turns"]),
            g("feed6", "feed_race", {"dice": 6, "goal": 12, "food": "strawberry"}, OLD, ["number.count.to6", "social.turns"]),
        ]),
        ("dominoes", "line_up", [
            g("dominoes_pictures", "dominoes", {"mode": "picture", "items": "tags:animal+farm"}, MID, ["matching", "social.turns"]),
            g("dominoes_numbers", "dominoes", {"mode": "numeral_dots", "values": 5}, OLD, ["number.numerals.to6", "social.turns"]),
        ]),
        ("i_spy", "spy_room", [
            g("spy_colours", "i_spy", {"mode": "colour", "rounds": 4}, MID, ["colours.basic", "social.turns"]),
            g("spot_difference", "i_spy", {"mode": "difference", "rounds": 3}, OLD, ["attention.differences", "social.turns"]),
        ]),
        ("tic_tac_zoo", "family_game", [
            g("tic_tac_zoo", "tic_tac_zoo", {"boards": 2}, OLD, ["strategy.lines", "social.turns"]),
        ]),
    ],
    "shapes_colours": [
        ("basic_shapes", "shape_hunt", [
            g("find_basic", "sound_match", {"mode": "shape", "items": ["circle", "square", "triangle"], "rounds": 5}, ALL, ["shapes.basic"], STEPS_UP_TO_3),
            g("holes_basic", "drag_to_target", {"mode": "shape_hole", "items": ["circle", "square", "triangle"], "rounds": 4}, ALL, ["shapes.basic"], STEPS_TARGETS),
            g("trace_basic", "trace_path", {"glyphs": ["circle", "square", "triangle"]}, MID, ["shapes.draw"]),
        ]),
        ("more_shapes", "draw_shape", [
            g("find_more", "sound_match", {"mode": "shape", "items": "tag:shape", "rounds": 5}, MID, ["shapes.more"], STEPS_CHOICES),
            g("holes_more", "drag_to_target", {"mode": "shape_hole", "items": "tag:shape", "targets": 3, "rounds": 4}, MID, ["shapes.more"]),
            g("trace_more", "trace_path", {"glyphs": ["star", "heart", "diamond", "rectangle"]}, MID, ["shapes.draw"]),
        ]),
        ("colours", "colour_hunt", [
            g("find_colour", "sound_match", {"mode": "colour", "items": ["red", "blue", "yellow", "green"], "rounds": 5}, ALL, ["colours.basic"], STEPS_CHOICES),
            g("colour_pairs", "pairs_memory", {"items": ["red", "blue", "yellow", "green"], "pairs": 3}, YOUNG, ["colours.basic", "memory"]),
            g("sort_colour", "sort_bins", {"by": "colour", "items": "tag:food", "perRound": 4, "rounds": 2,
                                           "bins": [{"value": "red", "item": "red"}, {"value": "yellow", "item": "yellow"}]}, ALL, ["colours.basic", "sorting"]),
        ]),
        # TODO(engine): true paint-pot mixing needs its own engine; for now more colour names.
        ("more_colours", "mix_colours", [
            g("find_more_colours", "sound_match", {"mode": "colour", "items": "tag:colour", "rounds": 5}, MID, ["colours.more"], STEPS_CHOICES),
            g("sort_three_colours", "sort_bins", {"by": "colour", "items": "tag:food", "perRound": 6, "rounds": 2,
                                                  "bins": [{"value": "red", "item": "red"}, {"value": "yellow", "item": "yellow"}, {"value": "green", "item": "green"}]}, MID, ["colours.more", "sorting"]),
            g("colour_pairs_more", "pairs_memory", {"items": "tag:colour", "pairs": 4}, MID, ["colours.more", "memory"]),
        ]),
        ("patterns", "clap_pattern", [
            g("pattern_ab", "sequence_pattern", {"items": ["red", "blue", "yellow", "green"], "patterns": ["AB"], "rounds": 4}, ALL, ["pattern.ab"]),
            g("pattern_aab", "sequence_pattern", {"items": "tag:shape", "patterns": ["AAB", "ABB"], "length": 5, "rounds": 4}, MID, ["pattern.aab"]),
            g("pattern_abc", "sequence_pattern", {"items": "tags:animal+farm", "patterns": ["ABC"], "length": 6, "choices": 3, "rounds": 4}, MID, ["pattern.abc"]),
        ]),
        ("shapes_world", "shape_walk", [
            g("sort_shapes", "sort_bins", {"by": "shape", "items": "tag:object", "perRound": 4, "rounds": 2,
                                           "bins": [{"value": "circle", "item": "circle"}, {"value": "square", "item": "square"}]}, MID, ["shapes.in_world"]),
            g("sort_shapes3", "sort_bins", {"by": "shape", "items": "tag:object", "perRound": 5, "rounds": 2,
                                            "bins": [{"value": "circle", "item": "circle"}, {"value": "square", "item": "square"}, {"value": "triangle", "item": "triangle"}]}, OLD, ["shapes.in_world"]),
            g("shape_names", "sound_match", {"mode": "shape", "items": "tag:shape", "rounds": 5, "choices": 3}, MID, ["shapes.more"]),
        ]),
    ],
}

# Letters: separate orders per language (CLAUDE.md: never reuse English phonics order for Albanian).
EN_LETTERS = [
    (["s", "a", "t", "p"], ["sun", "snake", "socks", "seal", "ant", "apple", "tiger", "tent", "tree", "train", "pig", "penguin", "panda", "pear", "pizza"]),
    (["i", "n", "m", "d"], ["ladybird", "nose", "nest", "mouse", "moon", "monkey", "milk", "dog", "duck", "dolphin"]),
    (["g", "o", "c", "k"], ["goat", "grapes", "octopus", "orange_fruit", "cat", "cow", "car", "cup", "cake", "crab", "key", "kangaroo"]),
    (["e", "u", "r", "h"], ["egg", "elephant", "umbrella", "rabbit", "rain", "rainbow", "rooster", "hat", "horse", "hen", "house", "hand", "honey"]),
    (["b", "f", "l"], ["ball", "bee", "bus", "bed", "banana", "bear", "bird", "book", "boat", "fish", "frog", "fox", "flower", "foot", "lion", "leaf"]),
    (["j", "v", "w"], ["jacket", "watermelon", "whale", "cat", "dog"]),
    (["x", "y", "z"], ["zebra", "yellow", "fox", "sun"]),
]
EN_WORDS = [["cat", "dog", "pig", "sun", "hen"], ["bus", "fox", "bed", "hat", "cup"]]

# DRAFT Albanian order: vowels and frequent letters first, digraphs early as single tiles, blending early
# because spelling is phonetic. The educator defines the final order.
SQ_LETTERS = [
    (["a", "m", "e", "i"], ["cat", "apple", "mouse", "monkey", "elephant", "bear", "bus", "plane"]),
    (["o", "t", "r", "n"], ["octopus", "clock", "tiger", "tent", "train", "cake", "duck", "ball"]),
    (["s", "sh", "k", "u"], ["rain", "house", "watermelon", "bed", "horse", "crab", "kangaroo", "cheese"]),
    (["l", "d", "dh", "ll"], ["flower", "lion", "rabbit", "book", "sheep", "pig", "hand", "sun", "goat", "gift", "fox"]),
    (["p", "b", "g", "gj"], ["fish", "hen", "penguin", "tree", "bee", "frog", "banana", "bread", "crab", "mouth", "rooster", "giraffe", "snake", "leaf"]),
    (["f", "v", "z", "zh"], ["seal", "nest", "butterfly", "egg", "boat", "ear", "bird", "zebra", "heart_obj", "toad"]),
    (["h", "j", "q", "c", "ç"], ["nose", "moon", "dog", "milk", "cherry", "circus", "umbrella", "socks", "key"]),
    (["x", "xh", "y", "nj", "rr", "th", "ë"], ["jacket", "star_obj", "rainbow", "grapes", "boar"]),
]
SQ_WORDS = [["mouse", "dog", "ball", "goat", "rain", "star_obj", "bird", "bear"], ["cat", "sheep", "flower", "duck", "apple", "grapes", "fish", "rooster", "pig", "moon"]]

LETTER_OFFSCREEN = ["letter_hunt", "body_letter", "sound_walk", "letter_hunt", "body_letter", "sound_walk", "name_letters", "letter_hunt"]


REVIEW = {
    "en": [
        g("en_sort_sounds", "sort_bins", {"by": "first_letter", "items": ["sun", "snake", "socks", "seal", "tiger", "tent", "tree", "train"], "perRound": 4, "rounds": 2,
                                          "bins": [{"value": "s"}, {"value": "t"}]}, MID, ["letters.en.sounds"], locales=["en"]),
        g("en_review_pairs", "pairs_memory", {"pairing": "letter_picture", "items": "tag:animal", "pairs": 4}, MID, ["letters.en.sounds", "memory"], locales=["en"]),
        g("en_review_trace", "trace_path", {"glyphs": ["m", "a", "p"]}, MID, ["letters.en.write"], locales=["en"]),
    ],
    "sq": [
        g("sq_sort_sounds", "sort_bins", {"by": "first_letter", "items": ["rain", "house", "watermelon", "bed", "seal", "snake"], "perRound": 4, "rounds": 2,
                                          "bins": [{"value": "sh"}, {"value": "f"}]}, MID, ["letters.sq.sounds"], locales=["sq"]),
        g("sq_review_pairs", "pairs_memory", {"pairing": "letter_picture", "items": "tag:animal", "pairs": 4}, MID, ["letters.sq.sounds", "memory"], locales=["sq"]),
        g("sq_review_trace", "trace_path", {"glyphs": ["sh", "ë", "ç"]}, MID, ["letters.sq.write"], locales=["sq"]),
    ],
}


def letters_levels():
    """10 levels per language: letter groups, then blending, then a review.

    English: 7 groups + 2 blending + 1 review. Albanian: 8 groups + 2 blending, the review joins the last one.
    """
    levels = {}
    for loc, table, words in (("en", EN_LETTERS, EN_WORDS), ("sq", SQ_LETTERS, SQ_WORDS)):
        plan = []
        for letters, items in table:
            plan.append([
                g(f"{loc}_trace", "trace_path", {"glyphs": letters}, MID, [f"letters.{loc}.write"], locales=[loc]),
                g(f"{loc}_find", "sound_match", {"mode": "letter", "letters": letters, "rounds": 5}, MID, [f"letters.{loc}.recognise"],
                  {"raiseAfter": 3, "lowerAfter": 2, "steps": [{"choices": 2}, {"choices": min(3, len(letters))}]}, locales=[loc]),
                g(f"{loc}_starts", "sound_match", {"mode": "starts_with", "letters": letters, "items": items, "rounds": 5, "choices": 2},
                  ALL if len(plan) < 2 else MID, [f"letters.{loc}.sounds"], locales=[loc]),
                g(f"{loc}_pairs", "pairs_memory", {"pairing": "letter_picture", "letters": letters, "items": items, "pairs": 3}, MID,
                  [f"letters.{loc}.sounds", "memory"], locales=[loc]),
            ])
        for k, ws in enumerate(words):
            plan.append([
                g(f"{loc}_blend", "blend_tiles", {"words": {loc: ws}, "rounds": 4}, MID if k == 0 else OLD, [f"letters.{loc}.blend"], locales=[loc]),
                g(f"{loc}_blend_more", "blend_tiles", {"words": {loc: ws}, "rounds": 3}, OLD, [f"letters.{loc}.blend"], locales=[loc]),
                g(f"{loc}_word_pairs", "pairs_memory", {"pairing": "picture", "items": ws, "pairs": 4}, MID, ["memory"], locales=[loc]),
            ])
        if len(plan) < 10:
            plan.append(list(REVIEW[loc]))
        else:
            # Keep the level at ≤ 5 games for every band: the review replaces the extra blending game.
            plan[-1] = [x for x in plan[-1] if not x["name"].endswith("_blend_more")] + REVIEW[loc]
        assert len(plan) == 10, (loc, len(plan))
        for n, games in enumerate(plan, start=1):
            levels.setdefault(n, []).extend(games)
    return [(f"level{n}", LETTER_OFFSCREEN[(n - 1) % len(LETTER_OFFSCREEN)] if n <= len(LETTER_OFFSCREEN) else "read_with_grownup", levels[n]) for n in sorted(levels)]


def write_level(world, n, level_name, off, games):
    out = []
    for game in games:
        pid = f"{world}.{level_name}.l{n}.{game['name']}"
        pl = game["pillars"] or PILLARS[game["game"]]
        doc = {
            "id": pid, "world": world, "level": n, "game": game["game"], "ageBands": game["bands"], "skills": game["skills"],
            "curriculum": {"eyfs": EYFS[world], "ccss": [], "al": AL[world]},
            "params": game["params"],
            "pillars": {"active": pl[0], "engaged": pl[1], "meaningful": pl[2], "social": pl[3]},
            "offscreen": f"offscreen.{off}",
        }
        if game["difficulty"]:
            doc["difficulty"] = game["difficulty"]
        if game["locales"]:
            doc["locales"] = game["locales"]
        path = f"assets/content/games/{world}/l{n:02d}_{game['name']}.json"
        with open(path, "w", encoding="utf-8") as f:
            json.dump(doc, f, ensure_ascii=False, indent=1)
            f.write("\n")
        out.append(path)
    return out


ENGINE_WHAT = {
    "sound_match": "hear it, tap it", "drag_to_target": "drag to the right place", "tap_count": "tap and count",
    "trace_path": "trace", "pairs_memory": "memory pairs", "sequence_pattern": "what comes next",
    "sort_bins": "sort into bins", "blend_tiles": "build the word",
    "roll_and_move": "Jungle Race", "dominoes": "Animal Dominoes", "bingo": "Picture Bingo", "tic_tac_zoo": "Tic-Tac-Zoo",
    "jigsaw": "Jigsaw", "i_spy": "I Spy / Spot the difference", "feed_race": "Feed the Animals",
}

HEADER = """# Curriculum map — DRAFT for educator review

> **Status: draft, not signed off.** Generated from `app/tool/levels_table.py`; edit the table, not this file.
> PLAN.md phase 3 needs an educator to sign this off before release.

## Sign-off checklist (educator)

- [ ] Level order and age bands for each world
- [ ] **Albanian letter order** (currently provisional: vowels and frequent letters first, digraphs early as single
      letters, blending early because spelling is phonetic)
- [ ] English phonics order (currently s a t p / i n m d / g o c k / e u r h / b f l / j v w / x y z, then CVC)
- [ ] Word lists for starts-with, sorting and blending in both languages
- [ ] Stroke order of traced letters and numerals (app/lib/games/trace_path/glyph_strokes.dart)
- [ ] Pillar scores (active, engaged, meaningful, social; currently estimates per engine)
- [ ] Mastery threshold: 80% independent over at least 5 rounds (`minAttemptsForMastery`)
- [ ] Off-screen challenges (safe, doable at home, in both languages)
- [ ] Albanian wording reviewed by a native speaker (lib/l10n/app_sq.arb)

## Known gaps

- Shapes & Colours level 4 should be colour *mixing* (paint pots, dress Pip); that needs a new engine. For now it
  practises more colour names.
- Letters: English j, v, w, x, y, z and Albanian ll, nj, x, th, ë have few or no picture words in the vocabulary,
  so those levels lean on tracing and "find the letter".
- Pip's House talk-back works in the browser only until the native Android/iOS plugin is built.

"""


def write_curriculum_md(worlds):
    out = [HEADER]
    names = {"board_games": "Board Games", "animals": "Animals", "numbers": "Numbers", "letters": "Letters", "shapes_colours": "Shapes & Colours"}
    for world, levels in worlds.items():
        out.append(f"## {names[world]}\n")
        out.append("| Level | Games | Ages | Skills | Off-screen challenge |")
        out.append("| --- | --- | --- | --- | --- |")
        for n, (level_name, off, games) in enumerate(levels, start=1):
            gl = "<br>".join(
                f"{ENGINE_WHAT[x['game']]}"
                + (f" ({x['params'].get('mode') or x['params'].get('pairing') or x['params'].get('by') or ''})".replace(" ()", ""))
                + (f" [{','.join(x['locales'])}]" if x["locales"] else "")
                for x in games
            )
            ages = ", ".join(sorted({b for x in games for b in x["bands"]}))
            skills = ", ".join(sorted({s for x in games for s in x["skills"]}))
            out.append(f"| {n}. {level_name.replace('_', ' ')} | {gl} | {ages} | {skills} | {OFFSCREEN[off][0]} / {OFFSCREEN[off][1]} |")
        out.append("")
    open("../docs/CURRICULUM.md", "w", encoding="utf-8").write("\n".join(out))


def main():
    count = 0
    worlds = dict(LEVELS)
    worlds["letters"] = letters_levels()
    for world, levels in worlds.items():
        d = f"assets/content/games/{world}"
        if world != "animals" and os.path.isdir(d):
            shutil.rmtree(d)
        os.makedirs(d, exist_ok=True)
        if world == "animals":
            for f in os.listdir(d):
                if f.startswith("l") and f[1:3].isdigit():
                    os.remove(os.path.join(d, f))
        for n, (level_name, off, games) in enumerate(levels, start=1):
            count += len(write_level(world, n, level_name, off, games))
    # Off-screen strings.
    strings = {("offscreen_" + k).split("_")[0] + "".join(p.title() for p in k.split("_")): v for k, v in OFFSCREEN.items()}
    for locale, idx in (("en", 0), ("sq", 1)):
        p = f"lib/l10n/app_{locale}.arb"
        arb = json.load(open(p, encoding="utf-8"))
        for key, pair in strings.items():
            arb[key] = pair[idx]
        json.dump(arb, open(p, "w", encoding="utf-8"), ensure_ascii=False, indent=2)
        open(p, "a").write("\n")
    write_curriculum_md(worlds)
    print(f"{count} games in {sum(len(v) for v in worlds.values())} levels")


if __name__ == "__main__":
    main()
