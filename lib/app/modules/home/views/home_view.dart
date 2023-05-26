import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth App'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                const Spacer(),
                const Text(
                  "Scan for a device",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Obx(
                  () => controller.isScanning.value
                      ? const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        )
                      : IconButton(
                          color: Colors.blue,
                          onPressed: () {
                            controller.scanDevices();
                          },
                          icon: const Icon(Icons.refresh),
                        ),
                ),
                const Spacer()
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              width: double.maxFinite - 20,
              height: Get.height * 0.15,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    const Text("Connected Device",
                        style: TextStyle(
                            fontSize: 17,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                    Obx(
                      () => controller.isAlreadyConnected.value == false
                          ? const Center(
                              child: Text("No device connected",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                            )
                          : Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(controller.connectedDevice?.name ??
                                      "No device connected"),
                                  const Spacer(),
                                  IconButton(
                                      onPressed: () {
                                        controller.disconnectDevice();
                                      },
                                      icon: const Icon(Icons.link_off_rounded)),
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              width: double.maxFinite - 20,
              height: Get.height * 0.5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Obx(
                () => controller.devices.isEmpty
                    ? const Center(
                        child: Text("No devices found"),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: const Icon(Icons.bluetooth),
                            title: Text(controller.devices[index].name),
                            subtitle: Text(controller.devices[index].id.id),
                            trailing: IconButton(
                                onPressed: () {
                                  controller.connectToDevice(
                                      controller.devices[index]);
                                },
                                icon: const Icon(Icons.link_rounded,
                                    color: Colors.blue)),
                          );
                        },
                        separatorBuilder: (context, index) {
                          return const Divider();
                        },
                        itemCount: controller.devices.length),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            // ElevatedButton(      For Serial Connection , not implemented yet
            //     onPressed: () {
            //       controller.scanForClassicDevices();
            //     },
            //     child: Text("Serial Connect"))
          ],
        ),
      ),
    );
  }
}
