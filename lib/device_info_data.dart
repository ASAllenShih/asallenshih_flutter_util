class DeviceInfoData {
  const DeviceInfoData({
    this.systemVersion,
    this.deviceName,
    this.cpuArchitecture,
    this.cpuCore,
    this.cpuFrequency,
    this.memory,
    this.memoryLeft,
    this.storage,
    this.storageLeft,
    this.supportedAbis,
  });
  final String? systemVersion;
  final String? deviceName;
  final String? cpuArchitecture;
  final double? cpuFrequency;
  final int? cpuCore;
  final int? memory;
  final int? memoryLeft;
  final int? storage;
  final int? storageLeft;
  final List<String>? supportedAbis;
}