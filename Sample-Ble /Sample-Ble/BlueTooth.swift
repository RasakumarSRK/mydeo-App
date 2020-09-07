

import Foundation
import CoreBluetooth
import CoreLocation
import HealthKit
import SwiftUI

protocol bluetoothDelegate{
    func getNearbyBluetoothDevicelist(_ peripheral:CBPeripheral)
    func peripheralConnected(_ peripheral:CBPeripheral)
    func bluetoothResponse(value1:Double,value2:Double,value3:Double)
    func afterCompletion()
}
extension bluetoothDelegate{
    func peripheralConnected(_ peripheral:CBPeripheral){
        
    }
}
protocol delegateBluetoothAlert{
    func callBlutoothErrorMessage(error:String)
}

class BlueTooth : NSObject, CBCentralManagerDelegate,CBPeripheralDelegate{
    
    var  delegate:bluetoothDelegate?
    var  delegateAlert:delegateBluetoothAlert?
    
    fileprivate var centralManager: CBCentralManager?
    fileprivate var discoveredPeripheral: CBPeripheral?
    
    var stringDeviceValiDation = NSString()
    //Blood Pressure
    var boolUpdateBPData:Bool = false
    let E1:[UInt8] = [0xFD,0xFD,0xFD,0x01,0x0D,0x0A]
    var dataE1 =  NSData()
    
    let EE:[UInt8] = [0xFD,0xFD,0xFD,0x0E,0x0D,0x0A]
    var dataEE = NSData()
    
    let E2:[UInt8] = [0xFD,0xFD,0xFE,0x02,0x0D,0x0A]
    var dataE2 = NSData()
    
    let E3:[UInt8] = [0xFD,0xFD,0xFE,0x03,0x0D,0x0A]
    var dataE3 = NSData()
    
    let E5:[UInt8] = [0xFD,0xFD,0xFE,0x05,0x0D,0x0A]
    var dataE5 = NSData()
    
    let EC:[UInt8] = [0xFD,0xFD,0xFE,0x0C,0x0D,0x0A]
    var dataEC = NSData()
    
    let EB:[UInt8] = [0xFD,0xFD,0xFD,0x0B,0x0D,0x0A]
    var dataEB = NSData()
    var StoreValue = NSString()
    var isSaved = false
    let ReadYText = "Required data has been retrieved. Please Enter reading and click send DB"

    
    //  pulse Oximeter
    let pulseOximeterServiceUUID = CBUUID(string: "CDEACB80-5235-4C07-8846-93A37EE6B86D")
    let pulseOximeterCharacteristicUUID = CBUUID(string:"CDEACB81-5235-4C07-8846-93A37EE6B86D")
    let pulseOximeterWriteCharacteristicUUID = CBUUID(string:"CDEACB82-5235-4C07-8846-93A37EE6B86D")
    let thermometerServiceUUID = CBUUID(string:"CDEACB80-5235-4C07-8846-93A37EE6B86D")
    let thermeterCharacteristicUUID = CBUUID(string:"CDEACB81-5235-4C07-8846-93A37EE6B86D")
    let glucometerServiceUUID = CBUUID(string: "FFF0")
    let glucometerCharacteristicUUID = CBUUID(string: "FFF4")
    let scaleServiceUUId = CBUUID(string: "FFF0")
    let scaleReadCharacteristicUUId = CBUUID(string: "FFF4")
    let scaleWriteCharacteristicUUId = CBUUID(string: "FFF1")
    let bloodPressureServiceUUId = CBUUID(string: "FFF0")
    var serviceUUID = "FFF0"
    let bleGlucometerServiceUUID = CBUUID(string: "FEE7")
    let bleGlucometerCharacteristicUUID = CBUUID(string: "FFF4")
    
    //gmate
    let GmateServiceUUID = CBUUID(string:"3E00C4FA-039C-4DE9-BA98-58C4332F7DB4")
    let GmateReadCharacteristicUUID = CBUUID(string:"5F171307-566F-4F5E-AF44-A363B9EA6F4E")
    let GmateWriteCharacteristicUUID = CBUUID(string:"C823AE96-2B2F-4599-8818-0408D3B4B2D9")
    
    /*
     let voyageServiceUUID = "0001"
     let voyageCharacteristicUUID1 = "0002"
     let voyageCharacteristicUUID2 = "0003"
     */
    var doublePI = Double()
    var doubleSpo2 = Double()
    var doublePulse = Double()
    var stringWeight = NSString()
    var doubleValue:Double!
    var peripheralname = String()
    var peripheralID = String()
    var deviceName = String()
    var device:DeviceNames?
    
    //#MARK:- Methods
    func callBluetoothDeviceScan(stringDevice:String,serviceUUID:String) {
        StoreValue = "Yes"
        self.serviceUUID = serviceUUID
        centralManager = CBCentralManager(delegate: self, queue: nil)
        stringDeviceValiDation = stringDevice as NSString
        if stringDeviceValiDation ==  (HealthDevice.BloodPressure.rawValue) as NSString {
            dataE1 = NSData(bytes:E1, length: E1.count * MemoryLayout<UInt8>.size)
            dataEE = NSData(bytes: EE, length: EE.count * MemoryLayout<UInt8>.size)
            dataE2 = NSData(bytes: E2, length: E2.count * MemoryLayout<UInt8>.size)
            dataE3 = NSData(bytes: E3, length: E3.count * MemoryLayout<UInt8>.size)
            dataE5 = NSData(bytes: E5, length: E5.count * MemoryLayout<UInt8>.size)
            dataEC = NSData(bytes: EC, length: EC.count * MemoryLayout<UInt8>.size)
            dataEB = NSData(bytes: EB, length: EB.count * MemoryLayout<UInt8>.size)
        }
    }
    
