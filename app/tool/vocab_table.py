#!/usr/bin/env python3
"""Single source for the picture vocabulary.

Writes assets/content/vocab/<category>.json and merges each item's name into
lib/l10n/app_en.arb and app_sq.arb (key vocab.<id> -> ARB key vocab<Id>).
Run from app/:  python3 tool/vocab_table.py && dart run tool/gen_lookup.dart

Albanian names are the indefinite citation form (lopë, not lopa) and need
native-speaker review (see docs/CURRICULUM.md). Emoji are placeholder art.
TODO(asset): replace emoji with illustrations.
"""
import json, os

# id, emoji, en, sq, tags, props
ANIMALS = [
    ("cow", "🐄", "Cow", "Lopë", "farm", dict(size="big", lives="land", food="grass", sound=True)),
    ("sheep", "🐑", "Sheep", "Dele", "farm", dict(size="big", lives="land", food="grass", sound=True)),
    ("pig", "🐖", "Pig", "Derr", "farm", dict(size="big", lives="land", food="apple", sound=True)),
    ("hen", "🐔", "Hen", "Pulë", "farm", dict(size="small", lives="land", food="corn", sound=True)),
    ("horse", "🐴", "Horse", "Kalë", "farm", dict(size="big", lives="land", food="carrot", sound=True)),
    ("duck", "🦆", "Duck", "Rosë", "farm", dict(size="small", lives="water", food="corn", sound=True)),
    ("goat", "🐐", "Goat", "Dhi", "farm", dict(size="big", lives="land", food="grass", sound=True)),
    ("rooster", "🐓", "Rooster", "Gjel", "farm", dict(size="small", lives="land", food="corn", sound=True)),
    ("dog", "🐶", "Dog", "Qen", "pet", dict(size="small", lives="land", food="bone", sound=True)),
    ("cat", "🐱", "Cat", "Mace", "pet", dict(size="small", lives="land", food="milk", sound=True)),
    ("rabbit", "🐰", "Rabbit", "Lepur", "pet", dict(size="small", lives="land", food="carrot", sound=True)),
    ("fish", "🐟", "Fish", "Peshk", "pet ocean", dict(size="small", lives="water", food="", sound=False)),
    ("parrot", "🦜", "Parrot", "Papagall", "pet jungle", dict(size="small", lives="land", food="corn", sound=True)),
    ("hamster", "🐹", "Hamster", "Hamster", "pet", dict(size="small", lives="land", food="corn", sound=False)),
    ("turtle", "🐢", "Turtle", "Breshkë", "pet", dict(size="small", lives="land", food="leaf", sound=False)),
    ("mouse", "🐭", "Mouse", "Mi", "pet", dict(size="small", lives="land", food="cheese", sound=True)),
    ("lion", "🦁", "Lion", "Luan", "jungle", dict(size="big", lives="land", food="", sound=True)),
    ("elephant", "🐘", "Elephant", "Elefant", "jungle", dict(size="big", lives="land", food="banana", sound=True)),
    ("monkey", "🐒", "Monkey", "Majmun", "jungle", dict(size="small", lives="land", food="banana", sound=True)),
    ("giraffe", "🦒", "Giraffe", "Gjirafë", "jungle", dict(size="big", lives="land", food="leaf", sound=False)),
    ("zebra", "🦓", "Zebra", "Zebër", "jungle", dict(size="big", lives="land", food="grass", sound=False)),
    ("tiger", "🐅", "Tiger", "Tigër", "jungle", dict(size="big", lives="land", food="", sound=True)),
    ("snake", "🐍", "Snake", "Gjarpër", "jungle", dict(size="small", lives="land", food="", sound=True)),
    ("crocodile", "🐊", "Crocodile", "Krokodil", "jungle", dict(size="big", lives="water", food="", sound=False)),
    ("whale", "🐳", "Whale", "Balenë", "ocean", dict(size="big", lives="water", food="", sound=True)),
    ("dolphin", "🐬", "Dolphin", "Delfin", "ocean", dict(size="big", lives="water", food="fish", sound=True)),
    ("octopus", "🐙", "Octopus", "Oktapod", "ocean", dict(size="small", lives="water", food="", sound=False)),
    ("crab", "🦀", "Crab", "Gaforre", "ocean", dict(size="small", lives="water", food="", sound=False)),
    ("shark", "🦈", "Shark", "Peshkaqen", "ocean", dict(size="big", lives="water", food="", sound=False)),
    ("penguin", "🐧", "Penguin", "Pinguin", "snow", dict(size="small", lives="land", food="fish", sound=True)),
    ("seal", "🦭", "Seal", "Fokë", "snow ocean", dict(size="big", lives="water", food="fish", sound=True)),
    ("fox", "🦊", "Fox", "Dhelpër", "snow", dict(size="small", lives="land", food="", sound=True)),
    ("owl", "🦉", "Owl", "Buf", "snow", dict(size="small", lives="land", food="", sound=True)),
    ("bear", "🐻", "Bear", "Ari", "snow", dict(size="big", lives="land", food="honey", sound=True)),
    ("bee", "🐝", "Bee", "Bletë", "garden", dict(size="small", lives="land", food="", sound=True)),
    ("frog", "🐸", "Frog", "Bretkosë", "garden", dict(size="small", lives="water", food="", sound=True)),
    ("toad", "🐸", "Toad", "Zhabë", "garden", dict(size="small", lives="water", food="", sound=True)),
    ("bird", "🐦", "Bird", "Zog", "garden", dict(size="small", lives="land", food="corn", sound=True)),
    ("butterfly", "🦋", "Butterfly", "Flutur", "garden", dict(size="small", lives="land", food="", sound=False)),
    ("ant", "🐜", "Ant", "Milingonë", "garden", dict(size="small", lives="land", food="", sound=False)),
    ("snail", "🐌", "Snail", "Kërmill", "garden", dict(size="small", lives="land", food="leaf", sound=False)),
    ("ladybird", "🐞", "Insect", "Mollëkuqe", "garden", dict(size="small", lives="land", food="", sound=False)),
    ("boar", "🐗", "Boar", "Thi", "forest", dict(size="big", lives="land", food="apple", sound=True)),
    ("kangaroo", "🦘", "Kangaroo", "Kangur", "jungle", dict(size="big", lives="land", food="grass", sound=False)),
    ("panda", "🐼", "Panda", "Panda", "jungle", dict(size="big", lives="land", food="leaf", sound=False)),
]

