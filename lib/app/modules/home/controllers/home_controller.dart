import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart' as bt;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  RxBool isAlreadyConnected = false.obs;
  RxBool isScanning = false.obs;
  RxList<BluetoothDevice> devices = <BluetoothDevice>[].obs;
  BluetoothDevice? connectedDevice;
  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  @override
  onInit() {
    super.onInit();
    connectedDevices();
  }

  connectedDevices() async {
    flutterBlue.connectedDevices.asStream().listen((event) {
      if (kDebugMode) {
        print(event.length);
      }
      for (BluetoothDevice device in event) {
        device.name.isNotEmpty && !devices.contains(device)
            ? {
                connectedDevice = device,
                isAlreadyConnected.value = true,
              }
            : null;
      }
    });
  }

  disconnectDevice() async {
    if (connectedDevice != null) {
      await connectedDevice!.disconnect();
      isAlreadyConnected.value = false;
      devices.add(connectedDevice!);
      connectedDevice = null;

      EasyLoading.showSuccess("Disconnected");
    } else {
      EasyLoading.showInfo("No device connected");
    }
  }

  scanDevices() async {
    isScanning.value = true;
    devices.clear();
    await configureBluetooth().then((value) async {
      if (value) {
        await flutterBlue.startScan(timeout: const Duration(seconds: 5));

        flutterBlue.scanResults.listen((event) {
          for (ScanResult result in event) {
            result.device.name.isNotEmpty && !devices.contains(result.device)
                ? devices.add(result.device)
                : null;
          }
        });

        flutterBlue.stopScan();
        isScanning.value = false;
      } else {
        isScanning.value = false;
      }
    });
  }

  connectToDevice(BluetoothDevice device) async {
    EasyLoading.show(
        status: "Connecting to ${device.name}",
        maskType: EasyLoadingMaskType.black);
    await device.connect();
    connectedDevice = device;
    isAlreadyConnected.value = true;
    devices.removeWhere((element) => element == device);
    EasyLoading.showSuccess("Connected to ${device.name}");
  }

  Future<bool> configureBluetooth() async {
    bool isConfigured = false;
    await flutterBlue.isAvailable.then((value) {
      if (kDebugMode) {
        print("Bluetooth is available $value");
      }
      if (!value) {
        EasyLoading.showError("Bluetooth is not available");
      }
    });

    await flutterBlue.isOn.then((value) async {
      if (kDebugMode) {
        print("Bluetooth is on $value");
      }
      isConfigured = value;
      if (!value) {
        EasyLoading.showInfo("Please turn on bluetooth",
            duration: const Duration(seconds: 2));
        await Future.delayed(
            const Duration(seconds: 3),
            () => Get.defaultDialog(
                  title: "Bluetooth",
                  content: const Text("Want to turn on bluetooth ?"),
                  actions: [
                    TextButton(
                      onPressed: () async {
                        await flutterBlue.turnOn();
                        isConfigured = true;
                        Get.back();
                      },
                      child: const Text("Yes"),
                    ),
                    TextButton(
                        onPressed: () {
                          Get.back();
                        },
                        child: const Text("No"))
                  ],
                ));
      }
    });
    return isConfigured;
  }

  // scanForClassicDevices() async {                Still need to work on it
  //   try {
  //     bt.BluetoothConnection connection =
  //         await bt.BluetoothConnection.toAddress(
  //             "50:76:AF:1D:E3:32"); // your device mac address
  //     print("Connected to the device");

  //     // connection.input?.listen((Uint8List data) {
  //     //   print("Data incoming: ${ascii.decode(data)}");
  //     //   connection.output.add(data); // Sending data
  //     // }).onDone(() {
  //     //   EasyLoading.showProgress(0.5, status: "Disconnected by remote request");
  //     //   print("Disconnected by remote request");
  //     // });
  //   } catch (e) {
  //     Get.defaultDialog(
  //         title: "Error",
  //         content: Container(
  //             width: Get.width * 0.8,
  //             height: 400,
  //             child: SingleChildScrollView(child: Text(e.toString()))));
  //     print(e);
  //   }
  // }
}
