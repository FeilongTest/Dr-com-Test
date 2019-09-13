//
//  ViewController.swift
//  Test-Demo
//
//  Created by 飞龙 on 2019/9/10.
//  Copyright © 2019 飞龙. All rights reserved.
//

import UIKit
import Alamofire
import Toast_Swift



class ViewController: UIViewController {
    @IBOutlet weak var user: UITextField!
    @IBOutlet weak var pass: UITextField!
    
    @IBOutlet weak var balanceLable: UILabel!
    
    let userDefault = UserDefaults.standard
    
    enum User:String {
        case account = "user"
        case pass = "pass"
        
        var stringValue:String {return self.rawValue}
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(get_uuid() != "" || get_pass() != ""){
            print("用户uuid：\(get_uuid())")
            print("用户pass：\(get_pass())")
            user.text = get_uuid()
            pass.text = get_pass()
        }
        // Do any additional setup after loading the view.
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    func get_uuid() -> String{
        let userid = UserDefaults.standard.string(forKey: User.account.rawValue)
        //判断UserDefaults中是否已经存在
        if(userid != nil){
            return userid!
        }else{
            //不存在则返回空
            return ""
        }
    }
    
    func get_pass() -> String{
        let pass = UserDefaults.standard.string(forKey: User.pass.rawValue)
        //判断UserDefaults中是否已经存在
        if(pass != nil){
            return pass!
        }else{
            //不存在则返回空
            return ""
        }
    }
    
    
    @IBAction func logout(_ sender: Any) {
        print("logout")
        //注销成功
        Alamofire.request("http://10.10.10.5/F.htm")
        self.view.makeToast("注销成功")
    }
    
    @IBAction func login(_ sender: Any) {
        
        print("login")
        if(user.text! == "" || pass.text! == ""){
            self.view.makeToast("请先输入账号或者密码！")
            return
        }
        
        let parameters: [String: String] = [
            "DDDDD":user.text!,
            "upass": pass.text!,
            "m1": "000000000000",
            "0MKKey": "0123456789",
            "ver": "1.5.100.201701112.G.L.A.D",
            "sim_sp": "undefine",
            "cver1": "1",
            "cver2": "0010501000",
            "R6": "1"
        ]
        
        let headers: [String: String] = [
            "User-Agent": "DrCOM-HttpClient",
            "Uip": "va5=1.2.3.4.7d90b22d5534741c6057abd51f0317a090824c79"
        ]
        
        
        Alamofire.request("http://10.10.10.5", method: .post, parameters: parameters,  headers: headers)
            .responseString { response in
                //print("Response String: \(String(describing: response.value))")
                let r = String(describing: response.value)
                if(r.contains("<!--Dr.COMWebLoginID_2.htm-->")){
                    print("error")
                    self.view.makeToast("密码错误或者余额不足")
                }else if(r.contains("<!--Dr.COMWebLoginID_3.htm-->")){
                    print("succeed")
                    self.view.makeToast("登陆成功")
                    self.balance()
                    //UserDefaults.setValue(User.account, forKey: self.user.text!)
                    //UserDefaults.setValue(User.pass, forKey: )
                    self.userDefault.set(self.user.text!, forKey: User.account.rawValue)
                    self.userDefault.set(self.pass.text!, forKey: User.pass.rawValue)
                    
                }else{
                    print("unknow")
                    self.view.makeToast("未知错误")
                }
                
        }
        
        




    }

    

    //点击空白处 收起键盘
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        user.resignFirstResponder()
        pass.resignFirstResponder()
        
    }
    
    
    @discardableResult
    func stringmid (wholestring:String,front:String,behind:String)->String
    {
        //wholestring 不能为nil
        if wholestring.isEmpty
        {
            return("")
        }else{
            var whole:NSString=wholestring as NSString
            let frontindex = whole.range(of: front)
            if frontindex.length > 0
            {
                whole = whole.substring(from: frontindex.location + frontindex.length) as NSString
                let behindindex = whole.range(of: behind)
                if behindindex.length > 0
                {
                    whole = whole.substring(to: behindindex.location) as NSString
                    return(whole as String)
                }else {
                    //没有找到behind在wholestring
                    return("")
                }
            } else{
                // 没有找到front 在wholestring
                return("")
            }
        }
    }
    
    func balance(){
        Alamofire.request("http://10.10.10.5")
            .responseString { response in
                print("Response String: \(String(describing: response.value))")
                let balance = self.stringmid(wholestring: String(describing: response.value), front: "fee=\\'", behind: "\\';xsele=0;")
                print(String(Double(balance.trimmingCharacters(in: .whitespaces))!/10000.00)+"元")
                self.balanceLable.text = String(Double(balance.trimmingCharacters(in: .whitespaces))!/10000.00)+"元"
        }
        
    }
    
    

}

