//
//  ViewController.swift
//  fortniteassistant
//
//  Created by AG on 20.01.2021.
// github token ab807b088035741918e479cc3136794c18af9736

import UIKit

class tableViewCell: UITableViewCell {
    @IBOutlet weak var labelCell: UILabel!
    @IBOutlet weak var imageType: UIImageView!
    @IBOutlet weak var labelPower: UILabel!
    @IBOutlet weak var imageGroup: UIImageView!
    @IBOutlet weak var imagePower: UIImageView!
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var label4: UILabel!
    @IBOutlet weak var labelSum: UILabel!
    @IBOutlet weak var viewFilter: UIView!
    @IBOutlet weak var switchZone0: UISwitch!
    @IBOutlet weak var switchZone1: UISwitch!
    @IBOutlet weak var switchZone2: UISwitch!
    @IBOutlet weak var switchZone3: UISwitch!
    @IBOutlet weak var switchCategory0: UISwitch!
    @IBOutlet weak var switchCategory1: UISwitch!
    @IBOutlet weak var switchCategory2: UISwitch!
    @IBOutlet weak var switchCategory3: UISwitch!
    @IBOutlet weak var switchSingle: UISwitch!
    @IBOutlet weak var switchGroup: UISwitch!
    @IBOutlet weak var switchVBucks: UISwitch!
    @IBOutlet weak var switchPerkup: UISwitch!
    @IBOutlet weak var switchEpic: UISwitch!
    @IBOutlet weak var switchLegendary: UISwitch!
    @IBOutlet weak var navigationTitle: UINavigationItem!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    let serverIP: String = "http://fa.z0p.ru:8080/api/v1/missions"
    struct PveMissionsInfo: Codable {
        var version: Int
        var expire: CLong
        var missions: [Mission]
    }
    struct Mission: Codable {
        var categoryId: Int
        var location: Int
        var typeId: Int
        var group: Bool
        var groupMembersCount: Int
        var powerId: Int
        var items: [Item]
    }
    struct Item: Codable {
        var typeId: Int = 0
        var nameId: Int = 0
        var perkup: Bool = false
        var reperk: Bool = false
        var rarId: Int = 0
        var quantity: Int = 0
    }
    struct MissionFlat {
        var locationName: String = ""
        var categoryId: Int = 0
//        var location: Int = 0
        var typeId: Int = 0
        var group: Bool = false
        var groupMembersCount: Int = 0
        var powerId: Int = 0
        var item: Item = Item()
     }
    var btn = UIButton(type: .custom)

    var expire: CLong?
    var zones = [[MissionFlat]()
 //       [MissionFlat](),  // Камнелесье
 //       [MissionFlat](),  // Планкертон
 //       [MissionFlat](),  // Вещая долина
 //       [MissionFlat]()   // Линч Пикс
    ]
    var vbucksSum = [Int](arrayLiteral: 0,0,0,0)
    var filterZones = [Bool](arrayLiteral: true,true,true,true)
    var filterCategories = [Bool](arrayLiteral: true,true,true,true)
    let zonesNames = [String](arrayLiteral: "Камнелесье","Планкертон","Вещая Долина","Линч Пикс")
    func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    var rareVal:[UInt] = [0x5C6BC0,// "rareItem"
                          0x50276b,// "epicItem"
                          0x388E3C,// "uncommonItem"
                          0xFB8C00]// "legendaryItem"
    let button = UIButton(frame: CGRect(x: 150, y: 550, width: 75, height: 75))

 // powerId начинается с 1
    var powerVal: [Int] = [1,3,5,9,15,19,23,28,34,40,46,52,58,64,70,76,82,88,94,100,108,116,124,132,140,160]
  // itemId начинается с 1
    var itemName: [String] = ["item_name_personnelxp","item_name_shortgun","item_name_floor_flamegrill","item_name__schematicxp","item_name_reagent","item_name_sniper","item_name_heroxp","item_name_campaign_event_currency","item_name_vbucks","item_name_mini_reward_liama","item_name_trap","item_name_assault_semiauto","item_name_scythe","item_name_pistol","item_name_spear","item_name_tool","item_name_sword","item_name_worker","item_name_hero","item_name_defender","item_name_floor_health","item_name_club","item_name_assault_lmg","item_name_ranged_assault","item_name_wall_electric","item_name_floor_spikes","item_name_axe","item_name_ceiling_electric","item_name_assault_burst","item_name_reagent_c_t01","item_name_reagent_c_t02","item_name_reagent_c_t03","item_name_reagent_c_t04","item_name_unknown"]
    
