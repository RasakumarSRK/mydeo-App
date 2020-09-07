
//  Copyright 2018 Mydayda Inc.

import UIKit
import CoreBluetooth
#if !targetEnvironment(simulator)
import LifevitSDK
#endif

class BluetoothConnectivityViewController: UIViewController,Alert {
    
    //This outlets are used for header and footer
    @IBOutlet var primaryHeaderView:PrimaryHeader!
    @IBOutlet var secondaryHeaderView:SecondaryHeader!
    @IBOutlet var animationView:UIView!
    @IBOutlet var bluetoothConnectingView:UIView!
    @IBOutlet var availableDevices:UIView!
    @IBOutlet var tableViewPheripherals:UITableView!
    @IBOutlet var progressSysReading:KDCircularProgress!
    @IBOutlet var progressDiaReading:KDCircularProgress!
    @IBOutlet var progressPulseReading:KDCircularProgress!
    @IBOutlet var progressPulseOximeter:KDCircularProgress!
    @IBOutlet var progressTemp:KDCircularProgress!
    @IBOutlet var readingView:UIView!
    @IBOutlet var lblReadingPulse:UILabel!
    @IBOutlet var lblReadingDia:UILabel!
    @IBOutlet var lblReadingSys:UILabel!
    @IBOutlet var lblReadingVitals:UILabel!
    @IBOutlet var lblDateTime:UILabel!
    @IBOutlet var viewBPCircle:UIView!
    @IBOutlet var lblPOSPO2:UILabel!
    @IBOutlet var lblPOPI:UILabel!
    @IBOutlet var lblPOPulse:UILabel!
    @IBOutlet var viewDotAnimationTemp:UIView!
    @IBOutlet var labelDisplayMeasure:UILabel!
    @IBOutlet var viewDotAnimationSys:UIView!
    @IBOutlet var viewDotAnimationDia:UIView!
    @IBOutlet var viewDotAnimationPulse:UIView!
    @IBOutlet var pleaseWaitLabel:UILabel!
    @IBOutlet var alertView:UIView!
    //show paired devices list
    @IBOutlet var lblPairedDevises:UILabel!
    @IBOutlet var tableViewPaireddevices:UITableView!
    @IBOutlet weak var Pairedheightconstraint: NSLayoutConstraint!
    @IBOutlet weak var peripheralheightconstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollviewheight: NSLayoutConstraint!
    @IBOutlet var ScanningLbl:UILabel!
    @IBOutlet var HeartRateLbl:UILabel!


    //Below are Global Variables
    var objectVitals = MDVitals()
    var objectVitalsDetails = MDVitalsDetails()
    var objectMDVitalsDeviceInfo = MDVitalsDeviceInfo()
    var objectActivityTracker = MDActivityTracker()
    var objectBluetooth = BlueTooth()
    var objectVitalsAPI = VitalsAPI()
    var objectActivityTrackerAPI = ActivityTrackerAPI()
    var objectCodeReusability = CodeReusability()
    var objectSleep = MDSleep()
    var objectSleepDetails  = MDSleepDetails()
    var objectMedicineDosage = MDMedicationDosage()
    var objectSleepApi = SleepAPI()
    var bluetoothManager: CBCentralManager?
    let objectBluetoothDevice = MDBluetoothDevice()
    
    //Below are Class Variables
    var peripherals = Array<CBPeripheral>()
    var selectedPeripheral : CBPeripheral?
    var peripheralNames = Set<String>()
    var arrayHeartValues = [NSNumber]()
    var single = true
    var idIdenditifier = String()
    var  deviceName = [String]()
    var Spo2array =  [Double]()
    var PIarray =  [Double]()
    var isNotPaired = false
    var Pulsearray =  [Double]()
    var peripheralname = String()
    var peripheralID = String()
    var isAlert = true
    var forSyncBand = false
    var PairedDeciveList = [SD.SDRow]()
    var PairedDeciveListID = [String]()
    var enablenavigation = true
    var isHeartRate = false
    var isHeartrateScreen = false
    var moduleIndex = 0
  //  var ArrayAlerts = [ACNS_CALL, ACNS_QQ, ACNS_SMS, ACNS_LINE, ACNS_EMAIL, ACNS_SKYPE, ACNS_WECHAT, ACNS_TWITTER, ACNS_FACEBOOK, ACNS_WHATSAPP, ACNS_INSTAGRAM]
    static  let AllModules = ["BloodPressure","BloodGlucose","O2Saturation","HeartRate","Temperature","Weight","Mood","Activities","Calories","Step","Distance","TotalSleep","DeepSleep","LightSleep","REMSleep","Smoking","Alcohol"]//,"Rest"

