 
 import UIKit
 import CoreBluetooth
 import MessageUI
 
 class ViewController: UIViewController, MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
        objectBluetooth.cancelPheriPeralConnection()
        self.NavigateRootVC()
    }
    
    @IBOutlet var tableViewPheripherals:UITableView!
    @IBOutlet var InitialView:UIView!
    @IBOutlet var startScanLbl:UILabel!
    
    //LogsView
    @IBOutlet var LogsView:UIView!
    @IBOutlet var BtnShowLogs:UIView!
    @IBOutlet var BtnSendLogs:UIView!
    @IBOutlet var logsTextView:UITextView!
    
    //Readingsview
    @IBOutlet var btnSendDB:UIView!
    @IBOutlet var viewRedings:UIView!
    @IBOutlet var lblStatus:UILabel!
    @IBOutlet var lblDevicename:UILabel!

    
    @IBOutlet var btnAddReadings:UIView!

    var isDisconnectState = false
    var isScanning = false
    var objectBluetooth = BlueTooth()
    var bluetoothManager: CBCentralManager?
    var lastUpdatedTime = Date()
    var isfinalreadingreceived = false
    
    //Below are Class Variables
    let ReadYText = "Required data has been retrieved. Please Enter reading and click send DB"
    var peripherals = Array<CBPeripheral>()
    var selectedPeripheral : CBPeripheral?
    var peripheralNames = Set<String>()
    var  deviceName = [String]()
    var peripheralname = String()
    var peripheralID = String()
    var isReadingsTaken = false
    override func viewDidLoad() {
        super.viewDidLoad()
        btnSendDB.layer.borderWidth = 2
        btnSendDB.layer.borderColor = UIColor.white.cgColor
        btnSendDB.layer.cornerRadius = 5
        
        btnAddReadings.layer.borderWidth = 1
        btnAddReadings.layer.borderColor = UIColor.white.cgColor
        btnAddReadings.layer.cornerRadius = 5
        logsTextView.isEditable = false
        BtnShowLogs.layer.borderWidth = 2
        BtnShowLogs.layer.borderColor = UIColor.white.cgColor
        BtnShowLogs.layer.cornerRadius = 5

         deviceName = [DeviceNames.BloodPressure.rawValue,DeviceNames.eBloodPressure.rawValue,DeviceNames.BelterBT.rawValue,DeviceNames.JumberBPPDHA120.rawValue,DeviceNames.JumberBPPDHA121.rawValue,DeviceNames.JPD_JumberBPPDHA120.rawValue,DeviceNames.PulseOximeter.rawValue,DeviceNames.Thermometer.rawValue,DeviceNames.BelterTP.rawValue,DeviceNames.JumberJPDFR.rawValue,DeviceNames.JumberJPDFR400.rawValue,DeviceNames.Glucometer.rawValue,DeviceNames.BLEGlucose.rawValue,DeviceNames.GmateVoicePlus1.rawValue,DeviceNames.GmateVoicePlus2.rawValue,DeviceNames.Scale.rawValue,DeviceNames.ChipseaBLE.rawValue,DeviceNames.BodyFatB2.rawValue,DeviceNames.HealthScale.rawValue,DeviceNames.JPD_HealthScale.rawValue,"Apple Watch"]
        
        startScanLbl.layer.cornerRadius = 100
        startScanLbl.layer.borderColor = UIColor.white.cgColor
        startScanLbl.layer.borderWidth = 5
        LogsView.layer.cornerRadius = 20
        
        // Do any additional setup after loading the view.
        objectBluetooth.delegate = self
        objectBluetooth.delegateAlert = self
        bluetoothManager = CBCentralManager(delegate: self, queue: nil)
        tableViewPheripherals.tableFooterView = UIView()
        tableViewPheripherals.reloadData()
        tableViewPheripherals.register(UINib(nibName: String.init(describing: BluetoothConnectivityTableViewCell.self), bundle: nil), forCellReuseIdentifier: String.init(describing: BluetoothConnectivityTableViewCell.self))
        DispatchQueue.main.async {   self.StartScanning(UIButton())   }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector:#selector(self.HandlecallBackEvents(notification:)), name: Notification.Name(rawValue: "BleRefresh"), object: nil)
     }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: "BleRefresh"), object: nil)
    }
 
    @IBAction func SwipeGuestureAction(_ sender: AnyObject) {
        objectBluetooth.cancelPheriPeralConnection()
        self.NavigateRootVC()
    }
    @objc func HandlecallBackEvents(notification: NSNotification) {
        if let notificationobject = notification.object as? String {
            if ReadYText == notificationobject{
                self.btnSendDB.isHidden = false
                self.btnAddReadings.isHidden = false
            }
            if notificationobject == "ShowLogsOptions"{
               // self.BtnShowLogs.isHidden = false
                addLog(LogText: "Device Connected ")
                addLog(LogText: "Connected time -->> \(Date())")
                LogsView.isHidden = false
                self.viewRedings.isHidden = false
                self.lblStatus.text = "Device Connected"
            }else {
                if !notificationobject.contains("log"){
                    if !isReadingsTaken{  self.lblStatus.text = notificationobject }
                }else{
                    let notificationobjectNw = notificationobject.replacingOccurrences(of: "log", with: "")
                    addLog(LogText: notificationobjectNw)
                }
            }
        }
    }
    
    func addLog(LogText:String){
        logsTextView.text = logsTextView.text + "\n"  + "\n"  +  LogText
        let bottom = NSMakeRange(logsTextView.text.count - 1, 1)
        logsTextView.scrollRangeToVisible(bottom)
        if !LogText.contains("User Data Entry"){
            self.LogsView.isHidden = false
        }
        lastUpdatedTime = Date()
        checkDisconnect()
    }
    
    func checkDisconnect()
    {
        let max:Double = deviceName.contains(peripheralname) ? 7 : 10
        let min:Double = deviceName.contains(peripheralname) ? 6 : 9
        DispatchQueue.main.asyncAfter(deadline: .now() + max){
            if Date() > self.lastUpdatedTime.addingTimeInterval(min){
                if !self.LogsView.isHidden{
                    self.addLog(LogText: "LogsView is hidded @\(Date()) ")
                    self.LogsView.isHidden = true
                    self.btnSendDB.isHidden = false
                    self.btnAddReadings.isHidden = false
                }
            }
        }
       /* DispatchQueue.main.asyncAfter(deadline: .now() + 5){
            if self.isDisconnectState && !self.LogsView.isHidden{
                self.LogsView.isHidden = true
                self.btnSendDB.isHidden = false
                self.btnAddReadings.isHidden = false
            }else{
                
            }
        }*/
    }
    
    /*
     Declaration    showPulseAnimation()
     
     Description    This method used to show call Animation
     
     Declared In     callUIViewController.swift
     */
    
    func showPulseAnimation(){
        CreatePulseAnimation(CACurrentMediaTime())
        CreatePulseAnimation(CACurrentMediaTime() + 0.7)
        //  CreatePulseAnimation(CACurrentMediaTime() + 1.4)
    }
    /*
     Declaration    CreatePulseAnimation()
     
     Description    This method used to create call Animation
     
     Declared In     callUIViewController.swift
     */
    func CreatePulseAnimation(_ beginTime: CFTimeInterval) {
        _ = UIColor( red:  91/255 , green: 120/255, blue: 163/255, alpha: 1)
        
        let circlePath1 = UIBezierPath(arcCenter: self.startScanLbl.center, radius: CGFloat(95), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
        let circlePath2 = UIBezierPath(arcCenter: self.startScanLbl.center, radius: CGFloat(200), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.fillColor = UIColor.gray.cgColor
        shapeLayer.path = circlePath1.cgPath
        self.InitialView.layer.insertSublayer(shapeLayer, at: 0)
        
        let pathAnimation = CABasicAnimation(keyPath: "path")
        pathAnimation.fromValue = circlePath1.cgPath
        pathAnimation.toValue = circlePath2.cgPath
        let alphaAnimation = CABasicAnimation(keyPath: "opacity")
        alphaAnimation.fromValue = 0.8
        alphaAnimation.toValue = 0
        
        let animationGroup = CAAnimationGroup()
        animationGroup.beginTime = beginTime
        animationGroup.animations = [pathAnimation, alphaAnimation]
        animationGroup.duration = 1.7
        animationGroup.repeatCount = Float.greatestFiniteMagnitude
        animationGroup.isRemovedOnCompletion = false
        shapeLayer.add(animationGroup, forKey: "sonar")
    }
    func showErrorMessageAlert(message:String) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "YES", style: UIAlertAction.Style.default, handler: {(action:UIAlertAction) in
            self.LogsView.isHidden = true
            self.NavigateRootVC()
        }))
        alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.default, handler: {(action:UIAlertAction) in
            self.btnSendDB.isHidden = false
            self.btnAddReadings.isHidden = false
            self.LogsView.isHidden = true
        }))
        self.present(alert, animated: false, completion: nil)
    }

    
    func NavigateRootVC(){
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let secondViewController = sb.instantiateViewController(withIdentifier: "InitialVC") as! InitialVC
        self.navigationController?.pushViewController(secondViewController, animated: false)
    }
    
    @objc func didScanDevice(notify:Notification){
        let p: CBPeripheral = notify.userInfo?["peripheral"] as! CBPeripheral
        BluetoothDevice.insertBluetoothDeviceInTable(periperal: p, CharacteristicsID: "NULL", Datas: "In didScanDevice", Description: "scane device \(String(describing: p.name))")
        if p.name != nil {
            BluetoothDevice.insertBluetoothDeviceInTable(periperal: p, CharacteristicsID: "NULL", Datas: "In didScanDevice", Description: "scane device \(String(describing: p.name))")
            if  peripheralNames.insert(p.name ?? "").inserted{
                peripherals.append(p)
                tableViewPheripherals.reloadData()
            }
        }
    }
    @IBAction func AddReadings(_ sender:UIButton!) {
 

        let alert = UIAlertController(title: "", message: "Please Enter Reading", preferredStyle: .alert)

        alert.addTextField { (textField) in
            textField.text = ""
        }

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            BluetoothDevice.insertBluetoothDeviceInTable(periperal: nil, CharacteristicsID: "NULL", Datas: "User Reading Entry ", Description: "User value \(textField?.text ?? "") ")
            self.addLog(LogText: "User Data Entry --->> \(textField?.text ?? "")")
            print("Text field values -->>: \(textField?.text)")
        }))

        self.present(alert, animated: true, completion: nil)
        
    }
    @IBAction func StartScanning(_ sender:UIButton!) {
        BluetoothDevice.insertBluetoothDeviceInTable(periperal: nil, CharacteristicsID: "NULL", Datas: "In StartScanning", Description: "Start Scanning ")
        if !isScanning{
            BluetoothDevice.insertBluetoothDeviceInTable(periperal: nil, CharacteristicsID: "NULL", Datas: "In isScanning", Description: "Start Scanning \(isScanning) ")
            startScanLbl.text = "Scanning..."
            isScanning = true
            showPulseAnimation()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1 ){
                self.objectBluetooth.scanBluetoothDevice()
            }
        }
    }
    @IBAction func ShowLogs(_ sender:UIButton!) {
        if sender.tag == 0 {
            LogsView.isHidden = false
        }else{
            LogsView.isHidden = true
        }
    }
    
    @IBAction func SendLogs(_ sender:UIButton!) {  }
    @IBAction func sendDataBase(_ sender: UIButton) {
        guard let data = NSData(contentsOfFile: SD.databasePath()) else {
            return
        }
        testmail(data: data as Data)
    }
 
           let mailids = [""]
    
    /*
     Declaration    testmail(filedate:Data)
     
     Description    This method used to send Email
     
     Declared In   HomeViewController.swift
     */
    func testmail(data:Data){
        if !MFMailComposeViewController.canSendMail() {
            print("Mail services are not available")
            return
        }else{
            let composeVC = MFMailComposeViewController()
            composeVC.mailComposeDelegate = self
            composeVC.setToRecipients(mailids)
            composeVC.setSubject("Sqlite DB")
            
            var Mailbody = "  Device Name : \(peripheralname)  \n   Date : \(Date().convertToSring(GlobalReusability.DateFormats.LocalDBDateTimeFormat))  \n   Logs: "
            Mailbody = Mailbody + "\n" + logsTextView.text
            composeVC.addAttachmentData(data, mimeType: ".sqlite", fileName: "Database.sqlite")
            composeVC.setMessageBody(Mailbody, isHTML: false)
            self.present(composeVC, animated: true, completion: nil)
        }
    }

 }
 extension ViewController:bluetoothDelegate{
    func getNearbyBluetoothDevicelist(_ peripheral:CBPeripheral) {
        print("--->> Retrived peripheral ",peripheral.name ?? "")
        BluetoothDevice.insertBluetoothDeviceInTable(periperal: peripheral, CharacteristicsID: "NULL", Datas: "In getNearbyBluetoothDevicelist", Description: "scane device \(String(describing: peripheral.name))")
        if peripheral.name != nil {
            if  peripheralNames.insert(peripheral.name ?? "").inserted{
                peripherals.append(peripheral)
                tableViewPheripherals.reloadData()
            }
        }
    }
    
    func  bluetoothResponse(value1:Double,value2:Double,value3:Double){
        
        BluetoothDevice.insertBluetoothDeviceInTable(periperal: nil, CharacteristicsID: "NULL", Datas: "Device values are --->>", Description: "value1 :\(value1)    value2 :\(value2)   value3 :\(value3)")
       addLog(LogText: "Progress reading @ --->>>>>>  \(Date())  \n ---->>> value1 :  \(value1)  :   value2 :  \(value2)    :   value3 :  \(value3)")
        /*if let deviceType = DeviceNames(rawValue: peripheralname)  {
            isReadingsTaken = true
            if deviceType == .BloodPressure {
                lblStatus.text = " Systolic : \(value1)  \n  Diastolic : \(value2)  \n Pulse : \(value3)  "
            }else if deviceType ==  .PulseOximeter {
                lblStatus.text = " Spo2 : \(value1)  \n  Pulse : \(value2)  \n PI : \(value3)  "
            }else if deviceType ==  .Thermometer {
                lblStatus.text = " Temp : \(value1) "
            }else if deviceType ==  .Glucometer{
                lblStatus.text = "Glucose : \(value1) "
            }else if deviceType ==  .Scale {
                lblStatus.text = "Weight : \(value1) "
            }
        }*/
    }
    
    //After complete
    func afterCompletion() {
        BluetoothDevice.insertBluetoothDeviceInTable(periperal: nil, CharacteristicsID: "NULL", Datas: " Final readings Completed \(Date())", Description: "final reading completed @ \(Date())")
        addLog(LogText: "final reading received @  ---->>> \(Date())")
        lblStatus.text = ReadYText
        viewRedings.isHidden = false
        self.btnSendDB.isHidden = false
        self.btnAddReadings.isHidden = false
        isfinalreadingreceived = true
        objectBluetooth.cancelPheriPeralConnection()
        if  self.LogsView.isHidden{
            self.LogsView.isHidden = true
            self.btnSendDB.isHidden = false
            self.btnAddReadings.isHidden = false
        }
    }
 }
 
 extension ViewController : CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        BluetoothDevice.insertBluetoothDeviceInTable(periperal: nil, CharacteristicsID: "NULL", Datas: "In centralManagerDidUpdateState", Description: "centralManagerDidUpdateState \(central.state)")
        switch central.state {
        case .poweredOn:
            print("powered on")
        case .poweredOff:
            print("powered off")
            //showErrorMessage(message: "Trun on Bluetooth")
            self.showErrorMessageAlert(message:"Please Trun on Bluetooth")
        case .resetting:
            print("resetting")
        case .unauthorized:
            print("unauthorized")
        case .unsupported:
            print("unsupported")
        case .unknown:
            print("unknown")
        @unknown default:
            print("unknown")
        }
    }
 }
 extension ViewController:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if peripherals.count > 0 { InitialView.isHidden = true }
        BluetoothDevice.insertBluetoothDeviceInTable(periperal: nil, CharacteristicsID: "NULL", Datas: "In numberOfRowsInSection", Description: "peripherals count \(peripherals.count)")
        return peripherals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String.init(describing: BluetoothConnectivityTableViewCell.self), for: indexPath) as! BluetoothConnectivityTableViewCell
        cell.nameLabel.text  = peripherals[indexPath.row].name ?? ""
        cell.nameLabel.font = UIFont.boldSystemFont(ofSize: 25)
       /* if deviceName.contains(peripherals[indexPath.row].name ?? "") {
            cell.nameLabel.textColor = UIColor.white
        }else {
            cell.nameLabel.textColor = UIColor.gray
        }*/
        cell.nameLabel.textColor = UIColor.white
        cell.tag = indexPath.row
        cell.selectionStyle = .none
        tableView.separatorColor = UIColor(red: 18/255.0, green: 98/255.0, blue: 150/255.0, alpha: 1.0)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height:CGFloat = 60.0
        BluetoothDevice.insertBluetoothDeviceInTable(periperal: peripherals[indexPath.row], CharacteristicsID: "NULL", Datas: "In heightForRowAt", Description: "table height: \(height) ForRowAt \(indexPath)")
        return height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("---->> Clicked \(indexPath.row)")
        if let periperalName = peripherals[indexPath.row].name, let device = DeviceNames(rawValue: periperalName)  {
            BluetoothDevice.insertBluetoothDeviceInTable(periperal: peripherals[indexPath.row], CharacteristicsID: "NULL", Datas: "In didSelectRowAt", Description: "didSelectRowAt \(indexPath), its register device, type \(device.context)")
            peripheralname = peripherals[indexPath.row].name ?? ""
            peripheralID =  peripherals[indexPath.row].identifier.uuidString
            selectedPeripheral = peripherals[indexPath.row]
            objectBluetooth.device = device
            objectBluetooth.stopScanning()
            addLog(LogText: "Connecting register device ...")
            //Code to call peripherals with protocols defined explicitly
            objectBluetooth.deviceName = peripherals[indexPath.row].name ?? ""
            objectBluetooth.connect(peripherals[indexPath.row])
        }else{
            BluetoothDevice.insertBluetoothDeviceInTable(periperal: peripherals[indexPath.row], CharacteristicsID: "NULL", Datas: "In didSelectRowAt", Description: "didSelectRowAt \(indexPath) its new device")
            peripheralname = peripherals[indexPath.row].name ?? ""
            peripheralID =  peripherals[indexPath.row].identifier.uuidString
            selectedPeripheral = peripherals[indexPath.row]
            objectBluetooth.device = nil
            objectBluetooth.stopScanning()
            addLog(LogText: "Connecting new device ...")
            //Code to call peripherals with protocols defined explicitly
            objectBluetooth.deviceName = peripherals[indexPath.row].name ?? ""
            objectBluetooth.connect(peripherals[indexPath.row])
        }
        
        addLog(LogText: "Connecting...")
        self.viewRedings.isHidden = false
        //self.btnSendDB.isHidden = false
        self.lblStatus.text = "Connecting..."
        lblDevicename.text = peripheralname
    }
 }
 // show Error message for device readings
 extension ViewController : delegateBluetoothAlert{
    
    func callBlutoothErrorMessage(error: String) {
        addLog(LogText: "error ---->>>   \(error)")
        if !isfinalreadingreceived{
            self.showErrorMessageAlert(message: error)
        }
    }
 }
 
 extension Date{
    /**
     Declaration        - convertToSring(format:String)->String
     
     Description        - This Method is DateFormat in Optional
     
     Returns            - String -> Returns date String Format
     
     Declared In        - NSDateExtentions.swift
     */
    func convertToSring(_ format:String) ->String{
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = format
        dateFormatter.amSymbol  = GlobalReusability.DateFormats.am
        dateFormatter.pmSymbol = GlobalReusability.DateFormats.pm
        return dateFormatter.string(from: self)
    }

 }