    // To display list of scanned bluetooth devices
    func scanBluetoothDevice(){
        
        BluetoothDevice.insertBluetoothDeviceInTable(periperal: nil, CharacteristicsID: "NULL", Datas: "In scanBluetoothDevice", Description: "scan Bluetooth Device")
        // To display list of scanned bluetooth devices - Delegate Method
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        //Data Events for Blood Pressure Error Handling
        dataE1 = NSData(bytes:E1, length: E1.count * MemoryLayout<UInt8>.size)
        dataEE = NSData(bytes: EE, length: EE.count * MemoryLayout<UInt8>.size)
        dataE2 = NSData(bytes: E2, length: E2.count * MemoryLayout<UInt8>.size)
        dataE3 = NSData(bytes: E3, length: E3.count * MemoryLayout<UInt8>.size)
        dataE5 = NSData(bytes: E5, length: E5.count * MemoryLayout<UInt8>.size)
        dataEC = NSData(bytes: EC, length: EC.count * MemoryLayout<UInt8>.size)
        dataEB = NSData(bytes: EB, length: EB.count * MemoryLayout<UInt8>.size)
        
    }
    // Method to check if Bluetooth is on in device
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        BluetoothDevice.insertBluetoothDeviceInTable(periperal: nil, CharacteristicsID: "NULL", Datas: "In centralManagerDidUpdateState", Description: "central Manager Did UpdateState \(String(describing: central.self))")
        guard central.state  == .poweredOn else {
            BluetoothDevice.insertBluetoothDeviceInTable(periperal: nil, CharacteristicsID: "NULL", Datas: "In centralManagerDidUpdateState", Description: "Bluetooth is not on.")
            print("Bluetooth is not on.")
            return
        }
        centralManager?.scanForPeripherals(withServices:nil)
    }
    
    // call back method for displaying the list of nearby devices
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        peripheralname = peripheral.name ?? ""
        peripheralID =  peripheral.identifier.uuidString
         delegate?.getNearbyBluetoothDevicelist(peripheral)
     }
    //Method to Select a Bluetooth device from the near by list to Connect
    func connect(_ peripheral:CBPeripheral){
        discoveredPeripheral = peripheral
        discoveredPeripheral?.delegate = self
        // And connect
        centralManager?.connect(peripheral)
        centralManager?.stopScan()
    }
    /** If the connection fails for whatever reason, we need to deal with it.*/
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "BleRefresh"), object: "Fail to connect")
        BluetoothDevice.insertBluetoothDeviceInTable(periperal: nil, CharacteristicsID: "NULL", Datas: "In didFailToConnect peripheral", Description: "peripheral didFailToConnect  and error -->> \(String(describing: error))")
        print("Error----------->",error!)
    }
    /** We've connected to the peripheral, now we need to discover the services and characteristics to find the 'transfer' characteristic.*/
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        discoveredPeripheral = peripheral
        print("Connected!")
        delegate?.peripheralConnected(peripheral)
        peripheralname = peripheral.name ?? ""
        peripheralID =  peripheral.identifier.uuidString
        print("peripheralname----->",peripheralname)
        BluetoothDevice.insertBluetoothDeviceInTable(periperal: nil, CharacteristicsID: "NULL", Datas: "In didConnect peripheral", Description: "peripheral devcice connected")

        discoveredPeripheral?.delegate = self
        discoveredPeripheral?.discoverServices(nil)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "BleRefresh"), object: "ShowLogsOptions")
    }
 
    //Here read characterics from device
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard error == nil else {  return  }
        
        guard let services = peripheral.services else {  return   }
        // Loop through the newly filled peripheral.services array, just in case there's more than one.
        BluetoothDevice.insertBluetoothDeviceInTable(periperal: nil, CharacteristicsID: "NULL", Datas: "In didDiscoverServices with below services", Description: "\(services.description )")
        NotificationCenter.default.post(name: Notification.Name(rawValue: "BleRefresh"), object: "Discovered Services")
        NotificationCenter.default.post(name: Notification.Name(rawValue: "BleRefresh"), object: "log services:----->>>> \(services.description)")

        for service in services {
            /*if service.uuid.uuidString == "180A"{ //"Device Information"{
             peripheral.discoverCharacteristics(nil, for: service)
             }*/
            peripheral.discoverCharacteristics(nil, for: service)
        }
        showsendDB()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "BleRefresh"), object: "log Characteristics didDiscoverDescriptorsFor:----->>>> \(characteristic.descriptors)")
    }
    func peripheral(_ peripheral: CBPeripheral, didDiscoverIncludedServicesFor service: CBService, error: Error?) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "BleRefresh"), object: "log Characteristics didDiscoverIncludedServicesFor :----->>>> ")
    }
 
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        
        // Deal with errors (if any)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "BleRefresh"), object: "log Characteristics:----->>>> \(service.characteristics?.description)")
        NotificationCenter.default.post(name: Notification.Name(rawValue: "BleRefresh"), object: "Discovered Characteristics")
        BluetoothDevice.insertBluetoothDeviceInTable(periperal: nil, CharacteristicsID: "NULL", Datas: "In didDiscoverCharacteristicsFor with below Characteristics and error = \(error.debugDescription)", Description: "\(service.characteristics)")

        guard error == nil else {
            BluetoothDevice.insertBluetoothDeviceInTable(periperal: peripheral, CharacteristicsID: "NULL", Datas: "In didDiscoverCharacteristicsFor", Description: "error debugDescription \(error.debugDescription)")
            BluetoothDevice.insertBluetoothDeviceInTable(periperal: peripheral, CharacteristicsID: "NULL", Datas: "In didDiscoverCharacteristicsFor", Description: "error localizedDescription \(error?.localizedDescription ?? "")")
            print("errorss--------->",error ?? "")
            return
        }
        guard let characteristics = service.characteristics else {
            BluetoothDevice.insertBluetoothDeviceInTable(periperal: peripheral, CharacteristicsID: "NULL", Datas: "In didDiscoverCharacteristicsFor", Description: "service characteristics is empty")
            return
        }

        if let deviceType = device?.context {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "BleRefresh"), object: "logg --->> its old device -->> \(deviceType)")
            BluetoothDevice.insertBluetoothDeviceInTable(periperal: nil, CharacteristicsID: "NULL", Datas: " deviceType is \(deviceType)", Description:" Device name is = \(deviceName) ")

            if deviceType == .BloodPressure {
                //Service UUID not used because devices listed and initiated conncection in nearby list itself
                if service.uuid.isEqual(CBUUID(string: "FFF0")) {
                    if deviceName != "Belter_BT"{
                        for characteristic in characteristics {
                            // And check if it's the right one
                            //Notify characterstic
                            if characteristic.uuid.isEqual(CBUUID(string: "0xFFF1")) {
                                peripheral.setNotifyValue(true, for: characteristic)
                            }
                            //Write characterstic to trigger peripheral and read a value
                            if characteristic.uuid.isEqual(CBUUID(string: "FFF2")) {
                                centralManager?.stopScan()
                                boolUpdateBPData = true
                                let val: [UInt8] = [0xFD, 0xFD, 0xFA, 0x05, 0x0D, 0x0A]
                                let data = NSData(bytes: val, length: val.count * MemoryLayout<UInt8>.size)
                                discoveredPeripheral?.writeValue(data as Data, for: characteristic, type: .withResponse)
                            }
                        }
                    }else{
                        for characteristic in characteristics {
                            //Notify characterstic
                            if characteristic.uuid.isEqual(CBUUID(string: "FFF4")) {
                                peripheral.setNotifyValue(true, for: characteristic)
                            }
                            //Write characterstic to trigger peripheral and read a value
                            if characteristic.uuid.isEqual(CBUUID(string: "FFF3")) {
                                boolUpdateBPData = true
                                // discoveredPeripheral?.readValue(for: characteristic)  //v1
                                let val  = [0xFFF3]
                                let data = NSData(bytes: val, length: val.count)
                                peripheral.writeValue(data as Data, for: characteristic, type: CBCharacteristicWriteType.withResponse)
                                
                                //  let string = "FFF3"
                                // let data1 = string.data(using: .utf8)
                                //    peripheral.writeValue(data1!, for: characteristic, type: CBCharacteristicWriteType.withResponse)
                                
                            }
                        }
                    }
                }
            }else if deviceType ==  .PulseOximeter {
                
                if service.uuid.isEqual(pulseOximeterServiceUUID) {
                    for characteristic in characteristics {
                        
                        //Notify characterstic
                        if (characteristic.uuid.isEqual(pulseOximeterCharacteristicUUID)) {
                            let val: [UInt8] = [0x80,0x81,0x82]
                            let data = NSData(bytes: val, length: val.count * MemoryLayout<UInt8>.size)
                            discoveredPeripheral?.writeValue(data as Data, for: characteristic, type: .withResponse)
                        }
                        //Write characterstic to trigger peripheral and read a value
                        if characteristic.properties.contains(.notify){
                            discoveredPeripheral?.setNotifyValue(true, for: characteristic)
                        }
                    }
                }
                
            }else if deviceType ==  .Thermometer {
                if deviceName == "JPD-FR409BT" ||  deviceName == "JPD-FR400" {
                    if service.uuid.isEqual(CBUUID(string: "FFF0")) {
                        for characteristic in characteristics {
                            //Read characterstic
                            if characteristic.properties.contains(.read){
                                discoveredPeripheral?.readValue(for: characteristic)
                            }
                            //Notify characterstic
                            if service.uuid.isEqual(CBUUID(string: "FFF3")) {
                                discoveredPeripheral?.setNotifyValue(true, for: characteristic)
                            }
                            
                        }
                    }
                    
                }else if deviceName != "Belter_TP"{
                    if service.uuid.isEqual(thermometerServiceUUID){
                        for characteristic in characteristics {
                            //Read characterstic
                            if characteristic.properties.contains(.read){
                                discoveredPeripheral?.readValue(for: characteristic)
                            }
                            //Notify characterstic
                            if characteristic.properties.contains(.notify){
                                discoveredPeripheral?.setNotifyValue(true, for: characteristic)
                            }
                        }
                    }
                }else {
                    print("Service--->",service)
                    print("characteristics",characteristics)
                    if service.uuid.isEqual(CBUUID(string: "fff0")) {
                        for characteristic in characteristics {
                            print("characteristic values",characteristic)
                            
                            if characteristic.uuid.isEqual(CBUUID(string: "FFF4")) {
                                peripheral.setNotifyValue(true, for: characteristic)
                            }
                            
                            if characteristic.uuid.isEqual(CBUUID(string: "FFF3")) {
                                discoveredPeripheral?.readValue(for: characteristic)
                            }
                        }
                    }
                }
            }else if deviceType ==  .GlucoseMeter {
                if deviceName == "Samico GL" {
                    if service.uuid.isEqual(glucometerServiceUUID){
                        for characteristic in characteristics{
                             
                            if characteristic.uuid.isEqual(glucometerCharacteristicUUID){
                                peripheral.setNotifyValue(true, for: characteristic)
                                peripheral.readValue(for: characteristic)
                                
                            }
                        }
                    }
                }else if deviceName.contains("Gmate") {
                    if service.uuid.isEqual(GmateServiceUUID){
                        
                        for characteristic in characteristics{
                            /* if characteristic.uuid.isEqual(GmateWriteCharacteristicUUID){
                             let val  = [0x6A]
                             let data = NSData(bytes: val, length: val.count)
                             peripheral.writeValue(data as Data, for: characteristic, type: CBCharacteristicWriteType.withResponse)
                             }*/
                            
                            if characteristic.uuid.isEqual(GmateReadCharacteristicUUID){
                                peripheral.setNotifyValue(true, for: characteristic)
                                peripheral.readValue(for: characteristic)
                            }
                        }
                        
                    }
                }
                
                
                /* else if service.uuid.isEqual(bleGlucometerServiceUUID)
                 {
                 for characteristic in characteristics{
                 peripheral.setNotifyValue(true, for: characteristic)
                 peripheral.readValue(for: characteristic)
                 }
                 }*/
                /*  else if service.uuid.isEqual(voyageServiceUUID)
                 {
                 for characteristic in characteristics{
                 //Read and notify characterstic
                 if characteristic.uuid.isEqual(voyageCharacteristicUUID1){
                 peripheral.setNotifyValue(true, for: characteristic)
                 peripheral.readValue(for: characteristic)
                 }else if characteristic.uuid.isEqual(voyageCharacteristicUUID2){
                 peripheral.setNotifyValue(true, for: characteristic)
                 peripheral.readValue(for: characteristic)
                 }else{
                 
                 }
                 }
                 }*/
            }else if deviceType ==  .Scale {
                
                if deviceName == DeviceNames.HealthScale.rawValue ||  deviceName == DeviceNames.JPD_HealthScale.rawValue {
                    if service.uuid.isEqual(scaleServiceUUId){
                        for characteristic in characteristics{
                            
                            if characteristic.properties.contains(.notify){
                                print("---- notify ")
                                discoveredPeripheral?.readValue(for: characteristic)
                                discoveredPeripheral?.setNotifyValue(true, for: characteristic)
                            }
                        }
                    }
                } else if deviceName != "Body Fat-B2" {
                    if service.uuid.isEqual(scaleServiceUUId){
                        for characteristic in characteristics{
                            //Read and notify characterstic
                            if characteristic.properties.contains(.read){
                                discoveredPeripheral?.readValue(for: characteristic)
                                discoveredPeripheral?.setNotifyValue(true, for: characteristic)
                            }
                            
                            //Write characterstic to trigger peripheral and read a value
                            if characteristic.properties.contains(.write){
                                let val: [UInt8] = [0xFE,0x03,0x01,0x00,0xAA,0x19,0x01,0xB0]
                                let data = NSData(bytes: val, length: val.count)
                                peripheral.writeValue(data as Data, for: characteristic, type: CBCharacteristicWriteType.withResponse)
                            }
                        }
                    }
                }else {
                    if service.uuid.isEqual("faa0") || service.uuid.isEqual("FAA0"){
                        for characteristic in characteristics{
                            if characteristic.uuid.isEqual(CBUUID(string: "faa2")) || characteristic.uuid.isEqual(CBUUID(string: "FAA2")){
                                peripheral.setNotifyValue(true, for: characteristic)
                            }
                            if characteristic.uuid.isEqual(CBUUID(string: "faa1")) || characteristic.uuid.isEqual(CBUUID(string: "FAA1")){
                                discoveredPeripheral?.readValue(for: characteristic)
                                let val  = [0xFAA1]
                                let data = NSData(bytes: val, length: val.count)
                                peripheral.writeValue(data as Data, for: characteristic, type: CBCharacteristicWriteType.withResponse)
                            }
                        }
                    }
                }
            }else {
                for characteristic in characteristics{
                    if characteristic.properties.contains(.read){
                        discoveredPeripheral?.readValue(for: characteristic)
                    }
                    if characteristic.properties.contains(.notify){
                        discoveredPeripheral?.setNotifyValue(true, for: characteristic)
                    }
                }
            }
        }else{
            NotificationCenter.default.post(name: Notification.Name(rawValue: "BleRefresh"), object: "log --->> no deviceType so its new device")
            BluetoothDevice.insertBluetoothDeviceInTable(periperal: nil, CharacteristicsID: "NULL", Datas: "no deviceType so its new device", Description:" Device name is = \(deviceName) ")

            for characteristic in characteristics{
                discoveredPeripheral?.discoverDescriptors(for: characteristic)

                BluetoothDevice.insertBluetoothDeviceInTable(periperal: nil, CharacteristicsID: "NULL", Datas: "characteristics --> \(String(describing: service.characteristics?.description)) ", Description: "in looping for this characteristics \(characteristics.description)")
                if characteristic.properties.contains(.notify){
                    print("---- notify ")
                    BluetoothDevice.insertBluetoothDeviceInTable(periperal: nil, CharacteristicsID: "NULL", Datas: "characteristics --> \(String(describing: service.characteristics?.description)) ", Description: "have notify characteristics ")
                    discoveredPeripheral?.readValue(for: characteristic)
                    discoveredPeripheral?.setNotifyValue(true, for: characteristic)
                }
                if characteristic.properties.contains(.read){
                    print("---- read ")
                    BluetoothDevice.insertBluetoothDeviceInTable(periperal: nil, CharacteristicsID: "NULL", Datas: "characteristics --> \(String(describing: service.characteristics?.description)) ", Description: "have read characteristics ")
                    discoveredPeripheral?.readValue(for: characteristic)
                    discoveredPeripheral?.setNotifyValue(true, for: characteristic)
                }
            }
        }
        BluetoothDevice.insertBluetoothDeviceInTable(periperal: peripheral, CharacteristicsID: "NULL", Datas: "In didDiscoverCharacteristicsFor", Description: "characteristics count \(characteristics.count)")
        for characteristic in characteristics {
            trackData(peripheral, characteristic: characteristic, Datas: "IN didDiscoverCharacteristicsFor")
        }
    }
    
    func trackData(_ peripheral: CBPeripheral, characteristic:CBCharacteristic, Datas: String) {
        // And check if it's the right one
        //Notify characterstic
        BluetoothDevice.insertBluetoothDeviceInTable(periperal: peripheral, CharacteristicsID: characteristic.uuid.uuidString, Datas: Datas, Description: "characteristic description ---->>>   \(characteristic.description)")
        BluetoothDevice.insertBluetoothDeviceInTable(periperal: peripheral, CharacteristicsID: characteristic.uuid.uuidString, Datas: Datas, Description: "characteristic debugDescription ---->>>  \(characteristic.debugDescription)")
        BluetoothDevice.insertBluetoothDeviceInTable(periperal: peripheral, CharacteristicsID: characteristic.uuid.uuidString, Datas: Datas, Description: "characteristic descriptors ---->>>   \(String(describing: characteristic.descriptors.self))")
        BluetoothDevice.insertBluetoothDeviceInTable(periperal: peripheral, CharacteristicsID: characteristic.uuid.uuidString, Datas: Datas, Description: "characteristic isNotifying ---->>>  \(String(describing: characteristic.isNotifying.self))")
        BluetoothDevice.insertBluetoothDeviceInTable(periperal: peripheral, CharacteristicsID: characteristic.uuid.uuidString, Datas: Datas, Description: "characteristic properties notify ---->>>  \(characteristic.properties.contains(.notify))" )
        BluetoothDevice.insertBluetoothDeviceInTable(periperal: peripheral, CharacteristicsID: characteristic.uuid.uuidString, Datas: Datas, Description: "characteristic properties read ---->>>  \(characteristic.properties.contains(.read))" )
        BluetoothDevice.insertBluetoothDeviceInTable(periperal: peripheral, CharacteristicsID: characteristic.uuid.uuidString, Datas: Datas, Description: "characteristic properties write ---->>>  \(characteristic.properties.contains(.write))" )
        BluetoothDevice.insertBluetoothDeviceInTable(periperal: peripheral, CharacteristicsID: characteristic.uuid.uuidString, Datas: Datas, Description: "characteristic properties authenticatedSignedWrites ---->>>  \(characteristic.properties.contains(.authenticatedSignedWrites))" )
        BluetoothDevice.insertBluetoothDeviceInTable(periperal: peripheral, CharacteristicsID: characteristic.uuid.uuidString, Datas: Datas, Description: "characteristic properties broadcast ---->>>  \(characteristic.properties.contains(.broadcast))" )
        BluetoothDevice.insertBluetoothDeviceInTable(periperal: peripheral, CharacteristicsID: characteristic.uuid.uuidString, Datas: Datas, Description: "characteristic properties extendedProperties ---->>>  \(characteristic.properties.contains(.extendedProperties))" )
        BluetoothDevice.insertBluetoothDeviceInTable(periperal: peripheral, CharacteristicsID: characteristic.uuid.uuidString, Datas: Datas, Description: "characteristic properties indicate ---->>>  \(characteristic.properties.contains(.indicate))" )
        BluetoothDevice.insertBluetoothDeviceInTable(periperal: peripheral, CharacteristicsID: characteristic.uuid.uuidString, Datas: Datas, Description: "characteristic properties indicateEncryptionRequired ---->>>  \(characteristic.properties.contains(.indicateEncryptionRequired))" )
        BluetoothDevice.insertBluetoothDeviceInTable(periperal: peripheral, CharacteristicsID: characteristic.uuid.uuidString, Datas: Datas, Description: "characteristic properties notifyEncryptionRequired ---->>>  \(characteristic.properties.contains(.notifyEncryptionRequired))" )
        BluetoothDevice.insertBluetoothDeviceInTable(periperal: peripheral, CharacteristicsID: characteristic.uuid.uuidString, Datas: Datas, Description: "characteristic properties writeWithoutResponse ---->>>  \(characteristic.properties.contains(.writeWithoutResponse))" )
        BluetoothDevice.insertBluetoothDeviceInTable(periperal: peripheral, CharacteristicsID: characteristic.uuid.uuidString, Datas: Datas, Description: "characteristic service characteristics ---->>>  \(String(describing: characteristic.service.characteristics))" )
        BluetoothDevice.insertBluetoothDeviceInTable(periperal: peripheral, CharacteristicsID: characteristic.uuid.uuidString, Datas: Datas, Description: "characteristic service includedServices ---->>>  \(String(describing: characteristic.service.includedServices))" )
        BluetoothDevice.insertBluetoothDeviceInTable(periperal: peripheral, CharacteristicsID: characteristic.uuid.uuidString, Datas: Datas, Description: "characteristic service isPrimary ---->>>  \(String(describing: characteristic.service.isPrimary))" )
        BluetoothDevice.insertBluetoothDeviceInTable(periperal: peripheral, CharacteristicsID: characteristic.uuid.uuidString, Datas: Datas, Description: "characteristic service peripheral ---->>>  \(String(describing: characteristic.service.peripheral))" )
        BluetoothDevice.insertBluetoothDeviceInTable(periperal: peripheral, CharacteristicsID: characteristic.uuid.uuidString, Datas: Datas, Description: "characteristic Data ---->>>  \(String(describing: characteristic.value))" )
        if let data = characteristic.value{
            BluetoothDevice.insertBluetoothDeviceInTable(periperal: peripheral, CharacteristicsID: characteristic.uuid.uuidString, Datas: Datas, Description: "characteristic UTF8 String ---->>>  \(String(decoding: data, as: UTF8.self))" )
        }
    }
    
    func getCurrentDateTime() ->String {
        let nowDate:NSDate = NSDate()
        let df:DateFormatter = DateFormatter()
        df.dateFormat = GlobalReusability.DateFormats.LocalDBDateTimeFormat
        return df.string(from: nowDate as Date)
    }
    
    
    @objc func showsendDB(time : Double = 12){
        DispatchQueue.main.asyncAfter(deadline: .now() + time){
            NotificationCenter.default.post(name: Notification.Name(rawValue: "BleRefresh"), object:self.ReadYText)
        }
    }
    /** This callback lets us know more data has arrived via notification on the characteristic
     */
    //Here we get values and response from Peripheral
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("called didUpdateValueFor------->",characteristic)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "BleRefresh"), object: "log didUpdateValueFor:----->>>> \(characteristic.description)")
        NotificationCenter.default.post(name: Notification.Name(rawValue: "BleRefresh"), object: "Reading Characteristics values")
        trackData(peripheral, characteristic: characteristic, Datas: "IN didUpdateValueFor")
        BluetoothDevice.insertBluetoothDeviceInTable(periperal: peripheral, CharacteristicsID: characteristic.uuid.uuidString, Datas: "In didUpdateValueFor", Description: "characteristic Description \(characteristic.description)")

        guard error == nil else {
            BluetoothDevice.insertBluetoothDeviceInTable(periperal: peripheral, CharacteristicsID: characteristic.uuid.uuidString, Datas: "In didUpdateValueFor", Description: "error debugDescription \(error.debugDescription)")
            BluetoothDevice.insertBluetoothDeviceInTable(periperal: peripheral, CharacteristicsID: characteristic.uuid.uuidString, Datas: "In didUpdateValueFor", Description: "error localizedDescription \(error?.localizedDescription ?? "")")
            print("error--------->",error ?? "")
            return
        }
        let bytes:Data? = characteristic.value!
        print("characteristic received------->",characteristic)
        if  bytes != nil {
            let array = bytes?.withUnsafeBytes {
                [UInt8](UnsafeBufferPointer(start: $0, count: (bytes?.count)!))
            }
            BluetoothDevice.insertBluetoothDeviceInTable(periperal: peripheral, CharacteristicsID: characteristic.uuid.uuidString, Datas: "In didUpdateValueFor", Description: "array bytes value \(array?.enumerated().compactMap{element in "Index \(element.offset), value \(Double(element.element))"}.joined(separator: "     ;     ") ?? "")")
            
            BluetoothDevice.insertBluetoothDeviceInTable(periperal: peripheral, CharacteristicsID: characteristic.uuid.uuidString, Datas: "In didUpdateValueFor", Description: "array value \(array)")

            NotificationCenter.default.post(name: Notification.Name(rawValue: "BleRefresh"), object: "log ArrayValue in Bytes  @ --->>>>>>  \(Date()) \n  values array :----->>>> \(array?.description)")
            print("bytes received------->",array ?? "")
            if let deviceType = device?.context{
                if deviceType ==  .BloodPressure {
                    
                    if deviceName != "Belter_BT"{
                        // if array count == 7 is progress reading
                        if array?.count == 7 {
                            let Dia = (array?[4]) ?? 0
                            delegate?.bluetoothResponse(value1: 0, value2: Double(Dia), value3: 0)
                        }
                        // if array count == 8 is completion reading
                        if array?.count == 8 {
                            let Sys = (array?[3]) ?? 0
                            let Dia = (array?[4]) ?? 0
                            let Pulse = (array?[5]) ?? 0
                            delegate?.bluetoothResponse(value1: Double(Sys), value2: Double(Dia), value3: Double(Pulse))
                            
                            if boolUpdateBPData {
                                boolUpdateBPData = false
                                _ = getCurrentDateTime()
                                delegate?.afterCompletion()
                            }
                        }
                        // if array count == 6 is show error
                        if array?.count == 6 {
                            if bytes! == dataE1 as Data {
                                delegateAlert?.callBlutoothErrorMessage(error: BloodPressureErrorAlert.alertE1.rawValue)
                            }
                            else if bytes! == dataE2 as Data {
                                delegateAlert?.callBlutoothErrorMessage(error: BloodPressureErrorAlert.alertE2.rawValue)
                            }
                            else if bytes! == dataE3 as Data {
                                delegateAlert?.callBlutoothErrorMessage(error: BloodPressureErrorAlert.alertE3.rawValue)
                            }
                            else if bytes! == dataE5 as Data {
                                delegateAlert?.callBlutoothErrorMessage(error: BloodPressureErrorAlert.alertE5.rawValue)
                            }
                            else if bytes! == dataEE as Data {
                                delegateAlert?.callBlutoothErrorMessage(error: BloodPressureErrorAlert.alertEE.rawValue)
                            }
                                
                            else if bytes! == dataEC as Data  {
                                delegateAlert?.callBlutoothErrorMessage(error: BloodPressureErrorAlert.alertEC.rawValue)
                            }
                                
                            else if bytes! == dataEB as Data {
                                delegateAlert?.callBlutoothErrorMessage(error: BloodPressureErrorAlert.alertEB.rawValue)
                            }
                        }
                    }else{
                        if array?.count == 7 {
                            let DiaByte = String(array![5])
                            let DecimalDia = Int(DiaByte, radix: 16)!// Hexadecimal to decimal
                            let HexDia = String(DecimalDia, radix: 16)// Decimal to hexadecimal
                            let dia = Double(HexDia) ?? 0
                            delegate?.bluetoothResponse(value1: 0, value2: dia, value3: 0)
                        }
                        
                        if array?.count == 17 {
                            let SysByte1 = String(array![5])
                            let SysByte2 = String(array![6])
                            let Shexa =  SysByte1 + SysByte2
                            let DecimalSys = Int(Shexa, radix: 16)!
                            let h1 = String(DecimalSys, radix: 16)
                            let Sys = Double(h1) ?? 0
                            
                            let DiaByte1 = String(array![7])
                            let DiaByte2 = String(array![8])
                            let Dhexa =  DiaByte1 + DiaByte2
                            let DecimalDia = Int(Dhexa, radix: 16)!
                            let h2 = String(DecimalDia, radix: 16)
                            let Dia = Double(h2) ?? 0
                            
                            let PulseByte1 = String(array![11])
                            let PulseByte2 = String(array![12])
                            let Phexa =  PulseByte1 + PulseByte2
                            let DecimalPulse = Int(Phexa, radix: 16)!
                            let h3 = String(DecimalPulse, radix: 16)
                            let Pulse = Double(h3) ?? 0
                            
                            delegate?.bluetoothResponse(value1: Double(Sys), value2: Double(Dia), value3: Double(Pulse))
                            
                            if boolUpdateBPData {
                                boolUpdateBPData = false
                                delegate?.afterCompletion()
                            }
                        }
                    }
                }else if deviceType ==  .PulseOximeter {
                    if array?.count == 4 {
                        // if array count > 3 is progress reading
                        if Int(array?[3] ?? 0) > 0 {
                            doublePI = Double(Double(array?[3] ?? 0)/10).roundToDecimal(1)
                            doubleSpo2 = Double(array?[2] ?? 0)
                            doublePulse =  Double(array?[1] ?? 0)
                            delegate?.bluetoothResponse(value1: doubleSpo2, value2: doublePulse, value3: doublePI)
                        }else {
                            // if array count = 3 is complete reading
                            if doublePI != 0 {
                                doublePI = 0
                                delegate?.bluetoothResponse(value1: doubleSpo2, value2: doublePulse, value3: doublePI)
                                delegate?.afterCompletion()
                            }
                        }
                    }
                }else if deviceType ==  .Thermometer {
                    if deviceName != "Belter_TP"{
                        let bytesData:NSData = characteristic.value! as NSData
                        var stringformat = NSString()
                        if #available(iOS 13.0, *) {
                            stringformat = NSString(format: "%@", bytesData.debugDescription)
                        }else{
                            stringformat = NSString(format: "%@", bytesData)
                        }
                        stringformat = stringformat.replacingOccurrences(of: "<" as String, with: "") as NSString
                        stringformat = stringformat.replacingOccurrences(of: ">" as String, with: "") as NSString
                        
                        if stringformat.length >= 8 {
                            // here we get reading between 4 to 7
                            let stringBytesValue = (stringformat as String)[(stringformat as String).index((stringformat as String).startIndex, offsetBy: 4)...(stringformat as String).index((stringformat as String).startIndex, offsetBy: 7)]
                            
                            if let numBytes = Int(stringBytesValue, radix: 16) {
                                let double  = Double(numBytes) / 100
                                let TempFahrenheit = (double * 9.0/5.0) + 32.0
                                delegate?.afterCompletion()
                                delegate?.bluetoothResponse(value1: TempFahrenheit, value2: 0, value3: 0)
                            }
                        }
                    }else{
                        let bytesData:NSData = characteristic.value! as NSData
                        var stringformat = NSString()
                        if #available(iOS 13.0, *) {
                            stringformat = NSString(format: "%@", bytesData.debugDescription)
                        }else{
                            stringformat = NSString(format: "%@", bytesData)
                        }
                        stringformat = stringformat.replacingOccurrences(of: "<" as String, with: "") as NSString
                        stringformat = stringformat.replacingOccurrences(of: ">" as String, with: "") as NSString
                        
                        if stringformat.length == 30 {
                            // here we get reading between 13 to 17
                            let stringBytesValue = (stringformat as String)[(stringformat as String).index((stringformat as String).startIndex, offsetBy: 13)...(stringformat as String).index((stringformat as String).startIndex, offsetBy: 16)]
                            var TempFahrenheit =  Double()
                            if let numBytes = Int(stringBytesValue, radix: 16) {
                                let double  = Double(numBytes) / 100
                                TempFahrenheit = (double * 9.0/5.0) + 32.0
                                TempFahrenheit = Double(String(NSString(format:"%.5f",TempFahrenheit)).dropLast(3)) ?? TempFahrenheit
                            }
                            delegate?.afterCompletion()
                            delegate?.bluetoothResponse(value1: TempFahrenheit, value2: 0, value3: 0)
                        }
                    }
                }else if deviceType ==  .GlucoseMeter {
                    if deviceName == "Samico GL"{
                        if array?.count == 5 {
                            //Here we get reading if array.count == 5
                            let doubleBloodGlucose:Double = Double(String(describing:(array?[2])!))!
                            delegate?.bluetoothResponse(value1: doubleBloodGlucose, value2: 0, value3: 0)
                        }
                    }else {
                        print("Glocose values array-------->",array!)
                        print("Glocose Characterstic------->",characteristic)
                        print("Glocose characteristic value-------->",characteristic.value! as NSData)
                        
                        // Values formate by document ( AAAAATTTTCC  ) A-vals T-temp  C-stripcode
                        if array?.count == 11 {
                            //Here we get reading if array.count == 5
                            let _:Double = Double(String(describing:(array?[2])!))!

                        }
                        
                        // method 2
                        let bytesData:NSData = characteristic.value! as NSData
                        var  stringformat =  NSString(format: "%@", bytesData)
                        stringformat = stringformat.replacingOccurrences(of: "<" as String, with: "") as NSString
                        stringformat = stringformat.replacingOccurrences(of: ">" as String, with: "") as NSString
                        
                        if stringformat.length >= 10 {
                            // here we get reading between 0 to 17
                            let stringBytesValue = (stringformat as String)[(stringformat as String).index((stringformat as String).startIndex, offsetBy: 0)...(stringformat as String).index((stringformat as String).startIndex, offsetBy: 4)]
                            if let numBytes = Int(stringBytesValue, radix: 16) {
                                print(numBytes)
                            }
                        }
                    }
                    
                }else if deviceType ==  .Scale {
                    
                    if deviceName == DeviceNames.HealthScale.rawValue || deviceName == DeviceNames.JPD_HealthScale.rawValue{
                        if array?.count == 11 ,array?[9] == 0 {
                            
                            let bytesValueOfWeight:NSData = characteristic.value! as NSData
                            // var stringBytesOfWeight = NSString(format: "%@", bytesValueOfWeight)
                            var stringBytesOfWeight = NSString()
                            if #available(iOS 13.0, *) {
                                stringBytesOfWeight = NSString(format: "%@", bytesValueOfWeight.debugDescription)
                            }else{
                                stringBytesOfWeight = NSString(format: "%@", bytesValueOfWeight)
                            }
                            stringBytesOfWeight = stringBytesOfWeight.replacingOccurrences(of: "<", with: "") as NSString
                            stringBytesOfWeight = stringBytesOfWeight.replacingOccurrences(of: ">", with: "") as NSString
                            if stringBytesOfWeight.length > 11{
                                let bytesOfWeight1 = (stringBytesOfWeight as String)[(stringBytesOfWeight as String).index((stringBytesOfWeight as String).startIndex, offsetBy: 6)...(stringBytesOfWeight as String).index((stringBytesOfWeight as String).startIndex
                                    , offsetBy: 7)]
                                let bytesOfWeight2 = (stringBytesOfWeight as String)[(stringBytesOfWeight as String).index((stringBytesOfWeight as String).startIndex, offsetBy: 9)...(stringBytesOfWeight as String).index((stringBytesOfWeight as String).startIndex
                                    , offsetBy: 10)]
                                //Here we get between 7 to 10
                                if isSaved == false{
                                    if let numbytes = Int(bytesOfWeight2 + bytesOfWeight1,radix:16){
                                        doubleValue = Double(numbytes)/100
                                        stringWeight = NSString(format:"%.1f",doubleValue)
                                    }
                                    
                                    if stringWeight != ""{
                                        
                                        let doub = (stringWeight).doubleValue
                                        let poundsValue = (doub) * (2.20462)
                                          isSaved = true
                                        stringWeight = ""
                                        delegate?.bluetoothResponse(value1: poundsValue, value2: 0, value3: 0)
                                    }
                                    delegate?.afterCompletion()
                                }
                            }
                        }
                        
                    }else if deviceName != "Body Fat-B2" {
                        let bytesValueOfWeight:NSData = characteristic.value! as NSData
                        // var stringBytesOfWeight = NSString(format: "%@", bytesValueOfWeight)
                        var stringBytesOfWeight = NSString()
                        if #available(iOS 13.0, *) {
                            stringBytesOfWeight = NSString(format: "%@", bytesValueOfWeight.debugDescription)
                        }else{
                            stringBytesOfWeight = NSString(format: "%@", bytesValueOfWeight)
                        }
                        stringBytesOfWeight = stringBytesOfWeight.replacingOccurrences(of: "<", with: "") as NSString
                        stringBytesOfWeight = stringBytesOfWeight.replacingOccurrences(of: ">", with: "") as NSString
                        //Here we get reading if array.count == 35
                        if stringBytesOfWeight.length == 35{
                            let bytesOfWeight = (stringBytesOfWeight as String)[(stringBytesOfWeight as String).index((stringBytesOfWeight as String).startIndex, offsetBy: 9)...(stringBytesOfWeight as String).index((stringBytesOfWeight as String).startIndex
                                , offsetBy: 12)]
                            //Here we get between 9 to 12
                            if isSaved == false{
                                if let numbytes = Int(bytesOfWeight,radix:16){
                                    doubleValue = Double(numbytes)/10
                                    stringWeight = NSString(format:"%.1f",doubleValue)
                                }
                                
                                if stringWeight != ""{
                                    
                                    let doub = (stringWeight).doubleValue
                                    let poundsValue = (doub) * (2.20462)
                                    delegate?.bluetoothResponse(value1: poundsValue, value2: 0, value3: 0)

                                     isSaved = true
                                    stringWeight = ""
                                }
                                delegate?.afterCompletion()
                            }
                        }
                    }else{
                      
                        
                    }
                }
            }else{
                //new devices
                BluetoothDevice.insertBluetoothDeviceInTable(periperal: peripheral, CharacteristicsID: characteristic.uuid.uuidString, Datas: "In didUpdateValueFor", Description: "$$$------->>>>characteristic Description \(characteristic.description)")
            }
        }else{
            BluetoothDevice.insertBluetoothDeviceInTable(periperal: peripheral, CharacteristicsID: characteristic.uuid.uuidString, Datas: "In didUpdateValueFor", Description: "bytes is nil")
        }
        showsendDB(time: 5)
    }
    
    func centralManager(_: CBCentralManager, didDisconnectPeripheral: CBPeripheral, error: Error?) {
        if error != nil{
            NotificationCenter.default.post(name: Notification.Name(rawValue: "BleRefresh"), object: "Device disconnected.")
            delegateAlert?.callBlutoothErrorMessage(error: "Device is disconnected. Do you want to scan again")
        }
    }
    
    //Method is called after a peripheral is connected
    func stopScanning(){
        centralManager?.stopScan()
    }
    
    //Method is called when user navigate back to previous screen from nearby list screen
    func cancelPheriPeralConnection() {
        stopScanning()
        StoreValue = "No"
        if discoveredPeripheral != nil {
            centralManager?.cancelPeripheralConnection(discoveredPeripheral!)
            discoveredPeripheral = nil
        }
    }
}


 
struct GlobalReusability{
    
    
    /*
     Declaration    struct DateFormats
     
     Description    This method is used to create static Declaration of DateTime Formats.
     
     Declared In    GlobalReusability.swift
     */
    
