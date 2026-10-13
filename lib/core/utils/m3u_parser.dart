import 'dart:convert';

import '../models/channel.dart';

List<Channel> parseM3U(String content) {
  final normalizedContent = content.trim();
  if (normalizedContent.isEmpty) {
    return const <Channel>[];
  }

  final lines = const LineSplitter().convert(normalizedContent);
  final channels = <Channel>[];
  String? pendingName;
  String? pendingLogo;
  String? pendingGroup;

  for (final rawLine in lines) {
    final line = rawLine.trim();
    if (line.isEmpty) {
      continue;
    }

    if (line.startsWith('#EXTINF')) {
      final metadata = _extractMetadata(line);
      pendingName = metadata['name'] ??
          metadata['tvg-name'] ??
          metadata['title'] ??
          'Canal sem nome';
      pendingLogo = metadata['logo'] ?? metadata['tvg-logo'] ?? '';
      pendingGroup = metadata['group'] ??
          metadata['group-title'] ??
          'Sem grupo';
      continue;
    }

    if (line.startsWith('#')) {
      continue;
    }

    if (!_isValidStreamUrl(line)) {
      pendingName = null;
      pendingLogo = null;
      pendingGroup = null;
      continue;
    }

    channels.add(
      Channel(
        name: pendingName ?? _fallbackNameFromUrl(line),
        logo: pendingLogo ?? '',
        group: pendingGroup ?? 'Sem grupo',
        url: line,
      ),
    );

    pendingName = null;
    pendingLogo = null;
    pendingGroup = null;
  }

  return channels;
}

Map<String, String> _extractMetadata(String line) {
  final metadata = <String, String>{};
  final attributeRegex = RegExp(
    "([A-Za-z0-9_-]+)\\s*=\\s*(?:\"([^\"]*)\"|'([^']*)'|([^,\\s]+))",
    caseSensitive: false,
  );

  for (final match in attributeRegex.allMatches(line)) {
    final key = match.group(1)?.toLowerCase();
    final value = match.group(2) ?? match.group(3) ?? match.group(4) ?? '';

    if (key != null && value.isNotEmpty) {
      metadata[key] = value.trim();
    }
  }

  final labelMatch = RegExp(r',\s*(.*)$').firstMatch(line);
  final label = labelMatch?.group(1)?.trim();
  if (label != null && label.isNotEmpty) {
    metadata['name'] = label;
  }

  if (metadata.containsKey('tvg-name') && metadata['tvg-name']!.isNotEmpty) {
    metadata['name'] = metadata['tvg-name']!;
  }

  if (metadata.containsKey('group-title') && metadata['group-title']!.isNotEmpty) {
    metadata['group'] = metadata['group-title']!;
  }

  if (metadata.containsKey('tvg-logo') && metadata['tvg-logo']!.isNotEmpty) {
    metadata['logo'] = metadata['tvg-logo']!;
  }

  return metadata;
}

bool _isValidStreamUrl(String value) {
  final uri = Uri.tryParse(value);
  if (uri == null || uri.hasScheme == false || uri.host.isEmpty) {
    return false;
  }

  final scheme = uri.scheme.toLowerCase();
  return switch (scheme) {
    'http' || 'https' || 'rtsp' || 'rtmp' || 'udp' || 'mms' => true,
    _ => false,
  };
}

String _fallbackNameFromUrl(String value) {
  final uri = Uri.tryParse(value);
  if (uri == null || uri.host.isEmpty) {
    return 'Canal sem nome';
  }

  return uri.host.replaceAll(RegExp(r'\.|-'), ' ').trim();
}