    //#MARK:- These are default delegates of this class
    override func viewDidLoad() {
        super.viewDidLoad()
        
        primaryHeaderView.delegate = self
        primaryHeaderView.isActivity = true
        secondaryHeaderView.delegate = self
        secondaryHeaderView.visibilityAllIcons(isHidden:true)
        if  UserDefaults.getVitalsName() == menuList.bloodPressure.description{
            deviceName = [DeviceNames.BloodPressure.rawValue,DeviceNames.eBloodPressure.rawValue,DeviceNames.BelterBT.rawValue,DeviceNames.JumberBPPDHA120.rawValue,DeviceNames.JumberBPPDHA121.rawValue,DeviceNames.JPD_JumberBPPDHA120.rawValue]
            primaryHeaderView.setTitle(title: "Blood Pressure")
            moduleIndex = 0
        }else  if  UserDefaults.getVitalsName() == menuList.pulseOximeter.description{
            deviceName = [DeviceNames.PulseOximeter.rawValue,DeviceNames.BLTM70C.rawValue ]
            moduleIndex = 2
            primaryHeaderView.setTitle(title: "Pulse Oximeter")
        }else  if  UserDefaults.getVitalsName() == menuList.heartRate.description{
            moduleIndex = 3
            isHeartrateScreen = true
        #if !targetEnvironment(simulator)
        let isConnect = LifevitSDKManager.sharedInstance()?.isDeviceConnected(DEVICE_BRACELET_AT500HR) ?? false
            if isConnect{
              tableViewPheripherals.isHidden = true
              tableViewPaireddevices.isHidden = true
              objectBluetooth.stopScanning()
              isHeartRate = true
              LifevitSDKManager.sharedInstance()?.getBraceletHeartBeat()
              HeartRateLbl.isHidden = false
            }else{
                deviceName = [DeviceNames.ActivityTracker.rawValue]
            }
            #endif
            primaryHeaderView.setTitle(title: "Heart Rate")
        }else  if  UserDefaults.getVitalsName() == menuList.thermometer.description{
            moduleIndex = 4
            deviceName = [DeviceNames.Thermometer.rawValue,DeviceNames.BelterTP.rawValue,DeviceNames.JumberJPDFR.rawValue,DeviceNames.JumberJPDFR400.rawValue ]
            primaryHeaderView.setTitle(title: "Thermometer")
        }else  if  UserDefaults.getVitalsName() == menuList.glucoseLevel.description{
            moduleIndex = 1
            deviceName = [DeviceNames.Glucometer.rawValue, DeviceNames.BLEGlucose.rawValue,DeviceNames.GmateVoicePlus1.rawValue,DeviceNames.GmateVoicePlus2.rawValue]
            primaryHeaderView.setTitle(title: "Glucometer")
        }else  if  UserDefaults.getVitalsName() == menuList.weight.description{
            moduleIndex = 5
            deviceName = [DeviceNames.Scale.rawValue,DeviceNames.ChipseaBLE.rawValue,DeviceNames.BodyFatB2.rawValue,DeviceNames.HealthScale.rawValue,DeviceNames.JPD_HealthScale.rawValue]
            primaryHeaderView.setTitle(title: "Weight Scale")
        }else  if  UserDefaults.getVitalsName() == "activityTracker"{
            moduleIndex = 7
            lblPairedDevises.isHidden = false
            ScanningLbl.isHidden = false
            tableViewPaireddevices.isHidden = false
            deviceName = [DeviceNames.ActivityTracker.rawValue]
            primaryHeaderView.setTitle(title: "Activity")
        }else  if  UserDefaults.getVitalsName() == "Sleep"{
            moduleIndex = 11
            lblPairedDevises.isHidden = false
            ScanningLbl.isHidden = false
            tableViewPaireddevices.isHidden = false
            deviceName = [DeviceNames.ActivityTracker.rawValue]
            primaryHeaderView.setTitle(title: "Sleep")
        }
        tableViewPheripherals.register(UINib(nibName: String.init(describing: BluetoothConnectivityTableViewCell.self), bundle: nil), forCellReuseIdentifier: String.init(describing: BluetoothConnectivityTableViewCell.self))
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(true)
        secondaryHeaderView.changeUserName()
        Constants.Analytics.ScreenName = "BluetoothConnectivityViewController"
        Constants.Analytics.setpatientVitalsAnalytics(moduleIndex,ScreenType: Constants.ScreenTypes.Home.rawValue)
        
        if !peripherals.isEmpty{
            peripherals.removeAll()
        }
        peripheralNames.removeAll()
        bluetoothConnectingView.isHidden = true
        if UserDefaults.getVitalsName() != "activityTracker" && UserDefaults.getVitalsName() != "Sleep" && !isHeartRate{ bluetoothConnectingView.isHidden = false }
        lblReadingPulse.text = ""
        lblReadingDia.text = ""
        lblReadingSys.text = ""
        lblReadingVitals.text = ""
        lblPOSPO2.text = ""
        lblPOPI.text = ""
        lblPOPulse.text = ""
        self.pleaseWaitLabel.text = ""
        viewDotAnimationDia.isHidden = false
        viewDotAnimationTemp.isHidden = false
        self.viewBPCircle.isHidden = true
        self.readingView.isHidden = true
        self.progressTemp.isHidden = true
        self.progressPulseOximeter.isHidden = true
        progressDiaReading.animate(toAngle: (360 * (0.0/80)), duration:0.5, completion: nil)
        progressPulseOximeter.animate(toAngle: (360 * (0.0/100)), duration:0.5, completion: nil)
        addAnimation()
        addDotAnimation(view:viewDotAnimationSys)
        addDotAnimation(view:viewDotAnimationDia)
        addDotAnimation(view:viewDotAnimationPulse)
        addDotAnimation(view:viewDotAnimationTemp)
        if  UserDefaults.getVitalsName() == "activityTracker" ||  UserDefaults.getVitalsName() == "Sleep"{
            ScanORConnectBand()
        }
        objectBluetooth.delegate = self
        objectBluetooth.delegateAlert = self
        objectBluetooth.scanBluetoothDevice()
        bluetoothManager = CBCentralManager(delegate: self, queue: nil)
        tableViewPheripherals.tableFooterView = UIView()
        intialSetupProgress()
        tableViewPheripherals.reloadData()
        tableViewPaireddevices.reloadData()
        
        #if !targetEnvironment(simulator)
        //Intialize LifevitSDKManager code
        LifevitSDKManager.sharedInstance()?.deviceDelegate = self
        LifevitSDKManager.sharedInstance()?.heartDelegate = self
        LifevitSDKManager.sharedInstance()?.weightscaleDelegate = self
        LifevitSDKManager.sharedInstance()?.braceletAT250Delegate = self
        LifevitSDKManager.sharedInstance()?.braceletDelegate = self
        LifevitSDKManager.sharedInstance()?.devicesScanDelegate = self
        LifevitSDKManager.sharedInstance()?.oximeterDelegate = self
        LifevitSDKManager.sharedInstance()?.scanAllDevices()
        LifevitSDKManager.sharedInstance()?.isBraceletInActivity()
        LifevitSDKManager.sharedInstance()?.isTensioBraceletMeasuring()
        #endif
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
            if self.peripherals.count == 0{
                if self.peripherals.count == 0 && UserDefaults.getVitalsName() != "activityTracker" &&  UserDefaults.getVitalsName() != "Sleep" && !self.isHeartRate {
                    self.navigationController?.popViewController(animated: true)
                }
            } }
        if isHeartRate
        {
            self.progressTemp.isHidden = false
            addDotAnimation(view:viewDotAnimationTemp)
        }
    }
    
    //#MARK:- Methods
    /*
     Declaration   func getPairedlist()
     
     Description  This method used to get Paired device list
     
     Declared In  BluetoothConnectivityViewController.swift
     */
    func getPairedlist()
    {
        PairedDeciveList = objectBluetoothDevice.getActivityDevices(DeviceName: "AT-500HR")
        if !PairedDeciveList.isEmpty
        {   forSyncBand = false
            bluetoothConnectingView.isHidden = true
            availableDevices.isHidden = false
            tableViewPaireddevices.reloadData()
        }
    }
    /*
     Declaration   func ScanORConnectBand()
     
     Description  This method used to Scan OR Connect Activity Band
     
     Declared In  BluetoothConnectivityViewController.swift
     */
    func ScanORConnectBand()
    {
        self.objectBluetoothDevice.deleteBandDetailsDeviceTable(name:"AT-500HR")
            DispatchQueue.main.asyncAfter(deadline: .now() + 12.0) {
            self.ScanningLbl.isHidden = true
            if !self.peripheralNames.contains("AT-500HR")
            {
                self.forSyncBand = true
                self.enablenavigation = false
                #if !targetEnvironment(simulator)
                LifevitSDKManager.sharedInstance()?.deviceDelegate = self
                LifevitSDKManager.sharedInstance()?.scanAllDevices()
                LifevitSDKManager.sharedInstance()?.braceletDelegate = self
                LifevitSDKManager.sharedInstance()?.braceletAT250Delegate = self
                LifevitSDKManager.sharedInstance()?.connectDevice(DEVICE_BRACELET_AT500HR, withTimeout: 30)
                #endif
            }
        }
    }
    /*
     Declaration   func setActiivtiesSync()
     
     Description  This method used to set Actiivties Sync values
     
     Declared In  BluetoothConnectivityViewController.swift
     */
    func setActiivtiesSync()
    {
        if UserDefaults.standard.value(forKey: "ActivityBandSteps") as? Bool == nil
        {
            UserDefaults.standard.set(true, forKey: "ActivityBandSteps")
            UserDefaults.standard.set(true, forKey: "ActivityBandcalories")
            UserDefaults.standard.set(true, forKey: "ActivityBandDistance")
        }
        if UserDefaults.standard.value(forKey: "ActivityBandHeartRate") as? Bool == nil
        {
            UserDefaults.standard.set(true, forKey: "ActivityBandHeartRate")
        }
    }
    /*
     Declaration   func actionConnect()
     
     Description  This method used to hide other views
     
     Declared In  BluetoothConnectivityViewController.swift
     */
    func actionConnect()
    {
        let currentDateTime = Date()
        let time = currentDateTime.convertToSring(GlobalReusability.DateFormats.hoursMinuteFormat)
        let day = currentDateTime.dayOfWeek()
        lblDateTime.text = day.appendingFormat("  %@ %@",currentDateTime.convertToSring(GlobalReusability.DateFormats.displayDateFormat),time)
        bluetoothConnectingView.isHidden = true
        availableDevices.isHidden = true
        if  UserDefaults.getVitalsName() == menuList.bloodPressure.description{
            viewBPCircle.isHidden = false
            readingView.isHidden = false
        }else  if  UserDefaults.getVitalsName() == menuList.pulseOximeter.description{
            progressPulseOximeter.isHidden = false
            readingView.isHidden = false
        }else  if  UserDefaults.getVitalsName() == menuList.thermometer.description{
            self.saveAnalytics()
            self.navigationController?.pushViewController(VitalsHomeViewController(), animated: false)
        }else  if  UserDefaults.getVitalsName() == menuList.glucoseLevel.description{
            self.saveAnalytics()
             self.navigationController?.pushViewController(VitalsHomeViewController(), animated: false)
        }else  if  UserDefaults.getVitalsName() == menuList.weight.description{
            readingView.isHidden = false
            progressTemp.isHidden = false
            labelDisplayMeasure.text = "lbs"
        }
    }
    /*
     Declaration   func addAnimation()
     
     Description  This method add animation
     
     Declared In  BluetoothConnectivityViewController.swift
     */
    fileprivate func addAnimation(){
        let lay = CAReplicatorLayer()
        lay.frame = CGRect(x: 0, y: 0, width: 50, height: 22)
        let bar = CALayer()
        bar.frame = CGRect(x: 0, y: 0, width: 20, height: 22)
        let myImage = UIImage(named: "md-arrow-right-green")?.cgImage
        bar.contents = myImage
        lay.addSublayer(bar)
        lay.instanceCount = 3
        lay.instanceTransform = CATransform3DMakeTranslation(20, 0, 0)
        let anim = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
        anim.fromValue = 1.0
        anim.toValue = 0.2
        anim.duration = 1
        anim.repeatCount = .infinity
        bar.add(anim, forKey: nil)
        lay.instanceDelay = anim.duration / Double(lay.instanceCount)
        animationView.layer.addSublayer(lay)
    }
    /*
     Declaration  func addDotAnimation(view:UIView)
     
     Description  This method add animation
     
     Declared In  BluetoothConnectivityViewController.swift
     */
    
    fileprivate func addDotAnimation(view:UIView){
        view.subviews.forEach { $0.removeFromSuperview() }
        let lay = CAReplicatorLayer()
        lay.frame = CGRect(x: 0, y: 0, width: 38, height: 6)
        let bar = CALayer()
        bar.frame = CGRect(x: 0, y: 0, width: 6, height: 6)
        bar.backgroundColor = UIColor.white.cgColor
        lay.addSublayer(bar)
        lay.instanceCount = 3
        lay.instanceTransform = CATransform3DMakeTranslation(15, 0, 0)
        let anim = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
        anim.fromValue = 1.0
        anim.toValue = 0.2
        anim.duration = 1
        anim.repeatCount = .infinity
        bar.add(anim, forKey: nil)
        lay.instanceDelay = anim.duration / Double(lay.instanceCount)
        view.layer.addSublayer(lay)
    }
    /*
     Declaration  showErrorMessageAlert(message:String)
     
     Description  This method used to show alert message and navigate back page.
     
     Parameters   message - This param is used to pass error message.
     
     Declared In  BluetoothConnectivityViewController.swift
     */
    func showErrorMessageAlert(message:String)
    {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "YES", style: UIAlertAction.Style.default, handler: {(action:UIAlertAction) in
                self.viewWillAppear(false)
                self.selectedPeripheral = nil
                if let topVC = topViewController() {
                    
                    if topVC is BluetoothConnectivityViewController {
                        // Here your topVC is BluetoothConnectivityViewController
                    }else{
                        self.navigationController?.popViewController(animated: false)
                    }
                }else{
                    self.navigationController?.popViewController(animated: false)
                }
            }))
            alert.addAction(UIAlertAction(title: "NO", style: UIAlertAction.Style.default, handler: {(action:UIAlertAction) in
                self.navigationController?.backToViewController(viewController: MyDailyHealthViewController.self)
            }))
            self.present(alert, animated: false, completion: nil)
        }
    }
    /*
     Declaration  showErrorMessageAlert(message:String)
     
     Description  This method used to show alert message and navigate back page.
     
     Parameters   message - This param is used to pass error message.
     
     Declared In  BluetoothConnectivityViewController.swift
     */
    func showUnpairAlert(message:String)
    {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "YES", style: UIAlertAction.Style.default, handler: {(action:UIAlertAction) in
                self.objectBluetoothDevice.deleteQueryForBluetoothDeviceTable(ID: self.peripheralID)
                self.isAlert = false
                self.openSettings("Bluetooth")
                self.PairedDeciveList = self.objectBluetoothDevice.getActivityDevices(DeviceName: "AT-500HR")
                self.objectBluetooth.scanBluetoothDevice()
                self.ScanningLbl.isHidden = false
                self.ScanORConnectBand()
                self.tableViewPaireddevices.reloadData()
            }))
            alert.addAction(UIAlertAction(title: "NO", style: UIAlertAction.Style.default, handler: {(action:UIAlertAction) in
            }))
            self.present(alert, animated: false, completion: nil)
        }
    }
    
    /*
     Declaration    saveAddAnalytics()
     
     Description    This method used to save Add Analytics values
     
     Declared In     callUIViewController.swift
     */
    func saveAnalytics(type:Constants.Operation = .View)
    {
        Constants.Analytics.Operation = type
        CodeReusability().saveAnalyticsforPatient()
    }
    /*
     Declaration  openSettings(preferenceType:String)
     
     Description  This method used to open the device settings
     
     Declared In  BluetoothConnectivityViewController.swift
     */
    func openSettings(_ preferenceType: String) {
        let preferencePath = "App-Prefs:root"
        let appPath = "\(preferencePath)=\(preferenceType)"
        if let url = URL(string: appPath) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        } else { }
    }
    /*
     Declaration  func intialSetupProgress()
     
     Description  This method used intial setup  for circular progress
     
     Declared In  BluetoothConnectivityViewController.swift
     */
    
    fileprivate func intialSetupProgress(){
        progressSysReading.startAngle = 90
        progressSysReading.progressThickness = 0.45
        progressSysReading.trackThickness = 0.45
        progressSysReading.clockwise = true
        progressSysReading.roundedCorners = true
        progressSysReading.glowMode = .noGlow
        progressSysReading.trackColor = .lightDarkColor
        progressSysReading.set(colors:  .systolicColor)
       
        progressDiaReading.startAngle = 90
        progressDiaReading.progressThickness = 0.45
        progressDiaReading.trackThickness = 0.45
        progressDiaReading.clockwise = true
        progressDiaReading.roundedCorners = true
        progressDiaReading.glowMode = .noGlow
        progressDiaReading.trackColor = .lightDarkColor
        progressDiaReading.set(colors:  .diastolicColor)
       
        progressPulseReading.startAngle = 90
        progressPulseReading.progressThickness = 0.45
        progressPulseReading.trackThickness = 0.45
        progressPulseReading.clockwise = true
        progressPulseReading.gradientRotateSpeed = 2
        progressPulseReading.roundedCorners = true
        progressPulseReading.glowMode = .noGlow
        progressPulseReading.trackColor = .lightDarkColor
        progressPulseReading.set(colors:  .pinkColor)
    
        progressPulseOximeter.startAngle = 90
        progressPulseOximeter.progressThickness = 0.3
        progressPulseOximeter.trackThickness = 0.3
        progressPulseOximeter.clockwise = true
        progressPulseOximeter.gradientRotateSpeed = 2
        progressPulseOximeter.roundedCorners = true
        progressPulseOximeter.glowMode = .noGlow
        progressPulseOximeter.trackColor = .darkGreenColor
        progressPulseOximeter.set(colors:  .green)
        
        progressTemp.startAngle = 90
        progressTemp.progressThickness = 0.3
        progressTemp.trackThickness = 0.3
        progressTemp.clockwise = true
        progressTemp.gradientRotateSpeed = 2
        progressTemp.roundedCorners = true
        progressTemp.glowMode = .noGlow
        progressTemp.trackColor = .darkGreenColor
        progressTemp.set(colors:  .green)
        
    }
    /*
     Declaration  SwipeGuestureAction(_ sender: AnyObject)
     
     Description  This method used to swipe page
     
     Parameters   sender - It is default param for UISwipeGuesture
     
     Declared In  BluetoothConnectivityViewController.swift
     */
    
    @IBAction func SwipeGuestureAction(_ sender: AnyObject) {
         if selectedPeripheral == nil{
             self.saveAnalytics()
             objectBluetooth.cancelPheriPeralConnection()
        #if !targetEnvironment(simulator)
        if (LifevitSDKManager.sharedInstance()?.isDeviceConnected(DEVICE_HEART))!{
                LifevitSDKManager.sharedInstance()?.disconnectDevice(DEVICE_HEART)
            }
            if (LifevitSDKManager.sharedInstance()?.isDeviceConnected(DEVICE_WEIGHT_SCALE))!{
                LifevitSDKManager.sharedInstance()?.disconnectDevice(DEVICE_WEIGHT_SCALE)
            }
            if (LifevitSDKManager.sharedInstance()?.isDeviceConnected(DEVICE_BRACELET_AT500HR))!{
                //LifevitSDKManager.sharedInstance()?.disconnectDevice(DEVICE_BRACELET_AT500HR)
            }
            if (LifevitSDKManager.sharedInstance()?.isDeviceConnected(DEVICE_OXIMETER))!{
                LifevitSDKManager.sharedInstance()?.disconnectDevice(DEVICE_OXIMETER)
            }
            #endif
            _ = self.navigationController?.popViewController(animated: false)
        }
    }
    /*
     Declaration  convertUTCDateToUTCStringdate(dateToConvert:Date) -> String
     
     Description  This method used to convert utc date to UTC string
     
     Parameters   dateToConvert - It is default param for pass date
     
     Declared In  BluetoothConnectivityViewController.swift
     */
    func convertUTCDateToUTCStringdate(dateToConvert:Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = GlobalReusability.DateFormats.LocalDBDateFormat
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter.string(from: dateToConvert)
    }
    /*
     Declaration  convertUTCDateToUTCString(dateToConvert:Date) -> String
     
     Description  This method used to convert utc date to UTC  date string

     Parameters   dateToConvert - It is default param for pass date
     
     Declared In  BluetoothConnectivityViewController.swift
     */
    func convertUTCDateToUTCString(dateToConvert:Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = GlobalReusability.DateFormats.LocalDBDateTimeFormat
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter.string(from: dateToConvert)
    }
    /*
     Declaration  didScanDevice(notify:Notification)
     
     Description  This method used to scan bluetooth device are connect
     
     Parameters   notify - It is default param for NotificationCenter
     
     Declared In  BluetoothConnectivityViewController.swift
     */
    @objc func didScanDevice(notify:Notification){
        let p: CBPeripheral = notify.userInfo?["peripheral"] as! CBPeripheral
         if p.name != nil {
            bluetoothConnectingView.isHidden = true
            availableDevices.isHidden = false
        if  peripheralNames.insert(p.name ?? "").inserted{
                peripherals.append(p)
                tableViewPheripherals.reloadData()
        }
      }
    }
    func showSleepAlert(message:String)
    {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "YES", style: UIAlertAction.Style.default, handler: {(action:UIAlertAction) in
                self.navigationController?.pushViewController(DevicesHomeViewController(), animated: true)
            }))
            alert.addAction(UIAlertAction(title: "NO", style: UIAlertAction.Style.default, handler: {(action:UIAlertAction) in
            }))
            self.present(alert, animated: false, completion: nil)
        }
    }
    /*
     Declaration  insertTable(vital:String,vitalPram:String,date:String,uuid:String,value:Double)
     
     Description  This method used to save vitals values in MDvitals and MDVitalsDetails table.
     
     Parameters   vital - This param used to pass vital name
     vitalPram - This param used to pass vitalPram name
     date - This param used to pass date
     uuid - This param used to pass id
     value - This param used to pass vital value
     
     Declared In  BluetoothConnectivityViewController.swift
     */
    func insertTable(vital:String,vitalPram:String,date:String,uuid:String,value:Double){
        
        let vitalId = UUID().uuidString
        self.objectVitals.insertToMDVitals(id: vitalId, vital: vital, createdDate: date, notes:Constants.defaultValues.defaultNote, moodName:"", share: Constants.defaultValues.defaultShare, DataType: Constants.DataType.Device.rawValue, sync: Constants.defaultValues.defaultSync, active: Constants.defaultValues.defaultActive, sourceName: peripheralname)
    
        var moduleId = Int()
        if vital == "BloodPressure" { moduleId = 1 }
        else if vital == "PulseOximeter" { moduleId = 2 }
        else if vital == "Scale" { moduleId = 3 }
        else if vital == "Thermometer" { moduleId = 4 }
        else if vital == "GlucoseMeter" { moduleId = 5 }
        else{  }
        MDLocations().insertValuesToLocationsTable(sDate: date, moduleID: moduleId, sourceID: vitalId, sync: false, isAdded: true, active: true)
        self.objectVitalsDetails.insertToMDVitalsDetails(vitalsParam: vitalPram, vitalsValue: value, createdDate: date,healthkitID:"2b109", vitalParamIDKey: 0, vitalsMasterName: vital)
            self.objectMDVitalsDeviceInfo.insertToMDVitalsDeviceInfo(id: vitalId, deviceID: peripheralID, deviceName: peripheralname)
        UserDefaults.setVitalsArrayForDashBoard(value:MDVitals().getDisplayVitalValues())
    }
}

