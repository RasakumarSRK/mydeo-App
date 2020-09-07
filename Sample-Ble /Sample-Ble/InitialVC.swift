 
 import UIKit
 import CoreBluetooth
 import MessageUI
 
 class InitialVC: UIViewController {
    @IBOutlet var startScanLbl:UILabel!

    override func viewDidLoad() {
        let Main = CGRect(x: 0.0, y: 271.33333333333326, width: 375.0, height: 151.66666666666669)
        let r1 = CGRect(x: 328.0, y: 350.66666666666674, width: 47.0, height: 89.33333333333331)
        let r2 = CGRect(x: 328.0, y: 440.8888880411784, width: 47.0, height: 89.33333333333331)



        super.viewDidLoad()
        startScanLbl.layer.cornerRadius = 100
        startScanLbl.layer.borderColor = UIColor.white.cgColor
        startScanLbl.layer.borderWidth = 5
    }

    @IBAction func StartScanning(_ sender:UIButton!) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let secondViewController = sb.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        self.navigationController?.pushViewController(secondViewController, animated: false)
    }
 }