    func getItemName(item: Item) -> String {
        if (item.perkup) {
            return NSLocalizedString("item_name_perkup", comment: "")
        }
        if (item.reperk) {
            return NSLocalizedString("item_name_reperk", comment: "")
        }
        if item.nameId>0,
           item.nameId<=itemName.count  { // itemID начинаются от 1
            return NSLocalizedString(itemName[item.nameId], comment: "")
        }
        return "error"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
 //       view.backgroundColor = .red
        tableView.dataSource = self
        tableView.delegate = self
  //      tableView.sectionHeaderHeight = 50
  //      tableView.register(tableViewCell.self, forCellReuseIdentifier: "myCell")
        let leftBar = UIBarButtonItem(title: "Обновить", style: .plain, target: self, action: #selector(touchUpInside))
        // magnifyingglass
        leftBar.image = UIImage(systemName: "arrow.triangle.2.circlepath",withConfiguration: UIImage.SymbolConfiguration(scale: .large))
        navigationTitle.leftBarButtonItem = leftBar
        titleLabel.text = NSLocalizedString("element_vbucks_header", comment: "")
        _ = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(onTimer), userInfo: nil, repeats: true)
        setTitle(newTitle: "dfff")
            btn.frame = CGRect(x: 285, y: 485, width: 80, height: 80)
            btn.setTitle("Filters", for: .normal)
            btn.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
            btn.clipsToBounds = true
            btn.layer.cornerRadius = 40
            btn.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            btn.layer.borderWidth = 3.0
            btn.addTarget(self,action: #selector(onFilter), for: .touchUpInside)
            view.addSubview(btn)
        viewFilter.isHidden = true
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        let upSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))

        leftSwipe.direction = .left
        rightSwipe.direction = .right
        downSwipe.direction = .down
        upSwipe.direction = .up

        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe)
        view.addGestureRecognizer(downSwipe)
        view.addGestureRecognizer(upSwipe)

    }
    
    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
        print("swipe")
        if  viewFilter.isHidden == false {
            viewFilter.isHidden = true
            btn.isHidden = false
        }
    }
    @objc func onFilter() {
        print("onFilter")
        viewFilter.isHidden = false
        btn.isHidden = true
    }
    
    @objc func onTimer() {
        let f = DateFormatter()
        f.dateFormat = "HH:mm:ss"
        if let expire = expire {
        let date = Date(timeIntervalSince1970: TimeInterval(expire) / 1000)
        let dateSinceNow = Date(timeIntervalSinceReferenceDate: date.timeIntervalSinceNow)

            setTitle(newTitle: NSLocalizedString("element_countdown_text",comment: "") + "\n\(f.string(from: dateSinceNow))")
        }
        }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
