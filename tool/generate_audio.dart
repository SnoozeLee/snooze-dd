// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

Uint8List createWav(List<double> samples, int sampleRate) {
  final numSamples = samples.length;
  final numChannels = 1;
  final bitsPerSample = 16;
  final byteRate = sampleRate * numChannels * (bitsPerSample ~/ 8);
  final blockAlign = numChannels * (bitsPerSample ~/ 8);
  final dataSize = numSamples * (bitsPerSample ~/ 8);
  final fileSize = 36 + dataSize;

  final buffer = ByteData(44 + dataSize);

  // RIFF header
  buffer.setUint8(0, 0x52); // 'R'
  buffer.setUint8(1, 0x49); // 'I'
  buffer.setUint8(2, 0x46); // 'F'
  buffer.setUint8(3, 0x46); // 'F'
  buffer.setUint32(4, fileSize, Endian.little);
  buffer.setUint8(8, 0x57); // 'W'
  buffer.setUint8(9, 0x41); // 'A'
  buffer.setUint8(10, 0x56); // 'V'
  buffer.setUint8(11, 0x45); // 'E'

  // fmt chunk
  buffer.setUint8(12, 0x66); // 'f'
  buffer.setUint8(13, 0x6D); // 'm'
  buffer.setUint8(14, 0x74); // 't'
  buffer.setUint8(15, 0x20); // ' '
  buffer.setUint32(16, 16, Endian.little); // chunk size
  buffer.setUint16(20, 1, Endian.little); // PCM format
  buffer.setUint16(22, numChannels, Endian.little);
  buffer.setUint32(24, sampleRate, Endian.little);
  buffer.setUint32(28, byteRate, Endian.little);
  buffer.setUint16(32, blockAlign, Endian.little);
  buffer.setUint16(34, bitsPerSample, Endian.little);

  // data chunk
  buffer.setUint8(36, 0x64); // 'd'
  buffer.setUint8(37, 0x61); // 'a'
  buffer.setUint8(38, 0x74); // 't'
  buffer.setUint8(39, 0x61); // 'a'
  buffer.setUint32(40, dataSize, Endian.little);

  int offset = 44;
  for (int i = 0; i < numSamples; i++) {
    final s = samples[i].clamp(-1.0, 1.0);
    final intSample = (s * 32767).round();
    buffer.setInt16(offset, intSample, Endian.little);
    offset += 2;
  }

  return buffer.buffer.asUint8List();
}

void main() {
  const sampleRate = 44100;

  // 1. Gentle Bell (风铃/磬声 - 1.2秒)
  {
    const duration = 1.2;
    final totalSamples = (sampleRate * duration).round();
    final samples = List<double>.generate(totalSamples, (i) {
      final t = i / sampleRate;
      final attack = (1 - exp(-t / 0.015)).clamp(0.0, 1.0);
      final env1 = exp(-3.2 * t);
      final env2 = exp(-4.8 * t);
      final env3 = exp(-6.5 * t);

      final f0 = 784.0; // G5
      final wave = 0.60 * sin(2 * pi * f0 * t) * env1 +
          0.30 * sin(2 * pi * f0 * 2.04 * t) * env2 +
          0.10 * sin(2 * pi * f0 * 3.01 * t) * env3;

      return wave * attack * 0.85;
    });

    File('assets/audio/gentle_bell.wav')
        .writeAsBytesSync(createWav(samples, sampleRate));
    print('Generated gentle_bell.wav');
  }

  // 2. Water Drop (清澈水滴 - 0.28秒)
  {
    const duration = 0.28;
    final totalSamples = (sampleRate * duration).round();
    final samples = List<double>.generate(totalSamples, (i) {
      final t = i / sampleRate;
      final attack = (1 - exp(-t / 0.005)).clamp(0.0, 1.0);
      final decay = exp(-18.0 * t);

      // 频率微变 (700 -> 1300 -> 900)
      final freq = 800.0 + 500.0 * sin(pi * t / duration);
      final wave = sin(2 * pi * freq * t) * decay;

      return wave * attack * 0.8;
    });

    File('assets/audio/water_drop.wav')
        .writeAsBytesSync(createWav(samples, sampleRate));
    print('Generated water_drop.wav');
  }

  // 3. Singing Bowl (静心颂钵 - 2.5秒)
  {
    const duration = 2.5;
    final totalSamples = (sampleRate * duration).round();
    final samples = List<double>.generate(totalSamples, (i) {
      final t = i / sampleRate;
      final attack = (1 - exp(-t / 0.05)).clamp(0.0, 1.0);
      final decay = exp(-1.2 * t);

      final f0 = 261.63; // C4
      final vibrato = 1.0 + 0.05 * sin(2 * pi * 4.0 * t);
      final wave = (0.65 * sin(2 * pi * f0 * t) +
              0.25 * sin(2 * pi * f0 * 2.01 * t) +
              0.10 * sin(2 * pi * f0 * 3.02 * t)) *
          vibrato *
          decay;

      return wave * attack * 0.85;
    });

    File('assets/audio/singing_bowl.wav')
        .writeAsBytesSync(createWav(samples, sampleRate));
    print('Generated singing_bowl.wav');
  }
}
