# Curriculum map — DRAFT for educator review

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


## Animals

| Level | Games | Ages | Skills | Off-screen challenge |
| --- | --- | --- | --- | --- |
| 1. farm | hear it, tap it<br>memory pairs<br>drag to the right place (food)<br>tap and count | 2-3, 4-5, 6-7 | knowledge.animals.food, memory, number.count.to5, vocab.animals.farm | Moo like a cow and crawl on all fours! / Bëj mu si lopa dhe ec me katër këmbë! |
| 2. pets | hear it, tap it<br>hear it, tap it (sound)<br>drag to the right place (food) | 2-3, 4-5, 6-7 | knowledge.animals.food, listening.sounds, vocab.animals.pets | Wag your tail like a happy dog! / Tunde bishtin si një qen i gëzuar! |
| 3. jungle | hear it, tap it<br>sort into bins (size)<br>memory pairs (picture_sound) | 2-3, 4-5, 6-7 | concept.size, listening.sounds, memory, vocab.animals.jungle | Stomp like an elephant: one, two, three! / Shkel fort si elefanti: një, dy, tre! |
| 4. ocean | hear it, tap it<br>sort into bins (lives)<br>memory pairs | 2-3, 4-5, 6-7 | knowledge.animals.habitat, memory, vocab.animals.ocean | Swim like a fish around the room! / Noto si peshk nëpër dhomë! |
| 5. snow | hear it, tap it<br>drag to the right place (habitat)<br>hear it, tap it (sound) | 2-3, 4-5, 6-7 | knowledge.animals.habitat, listening.sounds, vocab.animals.snow | Waddle like a penguin and show a grown-up! / Ec si pinguin dhe tregoja një të rrituri! |
| 6. baby mummy | drag to the right place (baby)<br>sort into bins (size)<br>memory pairs | 2-3, 4-5, 6-7 | concept.size, memory, vocab.animals.farm | Give a grown-up a big bear hug! / Përqafo fort një të rritur! |
| 7. homes | drag to the right place (habitat)<br>sort into bins (lives)<br>hear it, tap it | 2-3, 4-5, 6-7 | knowledge.animals.habitat, vocab.places | Build a cosy den with cushions! / Ndërto një strofull të ngrohtë me jastëkë! |
| 8. echo | hear it, tap it (sound)<br>memory pairs (picture_sound)<br>hear it, tap it | 2-3, 4-5, 6-7 | listening.sounds, memory, vocab.animals.all | Act like an animal. Can a grown-up guess which one? / Luaj si një kafshë. A e gjen i rrituri cila është? |

## Numbers

| Level | Games | Ages | Skills | Off-screen challenge |
| --- | --- | --- | --- | --- |
| 1. to3 | tap and count<br>hear it, tap it (number)<br>memory pairs (numeral_dots) | 2-3, 4-5 | memory, number.count.to3, number.recognise.to3 | Jump three times and count out loud! / Kërce tri herë dhe numëro me zë! |
| 2. to5 | tap and count<br>hear it, tap it (number)<br>hear it, tap it (number) | 2-3, 4-5, 6-7 | number.count.to5, number.numerals.to5, number.subitise.to5 | Count five toys and line them up! / Numëro pesë lodra dhe rreshtoji! |
| 3. to10 | tap and count<br>hear it, tap it (number)<br>memory pairs (numeral_dots) | 4-5, 6-7 | memory, number.count.to10, number.numerals.to10 | Count your steps to the door! / Numëro hapat deri te dera! |
| 4. subitise | hear it, tap it (number)<br>hear it, tap it (number)<br>memory pairs (numeral_dots) | 4-5, 6-7 | memory, number.subitise.to10, number.subitise.to6 | Find something with dots on it! / Gjej diçka me pika! |
| 5. compare | hear it, tap it (more)<br>hear it, tap it (fewer)<br>hear it, tap it (more) | 2-3, 4-5, 6-7 | number.compare.fewer, number.compare.more | Make two piles of blocks. Which has more? / Bëj dy grumbuj me kube. Cili ka më shumë? |
| 6. trace | trace<br>trace<br>hear it, tap it (number) | 4-5, 6-7 | number.numerals.to10, number.write | Write a number in the air with your finger! / Shkruaj një numër në ajër me gisht! |
| 7. share | sort into bins (share)<br>sort into bins (share)<br>tap and count | 4-5, 6-7 | number.count.to10, number.share | Share a snack fairly with someone! / Ndaje një ushqim në mënyrë të drejtë me dikë! |
| 8. bonds5 | hear it, tap it (bond)<br>hear it, tap it (bond)<br>hear it, tap it (number) | 4-5, 6-7 | number.bonds.5, number.subitise.to5 | Show five fingers, then hide some. How many are hiding? / Trego pesë gishta, pastaj fshih disa. Sa janë fshehur? |
| 9. bonds10 | hear it, tap it (bond)<br>hear it, tap it (bond)<br>hear it, tap it (number) | 6-7 | number.bonds.10, number.subitise.to10 | Show ten fingers! Bend some down and count the rest. / Trego dhjetë gishta! Palos disa dhe numëro të tjerët. |
| 10. add sub | hear it, tap it (sum)<br>hear it, tap it (take_away)<br>hear it, tap it (sum) | 6-7 | number.add.within10, number.subtract.within10 | Put two spoons and one more on the table. How many? / Vendos dy lugë dhe një tjetër në tavolinë. Sa janë? |