//CallBack method for primary header

extension BluetoothConnectivityViewController:PHProtocol{
    func actionsINPHProtocol(identify: String) {
        if selectedPeripheral == nil{
            if identify == "Settings"{
                 self.saveAnalytics()
                self.navigationController?.pushViewController(SettingsHomeViewController(), animated: true)
            }else if identify == "Back"{
                 self.saveAnalytics()
                self.navigationController?.popViewController(animated: true)
            }else if identify == "Home"{
                 self.saveAnalytics()
                self.navigationController?.pushViewController(HomeViewController(), animated: false)
            }
        }
    }
}

//CallBack method for Secondary header

extension BluetoothConnectivityViewController:SHProtocol {
    func actionsSHProtocol(identify: String) {
        if identify == "ProfileImage" && selectedPeripheral == nil {
             self.saveAnalytics()
            self.navigationController?.pushViewController(ChangeProfileViewController(), animated: true)
        }
    }
}

extension BluetoothConnectivityViewController:bluetoothDelegate{
    func getNearbyBluetoothDevicelist(_ peripheral:CBPeripheral) {
       if peripheral.name != nil {
         bluetoothConnectingView.isHidden = true
           availableDevices.isHidden = false
            if  peripheralNames.insert(peripheral.name ?? "").inserted{
                /* let peripheralid = peripheral.identifier.uuidString
                 if !PairedDeciveListID.contains(peripheralid)
                 {
                 peripherals.append(peripheral)
                 tableViewPheripherals.reloadData()
                 }*/
                if peripheral.name != "AT-500HR"
                {
                    peripherals.append(peripheral)
                    tableViewPheripherals.reloadData()
                }else
                {
                  if PairedDeciveList.isEmpty
                  {
                    ScanningLbl.isHidden = true
                    peripherals.append(peripheral)
                    tableViewPheripherals.reloadData()
                  }
                }
            }
        }
    }
    