# id, emoji, en, sq, tags, colour
FOOD = [
    ("grass", "🌿", "Grass", "Bar", "food", "green"),
    ("carrot", "🥕", "Carrot", "Karotë", "food", "orange"),
    ("banana", "🍌", "Banana", "Banane", "food", "yellow"),
    ("bone", "🦴", "Bone", "Kockë", "food", "white"),
    ("milk", "🥛", "Milk", "Qumësht", "food", "white"),
    ("apple", "🍎", "Apple", "Mollë", "food", "red"),
    ("cheese", "🧀", "Cheese", "Djathë", "food", "yellow"),
    ("corn", "🌽", "Corn", "Misër", "food", "yellow"),
    ("honey", "🍯", "Honey", "Mjaltë", "food", "orange"),
    ("leaf", "🍃", "Leaf", "Gjethe", "food nature", "green"),
    ("grapes", "🍇", "Grapes", "Rrush", "food", "purple"),
    ("orange_fruit", "🍊", "Orange", "Portokall", "food", "orange"),
    ("strawberry", "🍓", "Strawberry", "Luleshtrydhe", "food", "red"),
    ("pear", "🍐", "Pear", "Dardhë", "food", "green"),
    ("bread", "🍞", "Bread", "Bukë", "food", "brown"),
    ("egg", "🥚", "Egg", "Vezë", "food", "white"),
    ("watermelon", "🍉", "Watermelon", "Shalqi", "food", "red"),
    ("cherry", "🍒", "Cherry", "Qershi", "food", "red"),
    ("cake", "🎂", "Cake", "Tortë", "food", "pink"),
    ("pizza", "🍕", "Pizza", "Pica", "food", "orange"),
]

