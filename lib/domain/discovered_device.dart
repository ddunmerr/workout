class DiscoveredDevice {
  final String ipAddress;
  final String name;

  DiscoveredDevice({required this.ipAddress, required this.name});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiscoveredDevice &&
          runtimeType == other.runtimeType &&
          ipAddress == other.ipAddress;

  @override
  int get hashCode => ipAddress.hashCode;
}