    func  bluetoothResponse(value1:Double,value2:Double,value3:Double){
         if  UserDefaults.getVitalsName() == menuList.bloodPressure.description{
        viewDotAnimationDia.isHidden = true
        let diaValue = value2 > 80 ? 80 : value2
        progressDiaReading.animate(toAngle: (360 * (diaValue/80)), duration:0.5, completion: nil)
        lblReadingDia.text = String(value2)
         }else  if  UserDefaults.getVitalsName() == menuList.pulseOximeter.description{
            lblPOSPO2.text = String(value1)
            lblPOPulse.text = String(value2)
            lblPOPI.text = String(value3)
            let spo2Value = value1 > 100 ? 100 : value1
            progressPulseOximeter.animate(toAngle: (360 * (spo2Value/100)), duration:0.5, completion: nil)
            
         }else  if  UserDefaults.getVitalsName() == menuList.thermometer.description{
            
         }else  if  UserDefaults.getVitalsName() == menuList.glucoseLevel.description{
            
         }else  if  UserDefaults.getVitalsName() == menuList.weight.description{
            
        }
    }
    func disconnectBand()
    {
        #if !targetEnvironment(simulator)
        let isConnect = LifevitSDKManager.sharedInstance()?.isDeviceConnected(DEVICE_BRACELET_AT500HR) ?? false
        if isConnect{
        LifevitSDKManager.sharedInstance()?.disconnectDevice(DEVICE_BRACELET_AT500HR)
        }
        #endif
    }
    //After complete 
    func afterCompletion() {
         objectBluetooth.cancelPheriPeralConnection()
         if  UserDefaults.getVitalsName() == menuList.bloodPressure.description{
            self.saveAnalytics(type: .Add)
             self.navigationController?.pushViewController(BloodPressureHomeViewController(), animated: false)
        }else  if  UserDefaults.getVitalsName() == menuList.pulseOximeter.description{
            self.saveAnalytics(type: .Add)
             self.navigationController?.pushViewController(PulseOximeterHomeViewController(), animated: false)
        } else  if  UserDefaults.getVitalsName() == menuList.weight.description{
            self.saveAnalytics(type: .Add)
             self.navigationController?.pushViewController(VitalsHomeViewController(), animated: false)
        }
     }
}