print("section \(section)")
let label = UILabel()
        if  self.zones[section].indices.contains(0), // isIndexValid
            let locName = self.zones[section][0].locationName as String? {
            label.text = locName
        } else
        {
            label.text = "<>"
        }
 //       if section == 0 {label.text = "Камнелесье"}
 //       if section == 1 {label.text = "Планкертон"}
 //       if section == 2 {label.text = "Вещая Долина"}
 //       if section == 3 {label.text = "Линч Пикс"}

        label.backgroundColor = UIColor.lightGray
        return label
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("zone by section=\(section) count=\(self.zones[section].count)")
        return self.zones[section].count
   }
    func numberOfSections(in tableView: UITableView) -> Int {
        let i = self.zones.count
        print("number of section is \(i)")
        return i
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("add to tableView at section=\(indexPath.section),index=\(indexPath.row)")
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! tableViewCell
        let m = self.zones[indexPath.section][indexPath.row]
   //     cell.textLabel?.numberOfLines = 2
        print(m)
        cell.labelCell?.text = "\(getItemName(item: m.item)) (x\(m.item.quantity))"
        var s: String
        switch m.typeId {
        case 100: s = "retrieve_the_data_96"
        case 200, 201: s = "fight_the_storm_c1_96"
        case 202: s = "fight_the_storm_c2_96"
        case 203: s = "fight_the_storm_c3_96"
        case 204: s = "fight_the_storm_c4_96"
        case 300: s = "ride_the_lightning_96"
        case 400: s = "deliver_the_bomb_96"
        case 500: s = "rescue_survivors_96"
        case 600: s = "build_the_radar_grid_96"
        case 700: s = "eliminate_and_collect_96"
        case 800: s = "drawable.resupply_96"
        case 900: s = "evacuate_the_shelter_96"
        case 1000: s = "refuel_the_base_96"
        case 1100: s = "destroy_encampments_96"
        case 1200: s = "repair_the_shelter_96"
        default: s = "" // ic_input_add
        }
        let image = UIImage(named: s)?.withRenderingMode(.alwaysOriginal)
        cell.imageType?.image = image
        // grouped
        if m.group {
            cell.imageGroup?.image = UIImage(named: "group_96")?.withRenderingMode(.alwaysOriginal)
        } else {
            cell.imageGroup?.image = nil
        }
    // power
        if m.powerId > 0,   // powerID начинаются от 1
           m.powerId <= powerVal.count {
            cell.labelPower?.text = "\(powerVal[m.powerId-1])"
            let image = UIImage(named: "power_96")?.withRenderingMode(.alwaysOriginal)
            cell.imagePower?.image = image
        }
        if m.item.rarId>0,
           m.item.rarId<=4 {
            cell.backgroundColor = UIColorFromRGB(rgbValue: rareVal[m.item.rarId-1])
        }
      return cell
    }

    @objc private func setTitle(newTitle: String) {
//print("set new title")
            let label = UILabel()
            label.backgroundColor = .clear
            label.numberOfLines = 0     // To remove any maximum limit
            label.font = UIFont.boldSystemFont(ofSize: 16.0)
            label.textAlignment = .center
            label.textColor = .black
            label.text = newTitle
            label.sizeToFit()
            label.adjustsFontSizeToFitWidth = true
        self.navigationTitle.titleView = label
        }
    
    @objc func showJson(data: Data) {
        filterZones[0] = switchZone0.isOn
        filterZones[1] = switchZone1.isOn
        filterZones[2] = switchZone2.isOn
        filterZones[3] = switchZone3.isOn
        filterCategories[0] = switchCategory0.isOn
        filterCategories[1] = switchCategory1.isOn
        filterCategories[2] = switchCategory2.isOn
        filterCategories[3] = switchCategory3.isOn
        zones.removeAll()
        zones.append([MissionFlat]())
        zones.append([MissionFlat]())
        zones.append([MissionFlat]())
        zones.append([MissionFlat]())

        for i in 0..<vbucksSum.count {
            vbucksSum[i] = 0
        }
        let filterSingle = switchSingle.isOn
        let filterGroup = switchGroup.isOn
        let filterVBucks = switchVBucks.isOn
        var mTmp: MissionFlat! = MissionFlat()
        do {
        let decoder = JSONDecoder()
            let mi = try decoder.decode(PveMissionsInfo.self, from: data)
        for m in mi.missions {
            mTmp.categoryId = m.categoryId
            mTmp.typeId = m.typeId
            mTmp.group = m.group
            mTmp.groupMembersCount = m.groupMembersCount
            mTmp.powerId = m.powerId
            mTmp.locationName = ""
            for i in m.items {
                mTmp.item = i
                    var filterCategory: Bool = false
                    if mTmp.categoryId < 0 {
                        filterCategory = true
                    } else
                    if (mTmp.categoryId < self.filterCategories.count) {
                        filterCategory = self.filterCategories[mTmp.categoryId]
                    }
                if filterCategory,
                   (filterSingle && m.group == false) ||
                    (filterGroup && m.group == true),
                  m.location >= 0,
                  m.location < self.zones.count,
                  self.filterZones[m.location]{
                    print(m.location)
                       print(mTmp!)
                       mTmp.locationName = self.zonesNames[m.location]
                        self.zones[m.location].append(mTmp)
                       if mTmp.item.nameId == 9 {   // V-Bucks
                            self.vbucksSum[m.location] += mTmp.item.quantity
                       }
                }}
        }
 //   DispatchQueue.main.async { [self] in
        expire = mi.expire
        var i: Int = 0
        while i<zones.count {
            if zones[i].isEmpty {zones.remove(at: i)} else {i+=1}   // такое хитрое удаление, т.к. в простом for уедут индексы
        }
        tableView.reloadData()
        label1.text = NSLocalizedString("abb_caps_sw", comment: "") + "\n\(vbucksSum[0])"
        label2.text = NSLocalizedString("abb_caps_pt", comment: "") + "\n\(vbucksSum[1])"
        label3.text = NSLocalizedString("abb_caps_cv", comment: "") + "\n\(vbucksSum[2])"
        label4.text = NSLocalizedString("abb_caps_tp", comment: "") + "\n\(vbucksSum[3])"
        labelSum.text = NSLocalizedString("element_vbucks_total", comment: "") + "\n\(vbucksSum[0]+vbucksSum[1]+vbucksSum[2]+vbucksSum[3])"
//    }
        } catch {
                print(error.localizedDescription)
        }

    }
    
    @IBAction func touchUpInside(_ sender: Any) {
        let req = NSMutableURLRequest(url: NSURL(string:serverIP)! as URL)
//        req.httpMethod="GET"
        req.timeoutInterval = 5000.0
        let task = URLSession.shared.dataTask(with: req as URLRequest) {data, response, error in
            if let error = error {
                print ("error: \(error)")
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                print("response statusCode \(httpResponse.statusCode)")
            }
            guard let httpresponse = response as? HTTPURLResponse,
                (200...299).contains(httpresponse.statusCode) else {
                print ("server error")
                return
            }
 //print ("got data: \(String(describing: String(data: data!, encoding: .utf8)))")
            if let mimeType = httpresponse.mimeType, mimeType == "application/json",
                let data = data {
                DispatchQueue.main.async {
                    self.showJson(data: data)
                }
            } else {
                print("content error, mimeType != json")
                return
            }
       }
        task.resume()
    }
    }



