//
//  HomeScreen.swift
//  HomeScreen
//
//  Created by Alex Emry on 9/21/21.
//

import Foundation
import SwiftUI

struct HomeScreen: View {
	
	@Environment(\.colorScheme) var colorScheme
	@AppStorage("autoconnectUUID") var autoconnectUUID: String = ""
	@AppStorage("autoconnect") var autoconnect: Bool = false
	@ObservedObject var deviceInfo = BLEDeviceInfo.shared
	@ObservedObject var dfuUpdater = DFU_Updater.shared
	@ObservedObject var bleManager = BLEManager.shared
	@ObservedObject var downloadManager = DownloadManager.shared
	@ObservedObject var uptimeManager = UptimeManager.shared
	let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
	
	@State var currentUptime: TimeInterval!
	
	private var dateFormatter = DateComponentsFormatter()
	
	var body: some View {
		return VStack{
			Text("Infini-iOS")
				.font(.largeTitle)
				.padding()
				.frame(maxWidth: .infinity, alignment: .leading)
			List{
				Section(header: Text("Device Name")) {
					Text(deviceInfo.deviceName)
				}
				Section(header: Text("Device Information")) {
					if !bleManager.isConnectedToPinetime {
						Text("Firmware Version: ")
						Text("Model: ")
					} else {
						Text("Firmware Version: " + deviceInfo.firmware)
						Text("Model: " + deviceInfo.modelNumber)
					}
				}
				Section(header: Text("Uptime Stats")) {
					if UptimeManager.shared.lastDisconnect == nil {
						Text("Last disconnect: ")
					} else {
						Text("Last disconnect: " + uptimeManager.dateFormatter.string(from: uptimeManager.lastDisconnect))

					}
					if currentUptime == nil {
						Text("Uptime: ")
					} else {
						Text("Uptime: " + (dateFormatter.string(from: currentUptime) ?? ""))
					}
				}.onReceive(timer, perform: { _ in
					if uptimeManager.connectTime != nil {
						currentUptime = -uptimeManager.connectTime.timeIntervalSinceNow
					}
				})
				Section(header: Text("Firmware Updates")) {
					if downloadManager.updateAvailable && bleManager.isConnectedToPinetime {
						Button{
							let asset = downloadManager.chooseAsset(response: downloadManager.autoUpgrade)
							dfuUpdater.firmwareFilename = asset.name
							dfuUpdater.firmwareSelected = true
							dfuUpdater.local = false
							DownloadManager.shared.startDownload(url: asset.browser_download_url)
							PageSwitcher.shared.currentPage = .dfu
						} label: {
							Text("Firmware Update is Available!")
						}.disabled(!bleManager.isConnectedToPinetime)
					} else {
						Text("No Updates Available")
					}
				}
			}
			.listStyle(.insetGrouped)
			
			// leaving this section here in case of negative feedback on removing the button.
			
//			Spacer()
//			Button(action: {
//				// if pinetime is connected, button says disconnect, and disconnects on press
//				if bleManager.isConnectedToPinetime {
//					self.bleManager.disconnect()
//				} else {
//					// show connect sheet if pinetime is not connected and autoconnect is disabled,
//					// OR if pinetime is not connected and autoconnect is enabled, BUT there's no UUID saved for autoconnect
//					if !autoconnect || (autoconnect && autoconnectUUID.isEmpty) {
//						SheetManager.shared.showSheet = true
//					} else {
//						// if autoconnect is on and no pinetime is connected, start the scan which will autoconnect if that PT advertises
//						bleManager.startScanning()
//					}
//				}
//			}) {
//				Text(bleManager.isConnectedToPinetime ? "Disconnect from PineTime" : (bleManager.isScanning ? "Scanning" : "Connect to PineTime"))
//					.padding()
//					.padding(.vertical, 7)
//					.frame(maxWidth: .infinity, alignment: .center)
//					.background(colorScheme == .dark ? Color.darkGray : Color.blue)
//					.foregroundColor(Color.white)
//					.cornerRadius(10)
//					.padding(.horizontal, 20)
//					.padding(.bottom)
//			}.disabled(bleManager.isScanning && autoconnect) // this button should be disabled and read "Scanning" if autoconnect is enabled and a scan is started. Any other condition when not connected should show the sheet and cover the button
		}
	}
}


