//
//  ViewController.swift
//  fortniteassistant
//
//  Created by AG on 20.01.2021.
//

import UIKit
class tableViewCell: UITableViewCell {
    @IBOutlet weak var labelCell: UILabel!
    @IBOutlet weak var imageType: UIImageView!
    @IBOutlet weak var labelPower: UILabel!
    @IBOutlet weak var imageGroup: UIImageView!
    @IBOutlet weak var imagePower: UIImageView!
}
class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
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
        var categoryId: Int = 0
//        var location: Int = 0
        var typeId: Int = 0
        var group: Bool = false
        var groupMembersCount: Int = 0
        var powerId: Int = 0
        var item: Item = Item()
     }

    var zones = [
        [MissionFlat](),  // Камнелесье
        [MissionFlat](),  // Планкертон
        [MissionFlat](),  // Вещая долина
        [MissionFlat]()   // Линч Пикс
    ]
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

        setTitle(newTitle: "dfff")
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
print("section \(section)")
let label = UILabel()
        if section == 0 {label.text = "Камнелесье"}
        if section == 1 {label.text = "Планкертон"}
        if section == 2 {label.text = "Вещая Долина"}
        if section == 3 {label.text = "Линч Пикс"}

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
        print("add to tableView at secytion=\(indexPath.section),index=\(indexPath.row)")
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! tableViewCell
        let m = self.zones[indexPath.section][indexPath.row]
   //     cell.textLabel?.numberOfLines = 2
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
            let image = UIImage(named: "group_96")?.withRenderingMode(.alwaysOriginal)
            cell.imageGroup?.image = image
        }
        // power
        if m.powerId > 0,   // powerID начинаются от 1
           m.powerId <= powerVal.count {
            cell.labelPower?.text = "\(powerVal[m.powerId-1])"
            let image = UIImage(named: "power_96")?.withRenderingMode(.alwaysOriginal)
            cell.imagePower?.image = image
        }

      return cell
    }

    @objc private func setTitle(newTitle: String) {
            print("set new title")
            let label = UILabel()
            label.backgroundColor = .clear
            label.numberOfLines = 0     // To remove any maximum limit
            label.font = UIFont.boldSystemFont(ofSize: 16.0)
            label.textAlignment = .center
            label.textColor = .black
            label.text = newTitle
            label.sizeToFit()
            label.adjustsFontSizeToFitWidth = true
            self.navigationItem.titleView = label
        }

    @IBAction func touchUpInside(_ sender: Any) {
        zones[0].removeAll()
        zones[1].removeAll()
        zones[2].removeAll()
        zones[3].removeAll()
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
            if httpresponse.mimeType != "application/json" {
               print("content error, mimeType != json")
               return
            }
 //print ("got data: \(String(describing: String(data: data!, encoding: .utf8)))")
            var dateSinceNow: Date?
            var mTmp: MissionFlat! = MissionFlat()
            do {
            let decoder = JSONDecoder()
            let mi = try decoder.decode(PveMissionsInfo.self, from: data!)
            print(mi.expire)
            let date = Date(timeIntervalSince1970: TimeInterval(mi.expire) / 1000)
            dateSinceNow = Date(timeIntervalSinceReferenceDate: date.timeIntervalSinceNow)
            for m in mi.missions {
                mTmp.categoryId = m.categoryId
  //              mTmp.location = m.location
                mTmp.typeId = m.typeId
                mTmp.group = m.group
                mTmp.groupMembersCount = m.groupMembersCount
                mTmp.powerId = m.powerId
                for i in m.items {
                    mTmp.item = i
                    print(m.location)
                    print("zones count=\(self.zones.count)")
                    print(mTmp!)
                    
                    DispatchQueue.main.async{
                        if m.location >= 0,m.location < self.zones.count {
                        self.zones[m.location].append(mTmp)}
             }
            }
            }
        let f = DateFormatter()
        f.dateFormat = "HH:mm:ss"
        DispatchQueue.main.async {
           self.tableView.reloadData()
            self.titleLabel.text = "new missions after: \(f.string(from: dateSinceNow!))"
        }
            } catch {
                    print(error.localizedDescription)
            }
        }
        task.resume()
    }
    }



