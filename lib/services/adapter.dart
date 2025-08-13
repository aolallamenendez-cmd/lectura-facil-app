import 'dart:math';

class AdaptationResult {
  final String original;
  final String adapted;
  AdaptationResult({required this.original, required this.adapted});
}

class TextAdapter {
  final Map<String, String> _subs = const {
    'asimismo': 'también',
    'no obstante': 'pero',
    'consecuentemente': 'por eso',
    'implementación': 'puesta en marcha',
  };

  AdaptationResult adapt(String input, {bool advanced = false}) {
    String txt = input;
    txt = _cleanup(txt);
    final sentences = _splitSentences(txt);
    final adaptedSentences = <String>[];
    for (var s in sentences) {
      var w = s.trim();
      if (w.isEmpty) continue;
      w = _banSemicolon(w);
      w = _numbersPolicy(w);
      w = _lexicalSimplify(w);
      w = _preferActiveVoiceHeuristic(w);
      w = _limitSentenceLength(w);
      adaptedSentences.add(w);
    }
    final adapted = _reblock(adaptedSentences);
    return AdaptationResult(original: input, adapted: adapted);
  }

  String _cleanup(String t) {
    return t.replaceAll(RegExp(r'[\t ]+'), ' ').replaceAll('\r', '');
  }

  List<String> _splitSentences(String t) {
    final re = RegExp(r'(?<=[.!?])\s+');
    return t.split(re);
  }

  String _banSemicolon(String s) {
    if (!s.contains(';')) return s;
    final parts = s.split(';').map((p) => p.trim()).where((p) => p.isNotEmpty).toList();
    return parts.map((p) => _capitalize(p)).join('. ');
  }

  String _numbersPolicy(String s) {
    s = s.replaceAll(RegExp(r'\b1\.?º\b|\b1\.?o\b', caseSensitive: false), 'primero');
    s = s.replaceAll(RegExp(r'\b2\.?º\b|\b2\.?o\b', caseSensitive: false), 'segundo');
    s = s.replaceAllMapped(RegExp(r'(\d{1,3})(?:[\.,](\d{1,2}))?\s*%'), (m) {
      final v = int.tryParse(m.group(1) ?? '0') ?? 0;
      if (v >= 90) return 'casi todas las personas';
      if (v >= 60) return 'muchas personas';
      if (v >= 30) return 'algunas personas';
      return 'pocas personas';
    });
    s = s.replaceAllMapped(RegExp(r'\b(\d{1,2})[\-/](\d{1,2})[\-/](\d{2,4})\b'), (m) {
      final d = int.parse(m.group(1)!);
      final mo = int.parse(m.group(2)!);
      final y = int.parse(m.group(3)!);
      const months = ['enero','febrero','marzo','abril','mayo','junio','julio','agosto','septiembre','octubre','noviembre','diciembre'];
      final mname = (mo>=1 && mo<=12) ? months[mo-1] : 'mes';
      return '$d de $mname de $y';
    });
    s = s.replaceAllMapped(RegExp(r'\b(\d{1,2}):(\d{2})\b'), (m) {
      final hh = int.tryParse(m.group(1)!) ?? 0;
      final mm = m.group(2)!;
      String momento = 'de la tarde';
      if (hh < 12) momento = 'de la mañana';
      if (hh >= 20) momento = 'de la noche';
      final h12 = ((hh + 11) % 12) + 1;
      return 'a las $h12:$mm $momento';
    });
    return s;
  }

  String _lexicalSimplify(String s) {
    var out = s;
    _subs.forEach((k, v) {
      out = out.replaceAll(RegExp('\\b' + RegExp.escape(k) + '\\b', caseSensitive: false), v);
    });
    out = out.replaceAllMapped(RegExp(r'\\b(\\w+?)mente\\b', caseSensitive: false), (m) {
      final root = m.group(1);
      return 'de forma ' + (root ?? '');
    });
    return out;
  }

  String _preferActiveVoiceHeuristic(String s) {
    final re = RegExp(r'([^\.\!\?]+?)\s+(?:fue|era|ha sido|había sido)\s+([a-záéíóúñ]+)\s+por\s+([^\.\!\?]+)', caseSensitive: false);
    return s.replaceAllMapped(re, (m) {
      final obj = m.group(1)!.trim();
      final verbo = m.group(2)!.trim();
      final sujeto = m.group(3)!.trim();
      return '$sujeto $verbo $obj';
    });
  }

  String _limitSentenceLength(String s, {int maxLen = 22}) {
    final words = s.split(RegExp(r'\s+'));
    if (words.length <= maxLen) return s;
    final splitIdx = words.indexWhere((w) => ['y','pero','o','porque','aunque','además'].contains(w.toLowerCase()));
    if (splitIdx > 0 && splitIdx < words.length-1) {
      final a = words.sublist(0, splitIdx).join(' ');
      final b = words.sublist(splitIdx+1).join(' ');
      return _limitSentenceLength(a, maxLen: maxLen) + '. ' + _capitalize(_limitSentenceLength(b, maxLen: maxLen));
    }
    final mid = (words.length/2).floor();
    final a = words.sublist(0, mid).join(' ');
    final b = words.sublist(mid).join(' ');
    return a + '. ' + _capitalize(b);
  }

  String _reblock(List<String> sentences) {
    final out = <String>[];
    int i = 0;
    while (i < sentences.length) {
      final end = i + 3;
      out.add(sentences.sublist(i, end > sentences.length ? sentences.length : end).join(' '));
      i = end;
    }
    return out.join('\n\n');
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}