# id, emoji, en, sq, tags, colour (or ""), shape (or "")
OBJECTS = [
    ("sun", "☀️", "Sun", "Diell", "nature", "yellow", "circle"),
    ("moon", "🌙", "Moon", "Hënë", "nature", "yellow", ""),
    ("star_obj", "⭐", "Star", "Yll", "nature", "yellow", "star"),
    ("rain", "🌧️", "Rain", "Shi", "nature", "blue", ""),
    ("rainbow", "🌈", "Rainbow", "Ylber", "nature", "", ""),
    ("flower", "🌸", "Flower", "Lule", "nature", "pink", ""),
    ("tree", "🌳", "Tree", "Pemë", "nature", "green", ""),
    ("ball", "⚽", "Ball", "Top", "toy", "white", "circle"),
    ("balloon", "🎈", "Balloon", "Tullumbace", "toy", "red", ""),
    ("gift", "🎁", "Present", "Dhuratë", "toy", "red", "square"),
    ("book", "📕", "Book", "Libër", "home", "red", "rectangle"),
    ("key", "🔑", "Key", "Çelës", "home", "yellow", ""),
    ("house", "🏠", "House", "Shtëpi", "home", "", ""),
    ("tent", "⛺", "Tent", "Tendë", "home", "", "triangle"),
    ("bed", "🛏️", "Bed", "Shtrat", "home", "", ""),
    ("cup", "☕", "Cup", "Filxhan", "home", "", ""),
    ("clock", "🕒", "Clock", "Orë", "home", "white", "circle"),
    ("heart_obj", "❤️", "Heart", "Zemër", "toy", "red", "heart"),
    ("car", "🚗", "Car", "Makinë", "vehicle", "red", ""),
    ("bus", "🚌", "Bus", "Autobus", "vehicle", "yellow", ""),
    ("train", "🚂", "Train", "Tren", "vehicle", "", ""),
    ("plane", "✈️", "Plane", "Aeroplan", "vehicle", "", ""),
    ("boat", "⛵", "Boat", "Varkë", "vehicle", "", ""),
    ("bike", "🚲", "Bike", "Biçikletë", "vehicle", "", ""),
    ("umbrella", "☂️", "Umbrella", "Çadër", "clothes", "purple", ""),
    ("hat", "👒", "Hat", "Kapelë", "clothes", "yellow", ""),
    ("socks", "🧦", "Socks", "Çorape", "clothes", "red", ""),
    ("jacket", "🧥", "Jacket", "Xhaketë", "clothes", "brown", ""),
    ("hand", "✋", "Hand", "Dorë", "body", "", ""),
    ("nose", "👃", "Nose", "Hundë", "body", "", ""),
    ("ear", "👂", "Ear", "Vesh", "body", "", ""),
    ("mouth", "👄", "Mouth", "Gojë", "body", "red", ""),
    ("foot", "🦶", "Foot", "Këmbë", "body", "", ""),
    ("nest", "🪺", "Nest", "Fole", "nature", "brown", ""),
    ("circus", "🎪", "Circus", "Cirk", "toy", "red", ""),
    ("plate", "🍽️", "Plate", "Pjatë", "home", "white", "circle"),
]

# id, emoji, en, sq  (drag_to_target "where does it live?")
HABITATS = [
    ("habitat_farm", "🚜", "Farm", "Fermë"), ("habitat_home", "🏡", "Home", "Shtëpi"),
    ("habitat_jungle", "🌴", "Jungle", "Xhungël"), ("habitat_sea", "🌊", "Sea", "Det"),
    ("habitat_snow", "❄️", "Snow", "Borë"), ("habitat_garden", "🌷", "Garden", "Kopsht"),
    ("habitat_forest", "🌲", "Forest", "Pyll"),
]
HABITAT_OF_TAG = {"farm": "habitat_farm", "pet": "habitat_home", "jungle": "habitat_jungle", "ocean": "habitat_sea",
                  "snow": "habitat_snow", "garden": "habitat_garden", "forest": "habitat_forest"}