    struct DateFormats{
        
        //local db Format
        static let LocalDBDateTimeSlashFormat = "yyyy/MM/dd HH:mm:ss"
        static let LocalDBDateTimeFormat = "yyyy-MM-dd HH:mm:ss"
        static let LocalDBDateFormat = "yyyy-MM-dd"
        static let LocalDBDateFormat1 = "yyyy/MM/dd"
        static let reverseYearFormat = "MMM-dd-yyyy"
        static let localDateformat1 = "MMM d, yyyy"
        static let hoursMinuteFormat = "h:mm a"
        static let Hoursminstime = "H:mm:ss"
        static let hoursMinuteFormat1 = "hh:mm a"
        static let hoursMinuteFormat2 = "HH:mm:ss"
        static let FullDateFormat = "MMMM ddth"
        static let hours = "hh"
        static let year = "yyyy"
        static let QuestionnaireMonth = "MMMM"
        static let month = "MMM"
        static let am = "am"
        static let pm = "pm"
        static let hrs12 = "12:00"
        
        //UTC formate
        static let UTCDateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        static let UTCDateFormat1 = "yyyy-MM-dd'T'HH:mm:ss"
        static let notificationDateFormat = "yyyy-MM-dd HH:mm"
        static let apiNotificationFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        static let apiUTCFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        
        //displayformates
        static let dashboardDateFormat = "MMM d, yyyy. h:mm a"
        static let painManagementDashboardDateFormat = "M/d/yyyy h:mm:ss a"
        static let symptomsHistoryNotesDateFormat = "MMM d, yyyy"
        static let NotificationHeaderDateFormat = "MMMM d,yyyy"
        static let HistoryHeaderDateFormat = "MMM d,yyyy"
        static let GraphDateFormat = "h:mm a"
        static let localReverseDateFormat = "h:mm a, MMM d, yyyy"
        static let localreverseTimeformate = "MMM d, yyyy - h:mm a"
        static let ChatFormat = "H:mm"
        static let withOutSession = "hh:mm"
        static let displayDateFormat = "M/d/yyyy"
        static let graphDateFormat = "MMM d,yyyy \n h:mm a"
        static let markerDateFormat = "MMM d,yyyy h:mm a"
        static let PainProgressDateFormat = "MMM d,yyyy - h:mm a"
        static let ChatDateFormat = "MMM d"
        static let ChatDateFormat1 = "d MMM"
        static let WoundSymptomHistoryDateFormat = "MMM d, yyyy - h:mm a"
        static let patientDetailedReadingDateFormat = "MM/dd/yyyy hh:mm:ss a"
        static let patientGraphDateFormat = "M/d"
        static let patientMoodDetailedReadingDateFormat = "MMM d, yyyy h:mm a"
        
        
        //defaults
        static let calendarHomeDateFormat = "MMM d, yyyy"
        static let StoreFilesFormat =  "yyyyMMddhhmmss"
        static let lineChartFormat = "M/d/yyyy H:mm"
        static let DosageTimeFormat = "h:mm a\nMM/dd/yyyy"
        static let DosageTimeFormatReverse = "h:mm a\ndd-MM-yyyy"
        