## Shapes & Colours

| Level | Games | Ages | Skills | Off-screen challenge |
| --- | --- | --- | --- | --- |
| 1. basic shapes | hear it, tap it (shape)<br>drag to the right place (shape_hole)<br>trace | 2-3, 4-5, 6-7 | shapes.basic, shapes.draw | Find something round and something square! / Gjej diçka të rrumbullakët dhe diçka katrore! |
| 2. more shapes | hear it, tap it (shape)<br>drag to the right place (shape_hole)<br>trace | 4-5, 6-7 | shapes.draw, shapes.more | Draw a big circle in the air! / Vizato një rreth të madh në ajër! |
| 3. colours | hear it, tap it (colour)<br>memory pairs<br>sort into bins (colour) | 2-3, 4-5, 6-7 | colours.basic, memory, sorting | Find three red things at home! / Gjej tri gjëra të kuqe në shtëpi! |
| 4. more colours | hear it, tap it (colour)<br>sort into bins (colour)<br>memory pairs | 4-5, 6-7 | colours.more, memory, sorting | Ask a grown-up to help you mix two paints! / Kërkoji një të rrituri të të ndihmojë të përziesh dy bojëra! |
| 5. patterns | what comes next<br>what comes next<br>what comes next | 2-3, 4-5, 6-7 | pattern.aab, pattern.ab, pattern.abc | Clap a pattern: clap, stamp, clap, stamp! / Duartrokit një model: duartrokit, shkel, duartrokit, shkel! |
| 6. shapes world | sort into bins (shape)<br>sort into bins (shape)<br>hear it, tap it (shape) | 4-5, 6-7 | shapes.in_world, shapes.more | Walk around the room and name the shapes you see! / Ec nëpër dhomë dhe thuaj emrat e formave që sheh! |

## Letters