COLOURS = [
    ("red", "#E53935", "Red", "E kuqe"), ("blue", "#1E88E5", "Blue", "Blu"),
    ("yellow", "#FDD835", "Yellow", "E verdhë"), ("green", "#43A047", "Green", "Jeshile"),
    ("orange", "#FB8C00", "Orange", "Portokalli"), ("purple", "#8E24AA", "Purple", "Vjollcë"),
    ("pink", "#F06292", "Pink", "Rozë"), ("brown", "#8D6E63", "Brown", "Kafe"),
    ("black", "#212121", "Black", "E zezë"), ("white", "#FFFFFF", "White", "E bardhë"),
]

SHAPES = [
    ("circle", "Circle", "Rreth"), ("square", "Square", "Katror"), ("triangle", "Triangle", "Trekëndësh"),
    ("rectangle", "Rectangle", "Drejtkëndësh"), ("star", "Star", "Yll"), ("heart", "Heart", "Zemër"),
    ("oval", "Oval", "Vezak"), ("diamond", "Diamond", "Romb"),
]


def arb_key(content_key):
    parts = [p for p in content_key.replace("_", ".").split(".") if p]
    return parts[0] + "".join(p[0].upper() + p[1:] for p in parts[1:])


def main():
    strings = {}  # content key -> (en, sq)
    files = {}

    def add_name(kind, id_, en, sq):
        key = f"{kind}.{id_}"
        strings[key] = (en, sq)
        return key

    animals = []
    for id_, emoji, en, sq, tags, props in ANIMALS:
        item = {"id": id_, "nameKey": add_name("vocab", id_, en, sq), "emoji": emoji,
                "tags": ["animal"] + tags.split()}
        if props.pop("sound"):
            item["soundKey"] = f"sfx.animal.{id_}"
        props["habitat"] = HABITAT_OF_TAG[tags.split()[0]]
        item["props"] = {k: v for k, v in props.items() if v}
        animals.append(item)
    files["animals"] = animals

    files["food"] = [
        {"id": id_, "nameKey": add_name("vocab", id_, en, sq), "emoji": emoji, "tags": tags.split(),
         "props": {"colour": colour}}
        for id_, emoji, en, sq, tags, colour in FOOD
    ]
    files["objects"] = [
        {"id": id_, "nameKey": add_name("vocab", id_, en, sq), "emoji": emoji, "tags": ["object"] + tags.split(),
         "props": {k: v for k, v in dict(colour=colour, shape=shape).items() if v}}
        for id_, emoji, en, sq, tags, colour, shape in OBJECTS
    ]
    files["habitats"] = [
        {"id": id_, "nameKey": add_name("vocab", id_, en, sq), "emoji": emoji, "tags": ["habitat"]}
        for id_, emoji, en, sq in HABITATS
    ]
    files["colours"] = [
        {"id": id_, "nameKey": add_name("colour", id_, en, sq), "colour": hexv, "tags": ["colour"]}
        for id_, hexv, en, sq in COLOURS
    ]
    files["shapes"] = [
        {"id": id_, "nameKey": add_name("shape", id_, en, sq), "shape": id_, "tags": ["shape"]}
        for id_, en, sq in SHAPES
    ]

    ids = [i["id"] for items in files.values() for i in items]
    dupes = {i for i in ids if ids.count(i) > 1}
    assert not dupes, f"duplicate vocab ids: {dupes}"

    os.makedirs("assets/content/vocab", exist_ok=True)
    for name, items in files.items():
        with open(f"assets/content/vocab/{name}.json", "w", encoding="utf-8") as f:
            json.dump({"category": name, "items": items}, f, ensure_ascii=False, indent=1)
            f.write("\n")

    for locale, idx in (("en", 0), ("sq", 1)):
        path = f"lib/l10n/app_{locale}.arb"
        with open(path, encoding="utf-8") as f:
            arb = json.load(f)
        for key, names in strings.items():
            arb[arb_key(key)] = names[idx]
        with open(path, "w", encoding="utf-8") as f:
            json.dump(arb, f, ensure_ascii=False, indent=2)
            f.write("\n")

    # Emoji used by vocab, for tool/subset_emoji.sh.
    with open("tool/emoji_used.txt", "w", encoding="utf-8") as f:
        f.write("".join(sorted({i["emoji"] for items in files.values() for i in items if "emoji" in i})))
        f.write("\n")
    print(f"{len(ids)} vocab items, {len(strings)} names")


if __name__ == "__main__":
    main()
