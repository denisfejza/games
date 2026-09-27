#!/usr/bin/env python3
"""Synthesises every placeholder sound (no recordings, no text-to-speech).

Writes MP3 (plays everywhere, including Safari/iOS) into:
  assets/audio/sfx/<effect>.mp3        interface effects
  assets/audio/sfx/animal<Name>.mp3    cartoon animal noises (sfx.animal.<id>)
  assets/audio/babble/<kind><n>.mp3    Pip's babble voice, used while narration recordings are missing
  assets/audio/music/meadow.mp3        calm background loop

Run from app/:  pip install numpy scipy soundfile && python3 tool/make_sounds.py
TODO(asset): replace animal noises with real CC0 recordings and narration with native voice actors.
"""
import os

import numpy as np
import soundfile as sf
from scipy import signal

SR = 22050
rng = np.random.default_rng(7)
OUT = "assets/audio"


# ---------------------------------------------------------------- building blocks
def secs(d):
    return np.arange(int(SR * d)) / SR


def env(n, a=0.01, r=0.05, shape=1.0):
    """Attack/release envelope over n samples (seconds)."""
    e = np.ones(n)
    na, nr = max(1, int(a * SR)), max(1, int(r * SR))
    na, nr = min(na, n // 2), min(nr, n // 2)
    e[:na] = np.linspace(0, 1, na) ** shape
    e[-nr:] = np.linspace(1, 0, nr) ** shape
    return e


def decay(n, tau):
    return np.exp(-np.arange(n) / SR / tau)


def phase(freq):
    """Phase for a (possibly changing) frequency array."""
    return 2 * np.pi * np.cumsum(freq) / SR


def contour(points, n):
    """Piecewise-linear contour through (time 0-1, value) points."""
    xs = np.array([p[0] for p in points]) * (n - 1)
    ys = np.array([p[1] for p in points])
    return np.interp(np.arange(n), xs, ys)


def band(x, lo, hi, order=2):
    b, a = signal.butter(order, [lo / (SR / 2), min(hi, SR / 2 - 100) / (SR / 2)], btype="band")
    return signal.lfilter(b, a, x)


def lowpass(x, hi, order=2):
    b, a = signal.butter(order, hi / (SR / 2), btype="low")
    return signal.lfilter(b, a, x)


def noise(n):
    return rng.standard_normal(n)


VOWELS = {  # (F1, F2, F3) in Hz, child-ish
    "a": (850, 1300, 2800), "e": (600, 2100, 2900), "i": (350, 2600, 3300), "o": (550, 900, 2700),
    "u": (380, 850, 2500), "m": (280, 1000, 2400),
}


def voice(f0, formants, n, bright=1.0, bw=(90, 120, 170)):
    """Harmonic source shaped by (moving) formants. f0: array; formants: list of 3 arrays."""
    ph = phase(f0)
    out = np.zeros(n)
    kmax = int((SR / 2 - 200) / max(60, f0.min()))
    for k in range(1, min(kmax, 60) + 1):
        fk = k * f0
        amp = np.zeros(n)
        for (F, b) in zip(formants, bw):
            amp += 1.0 / (1 + ((fk - F) / b) ** 2)
        amp *= (fk < SR / 2 - 200) / k ** (1.2 / bright)
        out += amp * np.sin(k * ph)
    return out


def vowel_track(seq, n):
    """Formant arrays gliding through a vowel sequence."""
    tracks = []
    for i in range(3):
        pts = [(j / max(1, len(seq) - 1), VOWELS[v][i]) for j, v in enumerate(seq)]
        tracks.append(contour(pts, n))
    return tracks


def syllable(f0_pts, vowels, d, bright=1.0, breath=0.0, a=0.02, r=0.06, rough=0.0):
    n = int(SR * d)
    f0 = contour(f0_pts, n)
    x = voice(f0, vowel_track(vowels, n), n, bright)
    if breath:
        x += breath * band(noise(n), 1500, 7000) * np.abs(x).max()
    if rough:
        am = 1 + rough * lowpass(noise(n), 60)
        x *= am
    return x * env(n, a, r)


def silence(d):
    return np.zeros(int(SR * d))


def cat_(*parts):
    return np.concatenate(parts)


def mix(*parts):
    n = max(len(p) for p in parts)
    out = np.zeros(n)
    for p in parts:
        out[: len(p)] += p
    return out


def room(x, wet=0.18):
    """A little warmth: a few early reflections."""
    out = np.copy(x)
    for ms, g in ((31, 0.5), (53, 0.35), (79, 0.25), (113, 0.15)):
        d = int(SR * ms / 1000)
        out[d:] += g * wet * x[:-d]
    return out


def write(path, x, peak=0.8, bitrate_ok=True):
    x = np.asarray(x, dtype=np.float64)
    x = x - x.mean()
    m = np.abs(x).max() or 1
    x = x / m * peak
    x = x * env(len(x), 0.004, 0.02)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    sf.write(path, x.astype(np.float32), SR, format="MP3")


def tone(freq, d, kind="sine", tau=None, a=0.005, r=0.03):
    n = int(SR * d)
    f = freq if np.ndim(freq) else np.full(n, float(freq))
    ph = phase(f)
    x = {"sine": np.sin(ph), "tri": signal.sawtooth(ph, 0.5), "square": np.tanh(3 * np.sin(ph)),
         "saw": signal.sawtooth(ph)}[kind]
    x = x * env(n, a, r)
    if tau:
        x *= decay(n, tau)
    return x


def mallet(freq, d=0.5, tau=0.18):
    """Marimba-like note."""
    n = int(SR * d)
    t = secs(d)
    x = np.sin(2 * np.pi * freq * t) + 0.35 * np.sin(2 * np.pi * freq * 4 * t) * decay(n, tau / 4)
    return x * decay(n, tau) * env(n, 0.002, 0.02)


def note(name):
    names = {"C": -9, "D": -7, "E": -5, "F": -4, "G": -2, "A": 0, "B": 2}
    octave = int(name[-1])
    semis = names[name[0]] + (1 if "#" in name else 0) + (octave - 4) * 12
    return 440 * 2 ** (semis / 12)


# ---------------------------------------------------------------- interface effects
def effects():
    d = f"{OUT}/sfx"
    write(f"{d}/tap.mp3", mix(tone(1200, 0.06, tau=0.015), 0.2 * band(noise(400), 2000, 6000) * decay(400, 0.004)), 0.5)
    write(f"{d}/correct.mp3", room(mix(mallet(note("G5"), 0.5), cat_(silence(0.11), mallet(note("C6"), 0.6)))), 0.7)
    # Curious "hm?" — rising, soft, never a buzzer.
    write(f"{d}/try_again.mp3", room(cat_(tone(note("A4"), 0.14, "tri", a=0.02, r=0.05), tone(note("C5"), 0.22, "tri", a=0.02, r=0.1))), 0.45)
    arp = cat_(*[cat_(mallet(note(nm), 0.18, 0.12)) for nm in ("C5", "E5", "G5")], mallet(note("C6"), 0.7, 0.3))
    sparkle = mix(*[cat_(silence(0.35 + 0.07 * i), tone(note(nm), 0.12, tau=0.05)) for i, nm in enumerate(("E6", "G6", "B6", "E7"))])
    write(f"{d}/celebrate.mp3", room(mix(arp, 0.4 * sparkle)), 0.75)
    write(f"{d}/pop.mp3", tone(contour([(0, 350), (1, 1300)], int(SR * 0.08)), 0.08, tau=0.04), 0.55)
    write(f"{d}/giggle.mp3", room(cat_(*[cat_(syllable([(0, f), (1, f * 0.93)], "ii", 0.09, breath=0.3, a=0.005, r=0.04), silence(0.04))
                                          for f in (760, 700, 660, 600)])), 0.6)
    write(f"{d}/yawn.mp3", room(syllable([(0, 330), (0.3, 360), (1, 170)], "aao", 1.3, breath=0.6, a=0.2, r=0.5)), 0.5)
    write(f"{d}/flip.mp3", band(noise(int(SR * 0.12)), 2500, 7000) * env(int(SR * 0.12), 0.03, 0.08), 0.35)
    n = int(SR * 0.28)
    write(f"{d}/hop.mp3", tone(contour([(0, 260), (0.35, 720), (1, 520)], n) * (1 + 0.04 * np.sin(2 * np.pi * 18 * secs(0.28))), 0.28, tau=0.14), 0.55)
    n = int(SR * 0.7)
    vib = 1 + 0.03 * np.sin(2 * np.pi * 6 * secs(0.7))
    write(f"{d}/slide.mp3", tone(contour([(0, 1400), (1, 380)], n) * vib, 0.7, a=0.02, r=0.15), 0.45)
    write(f"{d}/climb.mp3", tone(contour([(0, 380), (1, 1400)], n) * vib, 0.7, a=0.02, r=0.15), 0.45)
    clicks = [cat_(silence(t), band(noise(330), 1200, 4500) * decay(330, 0.005)) for t in (0, 0.07, 0.15, 0.21, 0.3, 0.36)]
    thunk = cat_(silence(0.45), tone(170, 0.12, tau=0.04))
    write(f"{d}/dice.mp3", mix(*clicks, thunk), 0.6)
    write(f"{d}/snap.mp3", mix(tone(190, 0.1, tau=0.03), 0.5 * band(noise(500), 1500, 5000) * decay(500, 0.006)), 0.6)
    write(f"{d}/star.mp3", room(cat_(*[tone(note(nm), 0.1, tau=0.06) for nm in ("E6", "G6", "B6")], tone(note("E7"), 0.3, tau=0.12))), 0.5)
    munch = cat_(*[cat_(lowpass(noise(int(SR * 0.06)), 1800) * env(int(SR * 0.06), 0.005, 0.03), silence(0.06)) for _ in range(3)])
    write(f"{d}/munch.mp3", munch, 0.6)


# ---------------------------------------------------------------- animals (cartoon placeholders)
def animals():
    A = {}
    A["cow"] = room(syllable([(0, 118), (0.3, 112), (1, 92)], "mmoou", 1.5, a=0.15, r=0.4, bright=0.8, rough=0.1))
    bleat = lambda f, d: syllable([(0, f), (1, f * 0.92)], "eaa", d, breath=0.2, rough=0.0) * (1 + 0.5 * np.sin(2 * np.pi * 8 * secs(d)))
    A["sheep"] = room(bleat(390, 0.9))
    A["goat"] = room(bleat(520, 0.75) * (1 + 0.4 * np.sin(2 * np.pi * 12 * secs(0.75))))
    oink = lambda f: cat_(syllable([(0, f), (1, f * 0.75)], "mo", 0.16, bright=0.7, rough=0.4, breath=0.3, a=0.01, r=0.05), silence(0.08))
    A["pig"] = room(cat_(oink(190), oink(175), oink(200)))
    A["boar"] = room(cat_(oink(120), oink(110), oink(125)))
    cluck = lambda f: cat_(syllable([(0, f), (1, f * 0.8)], "ao", 0.07, breath=0.4, a=0.003, r=0.03), silence(0.09))
    A["hen"] = room(cat_(cluck(620), cluck(600), cluck(640), syllable([(0, 520), (0.4, 760), (1, 470)], "aa", 0.35, breath=0.3)))
    A["rooster"] = room(cat_(*[syllable([(0, f), (1, f * 1.05)], v, d, breath=0.25, a=0.01, r=0.03) for f, v, d in
                               ((520, "ao", 0.13), (700, "oa", 0.1), (650, "ou", 0.1), (820, "uo", 0.12))],
                             syllable([(0, 900), (0.2, 950), (1, 560)], "ouu", 0.6, breath=0.25, r=0.2)))
    n = int(SR * 1.1)
    neigh = syllable([(0, 650), (0.25, 1150), (0.6, 900), (1, 480)], "eea", 1.1, breath=0.5)
    A["horse"] = room(neigh * (1 + 0.8 * np.sin(2 * np.pi * 24 * secs(1.1))) * env(n, 0.05, 0.3))
    quack = lambda: cat_(syllable([(0, 320), (1, 250)], "aa", 0.2, bright=2.0, breath=0.5, rough=0.5, a=0.005), silence(0.1))
    A["duck"] = room(cat_(quack(), quack()))
    bark = lambda f: cat_(mix(syllable([(0, f), (1, f * 0.6)], "ao", 0.15, bright=1.5, breath=0.6, rough=0.3, a=0.003, r=0.08)), silence(0.12))
    A["dog"] = room(cat_(bark(380), bark(360)))
    A["fox"] = room(cat_(bark(900), bark(950)))
    A["seal"] = room(cat_(*[cat_(syllable([(0, 260), (1, 200)], "ao", 0.22, rough=0.4, breath=0.3), silence(0.1)) for _ in range(3)]))
    A["cat"] = room(syllable([(0, 450), (0.45, 680), (1, 400)], "iau", 0.85, breath=0.15, a=0.05, r=0.25))
    squeak = lambda: cat_(tone(contour([(0, 2900), (1, 3700)], int(SR * 0.07)), 0.07, tau=0.05), silence(0.07))
    A["mouse"] = cat_(squeak(), squeak(), squeak())
    A["parrot"] = room(syllable([(0, 900), (0.5, 1100), (1, 850)], "aa", 0.4, bright=2.5, breath=0.7, rough=0.7))
    roar = lambda f, d: syllable([(0, f), (0.3, f * 1.1), (1, f * 0.7)], "aao", d, bright=1.2, breath=0.9, rough=1.2, a=0.1, r=0.4)
    A["lion"] = room(mix(roar(125, 1.6), 0.6 * lowpass(noise(int(SR * 1.6)), 700) * env(int(SR * 1.6), 0.1, 0.5)))
    A["tiger"] = room(roar(150, 1.0))
    A["bear"] = room(roar(95, 1.1))
    A["elephant"] = room(syllable([(0, 420), (0.4, 640), (1, 460)], "ae", 1.2, bright=3.0, breath=0.6, rough=0.3, a=0.05, r=0.3))
    A["monkey"] = room(cat_(*[cat_(syllable([(0, f), (1, f * 1.1)], v, 0.17, breath=0.2), silence(0.05))
                              for f, v in ((420, "uu"), (500, "uu"), (620, "aa"), (720, "aa"))]))
    n = int(SR * 1.0)
    A["snake"] = band(noise(n), 3500, 9500) * env(n, 0.15, 0.3)
    n = int(SR * 2.2)
    f = contour([(0, 300), (0.4, 620), (0.7, 480), (1, 240)], n) * (1 + 0.02 * np.sin(2 * np.pi * 4 * secs(2.2)))
    A["whale"] = room(room(tone(f, 2.2, a=0.3, r=0.6) + 0.3 * tone(f * 2, 2.2, a=0.3, r=0.6)), 0.4)
    clicks = cat_(*[cat_(band(noise(120), 3000, 9000) * decay(120, 0.002), silence(0.05)) for _ in range(5)])
    n = int(SR * 0.5)
    A["dolphin"] = cat_(clicks, tone(contour([(0, 5500), (0.5, 8200), (1, 6500)], n), 0.5, a=0.02, r=0.1))
    honk = lambda d: cat_(syllable([(0, 300), (1, 280)], "aa", d, bright=2.2, rough=0.3, breath=0.3), silence(0.08))
    A["penguin"] = room(cat_(honk(0.18), honk(0.18), honk(0.45)))
    hoo = lambda d: cat_(syllable([(0, 390), (1, 360)], "uu", d, bright=0.5, breath=0.2, a=0.08, r=0.15), silence(0.2))
    A["owl"] = room(cat_(hoo(0.3), hoo(0.45)))
    n = int(SR * 1.0)
    buzz = signal.sawtooth(phase(220 + 12 * np.sin(2 * np.pi * 3 * secs(1.0)))) * (1 + 0.4 * np.sin(2 * np.pi * 22 * secs(1.0)))
    A["bee"] = lowpass(buzz, 2500) * env(n, 0.1, 0.2)
    ribbit = lambda f: cat_(syllable([(0, f), (1, f * 0.9)], "mo", 0.14, rough=0.2) * (0.6 + 0.4 * np.sign(np.sin(2 * np.pi * 55 * secs(0.14)))), silence(0.08))
    A["frog"] = room(cat_(ribbit(190), ribbit(210)))
    A["toad"] = room(cat_(ribbit(120), ribbit(125), ribbit(118)))
    chirp = lambda: cat_(tone(contour([(0, 3000), (1, 4600)], int(SR * 0.08)), 0.08, tau=0.06), silence(0.05))
    A["bird"] = room(cat_(chirp(), chirp(), chirp(), tone(contour([(0, 4200), (1, 3400)], int(SR * 0.25)), 0.25) * (1 + 0.6 * np.sin(2 * np.pi * 30 * secs(0.25)))))
    sniff = lambda: cat_(band(noise(int(SR * 0.05)), 1500, 6000) * env(int(SR * 0.05), 0.01, 0.03), silence(0.06))
    A["rabbit"] = cat_(sniff(), sniff(), sniff(), silence(0.1), tone(90, 0.12, tau=0.04))
    for k, x in A.items():
        write(f"{OUT}/sfx/animal{k[0].upper()}{k[1:]}.mp3", x)
    return sorted(A)


# ---------------------------------------------------------------- Pip's babble voice
def babble():
    """Pip "talks" in friendly gibberish syllables while narration recordings are missing.

    Six lengths (~0.5–3 s), statement and question (rising end) versions.
    """
    lengths = [0.5, 0.9, 1.3, 1.8, 2.4, 3.0]
    vowels = "aeiou"
    for kind in ("say", "ask"):
        r = np.random.default_rng(11 if kind == "say" else 13)
        for i, total in enumerate(lengths, start=1):
            parts = []
            t = 0.0
            while t < total:
                d = r.uniform(0.09, 0.15)
                progress = t / total
                base = 430 + 50 * np.sin(np.pi * progress)  # arc across the phrase
                end_rise = 1.25 if kind == "ask" and progress > 0.75 else 1.0
                f0 = base * r.uniform(0.92, 1.1) * end_rise
                v = vowels[r.integers(len(vowels))] + vowels[r.integers(len(vowels))]
                s = syllable([(0, f0), (1, f0 * r.uniform(0.95, 1.12))], v, d, breath=0.12, a=0.012, r=0.035)
                if r.random() < 0.35:  # a soft consonant-ish onset
                    s[: int(SR * 0.015)] += 0.3 * band(noise(int(SR * 0.015)), 2000, 6000) * np.abs(s).max()
                parts += [s, silence(r.uniform(0.015, 0.05))]
                t += d + 0.03
                if r.random() < 0.12:  # tiny pause between "words"
                    parts.append(silence(0.08))
                    t += 0.08
            write(f"{OUT}/babble/{kind}{i}.mp3", room(cat_(*parts)), 0.55)
    return lengths


# ---------------------------------------------------------------- music
def music():
    """8 bars, 92 bpm, C–Am–F–G twice: soft mallets, round bass, gentle pad. Starts and ends quietly so the loop is seamless."""
    bpm = 92
    beat = 60 / bpm
    bars = 8
    total = int(SR * beat * 4 * bars)
    out = np.zeros(total + SR * 2)
    chords = [["C4", "E4", "G4"], ["A3", "C4", "E4"], ["F3", "A3", "C4"], ["G3", "B3", "D4"]] * 2
    bass = ["C3", "A2", "F2", "G2"] * 2
    melody = [  # (beat, note) per bar, pentatonic, calm
        [(0, "E5"), (1.5, "G5"), (2, "A5"), (3, "G5")], [(0, "E5"), (2, "D5"), (3, "C5")],
        [(0, "C5"), (1, "D5"), (2, "E5"), (3.5, "G5")], [(0, "D5"), (2, "B4"), (3, "D5")],
        [(0, "E5"), (1.5, "G5"), (2, "A5"), (3, "C6")], [(0, "A5"), (2, "G5"), (3, "E5")],
        [(0, "D5"), (1, "E5"), (2, "G5"), (3, "E5")], [(0, "D5"), (2, "C5")],
    ]
    for b in range(bars):
        start = int(SR * beat * 4 * b)
        # Pad: detuned soft saws, low-passed, slow swell.
        d = beat * 4
        n = int(SR * d)
        pad = np.zeros(n)
        for nm in chords[b]:
            for det in (0.997, 1.003):
                pad += signal.sawtooth(phase(np.full(n, note(nm) * det)))
        pad = lowpass(pad, 1200) * env(n, 0.6, 0.6, 1.5) * 0.05
        out[start:start + n] += pad
        # Bass: round triangle on beats 1 and 3.
        for bt in (0, 2):
            s = start + int(SR * beat * bt)
            x = tone(note(bass[b]), beat * 1.6, "tri", tau=0.5) * 0.25
            out[s:s + len(x)] += x
        # Melody: mallets.
        for bt, nm in melody[b]:
            s = start + int(SR * beat * bt)
            x = mallet(note(nm), 1.2, 0.35) * 0.3
            out[s:s + len(x)] += x
    # Wrap the tail into the start so the loop has no gap.
    tail = out[total:]
    out = out[:total]
    out[: len(tail)] += tail
    out = room(out, 0.25)
    write(f"{OUT}/music/meadow.mp3", out, 0.5)


if __name__ == "__main__":
    effects()
    names = animals()
    babble()
    music()
    print(f"effects, {len(names)} animal sounds, babble voice and music written to {OUT}/")
