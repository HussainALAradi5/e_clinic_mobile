"""Synthesises the e-Clinic notification sounds: one short, soft bell pattern per kind of message, so people can
tell a visit reminder from a result or a chat without looking. Original sounds (sine partials with a bell-like
decay), 44.1 kHz mono 16-bit WAV.

Usage (from the repository root):
  python tools/make_notification_sounds.py apps/clinic/android/app/src/main/res/raw ../e_clinic_client/public/sounds
Android gets notify_<kind>.wav (resource names use underscores), the web client notify-<kind>.wav.
"""
import math
import os
import struct
import sys
import wave

RATE = 44100
NOTE = {'C5': 523.25, 'D5': 587.33, 'E5': 659.25, 'F5': 698.46, 'G5': 783.99, 'A5': 880.0, 'B5': 987.77,
        'C6': 1046.5, 'E6': 1318.5}

# kind -> [(note, start seconds, length seconds, gain)]; each pattern is struck three times (see render).
PATTERNS = {
    'visit': [('E5', 0.0, 1.2, 0.55), ('A5', 0.22, 1.0, 0.5)],                      # up a fourth: "ding-dong"
    'treatment': [('C5', 0.0, 0.9, 0.45), ('E5', 0.16, 0.9, 0.45), ('G5', 0.32, 1.0, 0.45)],  # calm arpeggio
    'result': [('G5', 0.0, 1.0, 0.5), ('C6', 0.18, 1.1, 0.5)],                      # bright, rising
    'pharmacy': [('A5', 0.0, 1.0, 0.5), ('E5', 0.2, 1.1, 0.5)],                     # falling
    'billing': [('D5', 0.0, 0.5, 0.5), ('D5', 0.18, 0.9, 0.45)],                    # soft double tap
    'hr': [('F5', 0.0, 0.9, 0.5), ('A5', 0.2, 1.0, 0.45)],                          # warm third
    'chat': [('B5', 0.0, 0.45, 0.55)],                                              # one short pop
    'support': [('C6', 0.0, 0.9, 0.45), ('G5', 0.2, 1.0, 0.5)],                     # falling fifth
    'urgent': [('A5', 0.0, 0.3, 0.8), ('A5', 0.22, 0.3, 0.8), ('E6', 0.44, 0.6, 0.7)],  # three quick, insistent
    'files': [('G5', 0.0, 0.5, 0.5), ('C6', 0.14, 0.5, 0.45), ('E6', 0.28, 0.9, 0.4)],  # quick rising "done"
    'system': [('C5', 0.0, 1.0, 0.45)],                                             # one low, quiet bell
}


def bell(freq, start, length, gain, samples):
    partials = [(1.0, 1.0), (2.0, 0.5), (3.01, 0.25), (4.2, 0.12), (5.4, 0.06)]  # bright enough to cut through a room
    begin = int(start * RATE)
    for i in range(int(length * RATE)):
        t = i / RATE
        attack = min(1.0, t / 0.008)
        decay = math.exp(-t * 1.5)  # rings on, so it is heard over a busy room
        value = sum(a * math.sin(2 * math.pi * freq * m * t) * math.exp(-t * m * 0.6) for m, a in partials)
        j = begin + i
        if j < len(samples):
            samples[j] += value * attack * decay * gain


def render(pattern):
    # Struck three times (short gaps) so it is noticed; chat stays a quick triple pop.
    span = max(start + min(length, 0.6) for _, start, length, _ in pattern) + 0.2
    pattern = [(note, start + span * k, length, gain) for k in range(3) for note, start, length, gain in pattern]
    total = max(start + length for _, start, length, _ in pattern)
    samples = [0.0] * int(total * RATE)
    for note, start, length, gain in pattern:
        bell(NOTE[note], start, length, gain, samples)
    # Loud enough to notice: normalise, then a gentle soft clip (tanh) raises the body of the sound without harsh
    # distortion; every kind ends up near full scale (the patterns differ in rhythm and pitch, not in volume).
    peak = max(abs(s) for s in samples) or 1.0
    shaped = [math.tanh(4.5 * s / peak) for s in samples]
    top = max(abs(s) for s in shaped) or 1.0
    return b''.join(struct.pack('<h', int(s / top * 0.97 * 32767)) for s in shaped)


def main(android_dir, web_dir):
    os.makedirs(android_dir, exist_ok=True)
    os.makedirs(web_dir, exist_ok=True)
    for kind, pattern in PATTERNS.items():
        frames = render(pattern)
        for path in (os.path.join(android_dir, f'notify_{kind}.wav'), os.path.join(web_dir, f'notify-{kind}.wav')):
            with wave.open(path, 'wb') as w:
                w.setnchannels(1)
                w.setsampwidth(2)
                w.setframerate(RATE)
                w.writeframes(frames)
    print(f'{len(PATTERNS)} sounds written')


if __name__ == '__main__':
    main(sys.argv[1], sys.argv[2])
