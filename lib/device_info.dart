import 'package:asallenshih_flutter_util/device.dart';
import 'package:asallenshih_flutter_util/log.dart';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceInfo {
  static DeviceInfoData? _data;
  static Future<void> init() async {
    if (_data == null) {
      await getData();
    }
  }

  static DeviceInfoData get data => _data ?? DeviceInfoData();

  static Future<DeviceInfoData> getData() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    try {
      if (Device.isWeb) {
        final webBrowserInfo = await deviceInfoPlugin.webBrowserInfo;
        _data = DeviceInfoData(
          systemVersion: webBrowserInfo.userAgent,
          deviceName: webBrowserInfo.browserName.name,
          cpuCore: webBrowserInfo.hardwareConcurrency,
          memory: webBrowserInfo.deviceMemory != null
              ? (webBrowserInfo.deviceMemory! * 1024).truncate()
              : null,
        );
      } else if (Device.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        _data = DeviceInfoData(
          systemVersion: androidInfo.version.release,
          deviceName: androidInfo.model,
          memory: androidInfo.physicalRamSize,
          memoryLeft: androidInfo.availableRamSize,
          storage: androidInfo.totalDiskSize,
          storageLeft: androidInfo.freeDiskSize,
        );
      } else if (Device.isIOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        _data = DeviceInfoData(
          systemVersion: iosInfo.systemVersion,
          deviceName: iosInfo.modelName,
          memory: iosInfo.physicalRamSize,
          memoryLeft: iosInfo.availableRamSize,
          storage: iosInfo.totalDiskSize,
          storageLeft: iosInfo.freeDiskSize,
        );
      } else if (Device.isWindows) {
        final windowsInfo = await deviceInfoPlugin.windowsInfo;
        _data = DeviceInfoData(
          systemVersion:
              '${windowsInfo.majorVersion}.${windowsInfo.minorVersion}.${windowsInfo.buildNumber}',
          deviceName: windowsInfo.computerName,
          cpuCore: windowsInfo.numberOfCores,
          memory: windowsInfo.systemMemoryInMegabytes,
        );
      } else if (Device.isMacOS) {
        final macOsInfo = await deviceInfoPlugin.macOsInfo;
        _data = DeviceInfoData(
          systemVersion:
              '${macOsInfo.majorVersion}.${macOsInfo.minorVersion}.${macOsInfo.patchVersion}',
          deviceName: macOsInfo.modelName,
          cpuCore: macOsInfo.activeCPUs,
          memory: macOsInfo.memorySize,
          cpuArchitecture: macOsInfo.arch,
          cpuFrequency: macOsInfo.cpuFrequency / 1000,
        );
      } else if (Device.isLinux) {
        final linuxInfo = await deviceInfoPlugin.linuxInfo;
        _data = DeviceInfoData(
          systemVersion: linuxInfo.version,
          deviceName: linuxInfo.prettyName,
        );
      }
    } catch (e) {
      log.e('Error while fetching device info', error: e);
    }
    return _data!;
  }
}

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