| Level | Games | Ages | Skills | Off-screen challenge |
| --- | --- | --- | --- | --- |
| 1. level1 | trace [en]<br>hear it, tap it (letter) [en]<br>hear it, tap it (starts_with) [en]<br>memory pairs (letter_picture) [en]<br>trace [sq]<br>hear it, tap it (letter) [sq]<br>hear it, tap it (starts_with) [sq]<br>memory pairs (letter_picture) [sq] | 2-3, 4-5, 6-7 | letters.en.recognise, letters.en.sounds, letters.en.write, letters.sq.recognise, letters.sq.sounds, letters.sq.write, memory | Find something at home that starts with the same sound! / Gjej diçka në shtëpi që fillon me të njëjtin tingull! |
| 2. level2 | trace [en]<br>hear it, tap it (letter) [en]<br>hear it, tap it (starts_with) [en]<br>memory pairs (letter_picture) [en]<br>trace [sq]<br>hear it, tap it (letter) [sq]<br>hear it, tap it (starts_with) [sq]<br>memory pairs (letter_picture) [sq] | 2-3, 4-5, 6-7 | letters.en.recognise, letters.en.sounds, letters.en.write, letters.sq.recognise, letters.sq.sounds, letters.sq.write, memory | Make the letter's shape with your body! / Bëje formën e shkronjës me trupin tënd! |
| 3. level3 | trace [en]<br>hear it, tap it (letter) [en]<br>hear it, tap it (starts_with) [en]<br>memory pairs (letter_picture) [en]<br>trace [sq]<br>hear it, tap it (letter) [sq]<br>hear it, tap it (starts_with) [sq]<br>memory pairs (letter_picture) [sq] | 4-5, 6-7 | letters.en.recognise, letters.en.sounds, letters.en.write, letters.sq.recognise, letters.sq.sounds, letters.sq.write, memory | Say the sound every time you take a step! / Thuaj tingullin sa herë që bën një hap! |
| 4. level4 | trace [en]<br>hear it, tap it (letter) [en]<br>hear it, tap it (starts_with) [en]<br>memory pairs (letter_picture) [en]<br>trace [sq]<br>hear it, tap it (letter) [sq]<br>hear it, tap it (starts_with) [sq]<br>memory pairs (letter_picture) [sq] | 4-5, 6-7 | letters.en.recognise, letters.en.sounds, letters.en.write, letters.sq.recognise, letters.sq.sounds, letters.sq.write, memory | Find something at home that starts with the same sound! / Gjej diçka në shtëpi që fillon me të njëjtin tingull! |
| 5. level5 | trace [en]<br>hear it, tap it (letter) [en]<br>hear it, tap it (starts_with) [en]<br>memory pairs (letter_picture) [en]<br>trace [sq]<br>hear it, tap it (letter) [sq]<br>hear it, tap it (starts_with) [sq]<br>memory pairs (letter_picture) [sq] | 4-5, 6-7 | letters.en.recognise, letters.en.sounds, letters.en.write, letters.sq.recognise, letters.sq.sounds, letters.sq.write, memory | Make the letter's shape with your body! / Bëje formën e shkronjës me trupin tënd! |
| 6. level6 | trace [en]<br>hear it, tap it (letter) [en]<br>hear it, tap it (starts_with) [en]<br>memory pairs (letter_picture) [en]<br>trace [sq]<br>hear it, tap it (letter) [sq]<br>hear it, tap it (starts_with) [sq]<br>memory pairs (letter_picture) [sq] | 4-5, 6-7 | letters.en.recognise, letters.en.sounds, letters.en.write, letters.sq.recognise, letters.sq.sounds, letters.sq.write, memory | Say the sound every time you take a step! / Thuaj tingullin sa herë që bën një hap! |
| 7. level7 | trace [en]<br>hear it, tap it (letter) [en]<br>hear it, tap it (starts_with) [en]<br>memory pairs (letter_picture) [en]<br>trace [sq]<br>hear it, tap it (letter) [sq]<br>hear it, tap it (starts_with) [sq]<br>memory pairs (letter_picture) [sq] | 4-5, 6-7 | letters.en.recognise, letters.en.sounds, letters.en.write, letters.sq.recognise, letters.sq.sounds, letters.sq.write, memory | Find the first letter of your name somewhere! / Gjej diku shkronjën e parë të emrit tënd! |
| 8. level8 | build the word [en]<br>build the word [en]<br>memory pairs (picture) [en]<br>trace [sq]<br>hear it, tap it (letter) [sq]<br>hear it, tap it (starts_with) [sq]<br>memory pairs (letter_picture) [sq] | 4-5, 6-7 | letters.en.blend, letters.sq.recognise, letters.sq.sounds, letters.sq.write, memory | Find something at home that starts with the same sound! / Gjej diçka në shtëpi që fillon me të njëjtin tingull! |
| 9. level9 | build the word [en]<br>build the word [en]<br>memory pairs (picture) [en]<br>build the word [sq]<br>build the word [sq]<br>memory pairs (picture) [sq] | 4-5, 6-7 | letters.en.blend, letters.sq.blend, memory | Read a picture book with a grown-up! / Lexo një libër me figura me një të rritur! |
| 10. level10 | sort into bins (first_letter) [en]<br>memory pairs (letter_picture) [en]<br>trace [en]<br>build the word [sq]<br>memory pairs (picture) [sq]<br>sort into bins (first_letter) [sq]<br>memory pairs (letter_picture) [sq]<br>trace [sq] | 4-5, 6-7 | letters.en.sounds, letters.en.write, letters.sq.blend, letters.sq.sounds, letters.sq.write, memory | Read a picture book with a grown-up! / Lexo një libër me figura me një të rritur! |
