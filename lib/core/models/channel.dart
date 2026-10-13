class Channel {
  const Channel({
    required this.name,
    required this.logo,
    required this.group,
    required this.url,
  });

  final String name;
  final String logo;
  final String group;
  final String url;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is Channel &&
        other.name == name &&
        other.logo == logo &&
        other.group == group &&
        other.url == url;
  }

  @override
  int get hashCode => Object.hash(name, logo, group, url);
}