        //watch
        static let HomeScreenDateFormat = "MMM dd yyyy, hh:mm"
        static let detailScreenDateFormat = "MMM dd yyyy"
        static let Calendar24formate = "HH:mm"
        static let timeSession = "a"
        static let manualActivitydiffCheck = "yyyy-MM-dd h:mm a"
        static let wordMonthWithDate = "MMM dd"
        
        // Clinical staff
        static let customRangeDateFormat = "M-d-yyyy"
        static let healthAlertDashboardDateFormat = "MMM d,yy"
        static let medicationAddDateFormat = "MM/dd/yyyy"
        static let accountSettingsDateFormate = "MM-dd-yyyy"
        static let woundHistoryDateFormat = "M/dd/yyyy hh:mm a"
        static let questionnarieDashboardDateFormat = "MMM dd,yyyy"
        
    }
}
enum HealthDevice: String{
    case PulseOximeter = "Pulse Oximeter"
    case BloodPressure = "Blood Pressure"
    case GlucoseLevel = "Glucose Level"
    case Thermometer = "Thermometer"
    case Weight = "Weight"
}


extension Double {
    func roundToDecimal(_ fractionDigits: Int) -> Double {
        let multiplier = pow(10, Double(fractionDigits))
        
        return Darwin.round(self * multiplier) / multiplier
    }
}