extension BluetoothConnectivityViewController : CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("powered on")
        case .poweredOff:
            print("powered off")
            //showErrorMessage(message: "Trun on Bluetooth")
            self.showErrorMessageAlert(message:"Trun on Bluetooth")
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
// show Error message for device readings
extension BluetoothConnectivityViewController : delegateBluetoothAlert, DelegateHealthGoal{
    func callHealthGoalOptionsInCell(options: String, intTag: Int) {
        if options ==  "Start"{
            didSelectAction(tableView: tableViewPheripherals, indexPath: IndexPath.init(row: intTag, section: 0))
        }
    }
    
    func callBlutoothErrorMessage(error: String) {
        self.showErrorMessageAlert(message: error)
    }
}

extension BluetoothConnectivityViewController:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tableViewPheripherals{
            if tableViewPaireddevices.isHidden{
                peripheralheightconstraint.constant = CGFloat(peripherals.count * 115)
            }else{
                var height = CGFloat()
                let count = peripherals.count
                if count != 0{
                    for dic in peripherals{
                        let name = dic.name ?? ""
                        if name == "AT-500HR" {
                           height = 40
                        }
                    }
                }
                peripheralheightconstraint.constant = CGFloat(count * 75) + height
            }
            scrollviewheight.constant = CGFloat(peripherals.count * 75) + 1500
            return peripherals.count
        }else if tableView == tableViewPaireddevices{
            Pairedheightconstraint.constant = CGFloat(PairedDeciveList.count * 75)
            return PairedDeciveList.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tableViewPheripherals{
            let cell = tableView.dequeueReusableCell(withIdentifier: String.init(describing: BluetoothConnectivityTableViewCell.self), for: indexPath) as! BluetoothConnectivityTableViewCell
            cell.startButton.isHidden = true
            cell.nameLabel.text  = peripherals[indexPath.row].name ?? ""
            cell.nameLabel.font = UIFont.boldSystemFont(ofSize: 25)
            if deviceName.contains(peripherals[indexPath.row].name ?? "") {
                cell.nameLabel.textColor = UIColor.white
                cell.startButton.isHidden = false
            }else if peripherals[indexPath.row].name ?? "" == "S5-2366" {
                cell.nameLabel.textColor = UIColor.gray//UIColor.white
                cell.startButton.isHidden = true
            }else {
                cell.nameLabel.textColor = UIColor.gray
                cell.startButton.isHidden = true
            }
            cell.delegate = self
            cell.tag = indexPath.row
            cell.startButton.backgroundColor = UIColor.init(red: 12/255.0, green: 64/255.0, blue: 120/255.0, alpha: 1.0)
            cell.startButton.setTitleColor(UIColor.init(red: 248/255.0, green: 222/255.0, blue: 0, alpha: 1.0), for: .normal)
            cell.backgroundColor = UIColor.darkColor
            cell.selectionStyle = .none
            tableView.separatorColor = UIColor(red: 18/255.0, green: 98/255.0, blue: 150/255.0, alpha: 1.0)
            return cell
        }else{
            let cell =  UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "Cell")
            let name = PairedDeciveList[indexPath.row]["DeviceName"]?.asString() ?? ""
            cell.textLabel?.textColor = UIColor.gray
            if deviceName.contains(name){
                cell.textLabel?.textColor = UIColor.white
            }
            cell.textLabel?.text  = name
            cell.backgroundColor = UIColor.darkColor
            cell.selectionStyle = .none
            tableView.separatorColor = UIColor(red: 18/255.0, green: 98/255.0, blue: 150/255.0, alpha: 1.0)
            return cell
        }
    }
}
// when click device name in the list ,app will connect peripheral
extension BluetoothConnectivityViewController:UITableViewDelegate{
  
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func didSelectAction(tableView:UITableView, indexPath:IndexPath){
        if let cell = tableView.cellForRow(at: indexPath) as? BluetoothConnectivityTableViewCell{
            cell.startButton.backgroundColor = UIColor.init(red: 1/255.0, green: 243/255.0, blue: 255, alpha: 1.0)
            cell.startButton.setTitleColor(UIColor.init(red: 12/255.0, green: 64/255.0, blue: 120/255.0, alpha: 1.0), for: .normal)
        }
        if  deviceName.contains(peripherals[indexPath.row].name ?? "")  {
            isNotPaired = true
            selectedPeripheral = peripherals[indexPath.row]
            peripheralname = peripherals[indexPath.row].name ?? ""
            peripheralID =  peripherals[indexPath.row].identifier.uuidString
            objectBluetooth.stopScanning()
            actionConnect()
            //If BP device is from LifeVit, call below method
            if peripherals[indexPath.row].name ?? "" == "eBlood-Pressure"{
                // Check if LifeVit BP device is connected. If not , initiate connection
                #if !targetEnvironment(simulator)
                self.disconnectBand()
                if !(LifevitSDKManager.sharedInstance()?.isDeviceConnected(DEVICE_HEART))!{
                    LifevitSDKManager.sharedInstance()?.connectDevice(DEVICE_HEART, withTimeout: 30)
                }
                #endif
            }else if peripherals[indexPath.row].name ?? "" == "Chipsea-BLE"{
                self.disconnectBand()
                #if !targetEnvironment(simulator)
                if !(LifevitSDKManager.sharedInstance()?.isDeviceConnected(DEVICE_WEIGHT_SCALE))!{
                    LifevitSDKManager.sharedInstance()?.connect(byUUID: peripherals[indexPath.row].identifier.uuidString, withType: DEVICE_WEIGHT_SCALE)
                    LifevitSDKManager.sharedInstance()?.connectDevice(DEVICE_WEIGHT_SCALE, withTimeout: 30)
                }
                #endif
            }else if peripherals[indexPath.row].name ?? "" == "BLE-Glucose"{
                objectBluetooth.connect(peripherals[indexPath.row])
            }else if peripherals[indexPath.row].name ?? "" == "AT-500HR"{
                #if !targetEnvironment(simulator)
                if !(LifevitSDKManager.sharedInstance()?.isDeviceConnected(DEVICE_BRACELET_AT500HR))!{
                    self.enablenavigation = true
                    pleaseWaitLabel.isHidden = false
                    self.isAlert = true
                    pleaseWaitLabel.text = "Connecting..."
                    LifevitSDKManager.sharedInstance()?.connectDevice(DEVICE_BRACELET_AT500HR, withTimeout: 30)
                }
                #endif
            }else if peripherals[indexPath.row].name ?? "" == "BLT_M70C"{
                self.disconnectBand()
                #if !targetEnvironment(simulator)
                if !(LifevitSDKManager.sharedInstance()?.isDeviceConnected(DEVICE_OXIMETER))!{
                    LifevitSDKManager.sharedInstance()?.connectDevice(DEVICE_OXIMETER, withTimeout: 30)
                }
                #endif
            }else {
                //Code to call peripherals with protocols defined explicitly
                objectBluetooth.deviceName = peripherals[indexPath.row].name ?? ""
                objectBluetooth.connect(peripherals[indexPath.row])
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == tableViewPheripherals{
            didSelectAction(tableView: tableView, indexPath: indexPath)
        }else{
            peripheralname = PairedDeciveList[indexPath.row]["DeviceName"]?.asString() ?? ""
            peripheralID =  PairedDeciveList[indexPath.row]["ID"]?.asString() ?? ""
            if peripheralname == "AT-500HR"
            {
           showUnpairAlert(message: "Do you want to unpair this device?")
            }
        }
    }
}
#if !targetEnvironment(simulator)
extension BluetoothConnectivityViewController:LifevitDeviceDelegate{
    func device(_ device: Int32, onConnectionChanged status: Int32) {
        DispatchQueue.main.async {
            switch(status){
            case STATUS_CONNECTED:
                print("STATUS_CONNECTED")
                
                if self.forSyncBand {
                    let isWatchNotPaired = MDBluetoothDevice().getInfo(DeviceName: "Apple Watch")
                    let isNotHaveBandValues = MDBluetoothDevice().getInfo(DeviceName: "AT-500HR" )
                    if isNotHaveBandValues && isWatchNotPaired
                    {
                        self.objectBluetoothDevice.insertIntoTable(ID: "5", DeviceName: "AT-500HR" , DeviceType: "ActivityBand")
                        UserDefaults.standard.set(true, forKey: "SleepDataFromActivityBand")
                        Constants.staticValues.StaticdeviceName = "AT-500HR"
                    }
                self.getPairedlist()
                self.enablenavigation = false
                    LifevitSDKManager.sharedInstance()?.configureBraceletDate(Date())
                    LifevitSDKManager.sharedInstance()?.getBraceletCurrentSteps()
                }else{
              if  UserDefaults.getVitalsName() == "activityTracker" ||  UserDefaults.getVitalsName() == "Sleep"{
                LifevitSDKManager.sharedInstance()?.configureBraceletDate(Date())
                LifevitSDKManager.sharedInstance()?.getBraceletCurrentSteps()
                 let isWatchNotPaired = MDBluetoothDevice().getInfo(DeviceName: "Apple Watch")
                 let isWatchDataEnabled = UserDefaults.standard.value(forKey: "SleepDataFromAppleWatch") as? Bool ?? false
                 let isNotHaveBandValues = MDBluetoothDevice().getInfo(DeviceName: "AT-500HR" )
                 if isNotHaveBandValues && isWatchNotPaired
                 {
                    self.objectBluetoothDevice.insertIntoTable(ID: "2", DeviceName: "AT-500HR" , DeviceType: "ActivityBand")
                    UserDefaults.standard.set(true, forKey: "SleepDataFromActivityBand")
                    Constants.staticValues.StaticdeviceName = "AT-500HR"
                 }
                
                 if !isWatchNotPaired && isWatchDataEnabled && isNotHaveBandValues
                 {
                  LifevitSDKManager.sharedInstance()?.disconnectDevice(DEVICE_BRACELET_AT500HR)
                  self.objectBluetoothDevice.insertIntoTable(ID: "1", DeviceName: "AT-500HR" , DeviceType: "ActivityBand")
                  self.showSleepAlert(message: " You already taking sleep values from Apple Watch. Do you want Sleep values from AT-500HR go to device settings and change your device ")
                 return
                 }
                if self.isHeartrateScreen
                {
                    self.enablenavigation = false
                    LifevitSDKManager.sharedInstance()?.getBraceletHeartBeat()
                }
               self.pleaseWaitLabel.text = "Reading Data"
                
                let isConnect = LifevitSDKManager.sharedInstance()?.isDeviceConnected(DEVICE_BRACELET_AT500HR) ?? false
                if isConnect{
                    UserDefaults.setActivityBandPaired(value: true)
                  } }
                 }
                
               
            case STATUS_DISCONNECTED:
                print("STATUS_DISCONNECTED")
                if self.isAlert{
                    self.selectedPeripheral = nil
                    self.showErrorMessageAlert(message:"Device is disconnected. Do you want to scan again")
                }
                if self.isHeartRate{
                    LifevitSDKManager.sharedInstance()?.deviceDelegate = self
                    LifevitSDKManager.sharedInstance()?.heartDelegate = self
                    LifevitSDKManager.sharedInstance()?.weightscaleDelegate = self
                    LifevitSDKManager.sharedInstance()?.braceletAT250Delegate = self
                    LifevitSDKManager.sharedInstance()?.braceletDelegate = self
                    LifevitSDKManager.sharedInstance()?.devicesScanDelegate = self
                    LifevitSDKManager.sharedInstance()?.oximeterDelegate = self
                    LifevitSDKManager.sharedInstance()?.scanAllDevices()
                    LifevitSDKManager.sharedInstance()?.isBraceletInActivity()
                    LifevitSDKManager.sharedInstance()?.isTensioBraceletMeasuring()
                }
            case STATUS_SCANNING:
                print("STATUS_SCANNING")
            case STATUS_CONNECTING:
                print("STATUS_CONNECTING")
            default:
                print("Not_Connecting")
            }
        }
    }
    
    func device(_ device: Int32, onConnectionError error: Int32) {
        DispatchQueue.main.async {
            print("on result error:",error)
            self.showErrorMessageAlert(message: "Unknown error")
        }
    }
    
    @IBAction func actionOK(_ sender:UIButton){
         self.navigationController?.popViewController(animated: false)
    }
}

extension BluetoothConnectivityViewController:LifevitHeartDelegate {
     // BP reading in progress
    func heartDevice(onProgressMeasurement pulse: Int32) {
        viewDotAnimationDia.isHidden = true
        let diaValue = Double(pulse) > 80 ? 80 : Double(pulse)
        progressDiaReading.animate(toAngle: (360 * (diaValue/80)), duration:0.5, completion: nil)
        lblReadingDia.text = String(Int(pulse))
    }

    // BP reading completion
    func heartDevice(onResult data: LifevitSDKHeartData!)
    {
        if data.systolic == nil{
            DispatchQueue.main.async(execute: {
                if self.isAlert{
                    switch data.errorCode.int32Value {
                    case CODE_UNKNOWN:
                        self.showErrorMessageAlert(message: "Unknown error")
                        self.isAlert = false
                    case CODE_LOW_SIGNAL:
                        self.showErrorMessageAlert(message: "Low communication signal with the device")
                        self.isAlert = false
                    case CODE_NOISE:
                        self.showErrorMessageAlert(message: "Interference in communication")
                        self.isAlert = false
                    case CODE_INFLATION_TIME:
                        self.showErrorMessageAlert(message: "The maximum inflation time has been exceeded")
                        self.isAlert = false
                    case CODE_ABNORMAL_RESULT:
                        self.showErrorMessageAlert(message: "An abnormal result has been received. The measurement has to be repeated")
                        self.isAlert = false
                    case CODE_RETRY:
                        self.showErrorMessageAlert(message: "The measurement has to be repeated")
                        self.isAlert = false
                    case CODE_LOW_BATTERY:
                        self.showErrorMessageAlert(message: "Low device battery")
                        self.isAlert = false
                    default:
                        self.showErrorMessageAlert(message: "Unknown error")
                        self.isAlert = false
                        
                    }
                    LifevitSDKManager.sharedInstance()?.disconnectDevice(DEVICE_HEART)
                    
                }
            })

        }else{
        let date = Date().convertToSring(GlobalReusability.DateFormats.LocalDBDateTimeFormat)
            BluetoothDevice.insertBluetoothDeviceInTable(periperal: self.selectedPeripheral!, DeviceType: "BloodPressure")
          if !self.objectMedicineDosage.existMedicationDosageTable().isEmpty {
            self.objectMedicineDosage.getDosageIdFromMDMedicineDosage(sDate: date,vitalsName:"BloodPressure")
        }
        self.saveAnalytics(type: .Add)
        self.insertTable(vital: Constants.Vitals.BloodPressure.rawValue, vitalPram: Constants.VitalsParams.Systolic.rawValue, date: date, uuid: "BPSystolic", value: Double(truncating: data.systolic))
        
        self.insertTable(vital: Constants.Vitals.BloodPressure.rawValue, vitalPram: Constants.VitalsParams.Diastolic.rawValue, date: date, uuid: "BPDiastolic", value: Double(truncating: data.diastolic))
        
        self.insertTable(vital: Constants.Vitals.BloodPressure.rawValue, vitalPram: Constants.VitalsParams.Pulse.rawValue, date: date, uuid: "BPPulse", value: Double(truncating: data.pulse))
        if !self.objectMedicineDosage.existMedicationDosageTable().isEmpty {
             self.objectMedicineDosage.getDosageIdFromMDMedicineDosage(sDate: date,vitalsName:"BloodPressure")
          }
        self.objectVitalsAPI.callPOSTAPIURLForVitals()
         self.isAlert = false
        //Syntax to disconnect device
        LifevitSDKManager.sharedInstance()?.disconnectDevice(DEVICE_HEART)
        self.navigationController?.pushViewController(BloodPressureHomeViewController(), animated: false)
        }
    }
}

extension BluetoothConnectivityViewController:LifevitWeightScaleDelegate{
    //Scale reading in progress
    func weightscale(onMeasurementResult data: LifevitSDKWeightScaleData!){
        viewDotAnimationTemp.isHidden = true
        let poundsValue = Double(truncating: data.weight) * (2.20462)
        let scaleValue = poundsValue > 80 ? 80 : poundsValue
        progressTemp.animate(toAngle: (360 * (scaleValue/100)), duration:0.5, completion: nil)
        lblReadingVitals.text = String(format:"%.1f",poundsValue)
    }
    //Scale reading completion
    func weightscale(onResult data: LifevitSDKWeightScaleData!) {
        let date = Date().convertToSring(GlobalReusability.DateFormats.LocalDBDateTimeFormat)
        let poundsValue = Double(truncating: data.weight) * (2.20462)
        self.saveAnalytics(type: .Add)
        BluetoothDevice.insertBluetoothDeviceInTable(periperal: self.selectedPeripheral!, DeviceType: "Scale")
        self.insertTable(vital: Constants.Vitals.Scale.rawValue, vitalPram: Constants.VitalsParams.Weight.rawValue, date: date, uuid: "ScaleDevice", value: poundsValue)

        self.objectVitalsAPI.callPOSTAPIURLForVitals()
        self.isAlert = false
        //Syntax to disconnect device
        LifevitSDKManager.sharedInstance()?.disconnectDevice(DEVICE_WEIGHT_SCALE)
        self.navigationController?.pushViewController(VitalsHomeViewController(), animated: false)
    
    }
    
    
}

extension BluetoothConnectivityViewController:LifevitBraceletAT250Delegate{
    func braceletSyncReceived(_ data: LifevitSDKBraceletData!) {
        print("Sleep count",data.sleepData.count)
        var dateArray = [String]()
        let v1 = data.sleepData.count
        let isSleepData = UserDefaults.standard.value(forKey: "SleepDataFromActivityBand") as? Bool ?? false
        var PutDateArray = [String]()
        var PutIDArray = [String]()
        for i in 0..<v1 {
            let vals = data.sleepData.object(at: i) as? LifevitSDKSleepData
            let sleepDuration = vals?.sleepDuration as! Int
            let sleepDeepness = vals?.sleepDeepness as! Int
            
            // Sleep deepness 0 -->2  ||  1 --> 1
            let Depnessval = sleepDeepness == 0 ? 2 : sleepDeepness
            let date = vals?.date ?? Date()
            let convertedLocalDate = convertUTCDateToUTCStringdate(dateToConvert: date)
            var localSdate = convertUTCDateToUTCString(dateToConvert: date)
            let convertedEDate = date.addingTimeInterval( TimeInterval(sleepDuration * 60))
            var localEndDate = convertUTCDateToUTCString(dateToConvert: convertedEDate)
            
            if localSdate.contains("00:00:00"){
                let date = localSdate.replacingOccurrences(of: "00:00:00", with: "00:00:01")
                localSdate = date
              }
 
            if localEndDate.contains("00:00:00"){
                let date = localSdate.substring(start: 0, offsetBy: 11) ?? "2019-03-14 "
                let time = "23:59:59"
                localEndDate = date + time
            }

            
            var SleepID = UUID().uuidString
            let SleepDetailsID = UUID().uuidString
            if  let rowID = self.objectSleep.getSleepIDbyDate(date:localSdate)
            {
                SleepID = rowID
                if !PutDateArray.contains(convertedLocalDate)
                    {
                    PutDateArray.append(convertedLocalDate)
                    PutIDArray.append(SleepID)
                    }
            }else{
                if isSleepData {
                MDLocations().insertValuesToLocationsTable(sDate: Date().getDBformat(), moduleID: Constants.MydaydaMasterID.Sleep.rawValue, sourceID: SleepID, sync: false, isAdded: false, active: true)
                let bedValues = "('\(SleepID)','\(convertedLocalDate)','\(0)','\(false.intValue)','\(1)')"
                self.objectSleep.insertToSleep(SleepValues:bedValues)
                MDLocations().insertValuesToLocationsTable(sDate: Date().getDBformat(), moduleID: Constants.MydaydaMasterID.Sleep.rawValue, sourceID: SleepID, sync: false, isAdded: true, active: true)
                }
            }

            let allsleepvalues = "('\(SleepDetailsID)','\(SleepID)','\(localSdate)','\(localEndDate)','\(UUID().uuidString)','\("Asleep")','\(Depnessval)','\(peripheralname)','\(peripheralID)')"
            if !dateArray.contains(localSdate)
            {
                if isSleepData {
                    self.objectSleepDetails.insertToSleepDetailsTable(asleepValues: allsleepvalues) }
            dateArray.append(localSdate)
            }
            if i == v1 - 1 {
                self.pleaseWaitLabel.isHidden = true
                if enablenavigation{
                    self.navigationController?.popViewController(animated: false) }
            }
        }
       self.objectSleep.getLatestSleepValuesOndashboard()
     let (_,_) =  self.objectSleep.getSleepLatestValues()

      //  LifevitSDKManager.sharedInstance()?.configureBraceletACNS(self.ArrayAlerts)
        if v1 == 0
        {
            self.pleaseWaitLabel.isHidden = true
            if enablenavigation{
                self.navigationController?.popViewController(animated: false) }
        }
        self.saveAnalytics(type: .Add)
        self.objectSleepApi.callPOSTAPIURLForSleep()
        self.objectSleepApi.callPUTMethodForSleep(vals:PutDateArray,ids: PutIDArray)
        self.setActiivtiesSync()
    }
    
    func braceletCurrentStepsReceived(_ data: LifevitSDKStepData!) {
        if isNotPaired{
            BluetoothDevice.insertBluetoothDeviceInTable(periperal: self.selectedPeripheral!, DeviceType: "ActivityBand")
            UserDefaults.setActivityBandPaired(value: true)
        }
        let date =  Date().getDBformat()
        let distance = data.distance.doubleValue * 0.621371
        let strDistance = String(format: "%.2f", distance)
        let stepval = data?.steps
        let calval = data?.calories
        _ = data.date.getDBformat()
        if stepval?.intValue != 0
        {
            let ActivityId = UUID().uuidString
            let distanceUUID = UUID().uuidString
            let caloriesUUID = UUID().uuidString
            let IsStepsData = UserDefaults.standard.value(forKey: "ActivityBandSteps") as? Bool ?? false
            if IsStepsData{
                objectActivityTracker.insertOrUpdateValuesForActivityTable(uuid:ActivityId ,startDate: date , sSteps: stepval?.intValue ?? 0, sMoodID: "", sNote: "", sync: false, share: false, dataType: 1, endDate: date, distance: 0.0, calorie: 0, activity: 40, painLevel: 0, duration: 0.0, rest: 0.0, healthkitID: UUID().uuidString, painArea: 0, isImpact: true, sourceName: peripheralname, createdDate: date, workoutID: 0, active: true, status:"Steps != '0'", deviceID: peripheralID, deviceName: peripheralname)
            }
    
            let IsDistanceData = UserDefaults.standard.value(forKey: "ActivityBandDistance") as? Bool ?? false
            if IsDistanceData{
                objectActivityTracker.insertOrUpdateValuesForActivityTable(uuid:distanceUUID ,startDate: date , sSteps: 0, sMoodID: "", sNote: "", sync: false, share: false, dataType: 1, endDate: date, distance: Double(strDistance) ?? 0, calorie: 0, activity: 41, painLevel: 0, duration: 0.0, rest: 0.0, healthkitID: UUID().uuidString, painArea: 0, isImpact: true, sourceName: peripheralname, createdDate: date, workoutID: 0, active: true, status:"Distance != '0.0'", deviceID: peripheralID, deviceName: peripheralname)
            }
    
            let IsCaloriesData = UserDefaults.standard.value(forKey: "ActivityBandcalories") as? Bool ?? false
            if IsCaloriesData{
                objectActivityTracker.insertOrUpdateValuesForActivityTable(uuid:caloriesUUID ,startDate: date , sSteps: 0, sMoodID: "", sNote: "", sync: false, share: false, dataType: 1, endDate: date, distance: 0.0, calorie: Int(calval?.doubleValue ?? 0), activity: 37, painLevel: 0, duration: 0.0, rest: 0.0, healthkitID: UUID().uuidString, painArea: 0, isImpact: true, sourceName: peripheralname, createdDate: date, workoutID: 0, active: true, status:"Calories != '0'", deviceID: peripheralID, deviceName: peripheralname)
            }
          self.saveAnalytics(type: .Add)
        }
        LifevitSDKManager.sharedInstance()?.synchronizeBraceletHistoryData()
    }
    
    func bracelet(at250HRReceived value: Int32) {
        print("heartRate",value)
    }
    
    func operationFinished(_ success: Bool) {
        if success {
            print("success")
        }else {
             print("failure")
        }
    }
    
    
    
}

extension BluetoothConnectivityViewController: LifevitBraceletDelegate{
    func braceletBeepReceived() {
        print("Beep Received")
    }
    
    func braceletActivityStarted() {
        
    }
    
    
    func braceletActivityFinished() {
       //LifevitSDKManager.sharedInstance()?.getBraceletCurrentSteps()
    }
    
    func braceletBatteryReceived(_ battery: Int32) {
        print("batteryLevel",battery)
    }
    
    func braceletParameterSet(_ parameter: Int32) {
        print("parameter",parameter)
    }
    
    func braceletActivityStepsReceived(_ steps: Int32) {
        print("steps",steps)
    }
  
    func braceletHeartDataReceived(_ data: LifevitSDKHeartBeatData!) {
        DispatchQueue.main.async(execute: {
            let heartVal = data.heartRate.intValue
            let vitalId = UUID().uuidString
            let date = Date().convertToSring(GlobalReusability.DateFormats.LocalDBDateTimeFormat)
            self.objectVitals.insertToMDVitals(id: vitalId, vital: Constants.Vitals.HeartRate.rawValue, createdDate: date, notes:Constants.defaultValues.defaultNote, moodName:"", share: Constants.defaultValues.defaultShare, DataType: Constants.DataType.Device.rawValue, sync: Constants.defaultValues.defaultSync, active: Constants.defaultValues.defaultActive, sourceName: "AT-500HR")
            MDLocations().insertValuesToLocationsTable(sDate: date, moduleID: Constants.MydaydaMasterID.HeartRate.rawValue, sourceID: vitalId, sync: false, isAdded: true, active: true)
            self.objectVitalsDetails.insertToMDVitalsDetailsfroPulse(vitalsParam: Constants.VitalsParams.Pulse.rawValue, vitalsValue: Double(heartVal), createdDate: date,healthkitID:"2b109", vitalParamIDKey: 0, vitalID: vitalId)
            self.saveAnalytics(type: .Add)
            if !self.objectMedicineDosage.existMedicationDosageTable().isEmpty {
                self.objectMedicineDosage.getDosageIdFromMDMedicineDosage(sDate: date,vitalsName:"HeartRate")
            }
            self.objectMDVitalsDeviceInfo.insertToMDVitalsDeviceInfo(id: vitalId, deviceID: self.peripheralID, deviceName: "AT-500HR")
            
               self.objectVitalsAPI.callPOSTAPIURLForVitals()
            self.navigationController?.pushViewController(HeartRateHomeViewController(), animated: false)
        })
        
    }
    
    func braceletInfoReceived(_ info: String!) { }
    
}

extension BluetoothConnectivityViewController:LifevitSDKDevicesScanDelegate{
    func allDevicesDetected(_ devicesList: NSMutableDictionary!) { }
 }

extension BluetoothConnectivityViewController:LifevitOximeterDelegate{
    func oximeterDevice(onProgressMeasurement data: LifevitSDKOximeterData!) {
       // print("Progressdata ---->",data)
    }
    
    func oximeterDevice(onResult data: LifevitSDKOximeterData!) {
        if isNotPaired{
            BluetoothDevice.insertBluetoothDeviceInTable(periperal: self.selectedPeripheral, DeviceType: "Pulse Oximeter")
        }
        let spo2 = Double(truncating: data.sp2)
        let pi = Double(truncating: data.pi)
        let convertedPI =  Double((pi)/10).roundToDecimal(1)
        let pulse = Double(truncating: data.lpm)
        let spo2Value = spo2 > 100 ? 100 : spo2
        if spo2 < 110{
        Spo2array.append(spo2)
        let val = spo2 > 99 ? 99 : spo2
        PIarray.append(convertedPI)
        Pulsearray.append(pulse)
        lblPOSPO2.text = String(val)
        lblPOPulse.text = String(pulse)
        lblPOPI.text = String(convertedPI)
        progressPulseOximeter.animate(toAngle: (360 * (spo2Value/100)), duration:0.5, completion: nil)
        }else{
            if Spo2array.count > 10{
                
                let date = Date().convertToSring(GlobalReusability.DateFormats.LocalDBDateTimeFormat)
                self.saveAnalytics(type: .Add)
                self.insertTable(vital: Constants.Vitals.PulseOximeter.rawValue, vitalPram: Constants.VitalsParams.SPO2.rawValue, date: date, uuid: "PulseSpo2", value: Spo2array[Spo2array.count - 1])
                
                self.insertTable(vital: Constants.Vitals.PulseOximeter.rawValue, vitalPram: Constants.VitalsParams.PerfusionIndex.rawValue, date: date, uuid: "PulsePI", value: PIarray[PIarray.count - 1])
                
                self.insertTable(vital: Constants.Vitals.PulseOximeter.rawValue, vitalPram: Constants.VitalsParams.Pulse.rawValue, date: date, uuid: "Pulse", value: Pulsearray[Pulsearray.count - 1])
                if  let rowID = self.objectMDVitalsDeviceInfo.getLatestRowIDForVitalsTable() {
                    self.objectMDVitalsDeviceInfo.insertToMDVitalsDeviceInfo(id: rowID, deviceID: peripheralID, deviceName: peripheralname)
                if !self.objectMedicineDosage.existMedicationDosageTable().isEmpty {
                      self.objectMedicineDosage.getDosageIdFromMDMedicineDosage(sDate: date,vitalsName:Constants.Vitals.PulseOximeter.rawValue)
                   }
                }
                self.objectVitalsAPI.callPOSTAPIURLForVitals()
         self.isAlert = false
                //Syntax to disconnect device
                LifevitSDKManager.sharedInstance()?.disconnectDevice(DEVICE_OXIMETER)
                self.navigationController?.pushViewController(PulseOximeterHomeViewController(), animated: false)
            }
        }
    }
 }
#endif
 //  Copyright 2018 Mydayda Inc.