//Peripheral Names as received in response after initiating Bluetooth connection
enum DeviceNames:String{
    var paramKey:Constants.VitalsParams{
        switch self{
        case .Scale, .HealthScale, .JPD_HealthScale:
            return .Weight
        case .Glucometer:
            return .BloodGlucose
        case .Thermometer:
            return .BodyTemperature
        default:
            return .Rest
        }
    }
    var context:Constants.Vitals{

        switch self {
        case .BloodPressure, .JumberBPPDHA120, .JumberBPPDHA121, .JPD_JumberBPPDHA120 , .BelterBT:
            return .BloodPressure
        case .PulseOximeter, .BLTM70C:
            return .PulseOximeter
        case .Glucometer:
            return .GlucoseMeter
        case .Thermometer, .BelterTP, .JumberJPDFR,  .JumberJPDFR400:
            return .Thermometer
        case .Scale, .HealthScale, .JPD_HealthScale:
            return .Scale
        case .ActivityTracker, .none:
            return .none
        default:
            return .none
        }
    }
    var unit: String{
        switch self {
        case .Glucometer:
            return "mg/dl"
        case .Thermometer:
            return "\u{00B0}F"
        case .Scale, .HealthScale, .JPD_HealthScale:
            return "lbs"
        default:
            return ""
        }
    }
    var headerText: String{
        switch self {
        case .BloodPressure, .JumberBPPDHA120, .JumberBPPDHA121, .JPD_JumberBPPDHA120:
            return "BLOOD PRESSURE"
        case .PulseOximeter, .BLTM70C:
            return "SPO2"
        case .Glucometer:
            return "GLUCOMETER"
        case .Thermometer, .BelterTP, .JumberJPDFR,  .JumberJPDFR400:
            return "THERMOMETER"
        case .Scale, .HealthScale, .JPD_HealthScale:
            return "SCALE"
        case .ActivityTracker, .none:
            return ""
        default:
            return ""
        }
    }
    case BloodPressure = "Bluetooth BP"
    case PulseOximeter = "My Oximeter"
    case Thermometer = "My Thermometer"
    case Glucometer = "Samico GL"
    case Scale = "Electronic Scale"
    case ActivityTracker = "AT-500HR"
    
    //new devices
    case eBloodPressure = "eBlood-Pressure"
    case BelterBT = "Belter_BT"
    case BLTM70C = "BLT_M70C"
    case BelterTP = "Belter_TP"
    case BLEGlucose = "BLE-Glucose"
    case GmateVoicePlus1 = "Gmate Voice Plus      "
    case GmateVoicePlus2 = "Gmate Voice Plus       "
    case ChipseaBLE = "Chipsea-BLE"
    case BodyFatB2  = "Body Fat-B2"
    
    //new jumber devices
    //Bp
    case JumberBPPDHA120 = "JPD-HA120"
    case JumberBPPDHA121 = "JPD-HA121"
    //Scale
    case HealthScale = "Health Scale"
    //Thermo
    case JumberJPDFR = "JPD-FR409BT"
    case JumberJPDFR400 = "JPD-FR400"
    case JPD_HealthScale = "JPD Scale"
    case JPD_JumberBPPDHA120 = "JPD BPM"
    
    case none
}

/*
 Declaration    enum BloodPressureErrorAlert: String
 
 Description    This method is used to shoe bluetooth devices error messages.
 
 Returns        String - This param is used to returns string values.
 
 Declared In    Constants.swift
 */

enum BloodPressureErrorAlert: String {
    case alertE1 = "The Signal of Human heart beat is too small or pressure drop.It is error measurement,please refer to the user manual to rewear the CUFF,kepp calm and take measurement again"
    case alertE2 = "Noise interference.It is error measurement,please refer to the user manual to rewear the CUFF,kepp calm and take measurement again"
    case alertE3 = "The inflation time is too long.It is error measurement,please refer to the user manual to rewear the CUFF,kepp calm and take measurement again"
    case alertE5 = "The result of measurement is abnormal.It is error measurement,please refer to the user manual to rewear the CUFF,kepp calm and take measurement again"
    case alertEE = "Abnormal blood pressure contact your vendor"
    case alertEC = "Correction of abnormal.It is error measurement,please refer to the user manual to rewear the CUFF,kepp calm and take measurement again"
    case alertEB = "The power has low voltage. The batteries are low, please replace the batteries"
}

 
struct Constants {
        /*
     Declaration    enum Vitals:String
     
     Description    This method is used to get Vitals module names.
     
     Returns        String - This param is used to returns module name.
     
     Declared In    Constants.swift
     */
    
    enum Vitals:String{
        case  BloodPressure
        case  PulseOximeter
        case  Scale
        case  Thermometer
        case  GlucoseMeter
        case  HeartRate
        case none
    }
    /*
     Declaration    enum VitalsParams:String
     
     Description    This method is used to get VitalsParams master names.
     
     Returns        String - This param is used to returns master name.
     
     Declared In    Constants.swift
     */
    
    enum VitalsParams:String{
        case Systolic
        case Diastolic
        case Pulse
        case SPO2
        case PerfusionIndex
        case Weight
        case BloodGlucose
        case BodyTemperature
        case Activity
        case Medication
        case Meals
        case Calories
        case Distance
        case Rest
        case Duration
        case Steps
        case Sleep
        case Smoking
        case Beverages
    }
}
