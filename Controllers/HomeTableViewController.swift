//
//  HomeTableViewController.swift
//  Machine_Test_Assignment
//
//  Created by Mr. Raj on 1/2/26.
//

import UIKit
import FirebaseAuth
import CoreData

class HomeTableViewController: UITableViewController {

    // Properties
    private let serviceBrowser = NetServiceBrowser()
    private var services: [NetService] = []
    
    // CoreData-backed model Properties
    private var devices: [DiscoveredDevice] = []
    var context: NSManagedObjectContext {
        (UIApplication.shared.delegate as! AppDelegate)
            .persistentContainer
            .viewContext
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadFromCoreData()
        startDiscovery()
        setSignOutBtn()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceCell", for: indexPath)
        let device = devices[indexPath.row]
        let displayName = cleanDeviceName(device.name)
        
        cell.textLabel?.text = displayName
        cell.detailTextLabel?.numberOfLines = 0

        let statusText = device.reachable ? "Reachable" : "Un-Reachable"
        let dotColor: UIColor = device.reachable ? .systemGreen : .systemRed
        let dot = "● "
        let fullText = "\(device.ip)\n\n\(dot)\(statusText)"
        let attributedText = NSMutableAttributedString(string: fullText)
        let dotRange = (fullText as NSString).range(of: dot)
        attributedText.addAttribute(.foregroundColor,
                                    value: dotColor,
                                    range: dotRange)
        
        let statusRange = (fullText as NSString).range(of: statusText)
        attributedText.addAttribute(.font,
                                    value: UIFont.systemFont(ofSize: 13, weight: .medium),
                                    range: statusRange)
        
        cell.detailTextLabel?.attributedText = attributedText
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detailVC = storyboard.instantiateViewController( withIdentifier: "DetailsViewController") as! DetailsViewController
        detailVC.device =  devices[indexPath.row]
        navigationController?.pushViewController(detailVC, animated: true)
    }

    
    func cleanDeviceName(_ rawName: String) -> String {
        if let index = rawName.firstIndex(of: "@") {
            return String(rawName[rawName.index(after: index)...])
        }
        return rawName
    }

    func startDiscovery() {
        serviceBrowser.delegate = self
        //serviceBrowser.searchForServices(ofType: "_airplay._tcp.", inDomain: "")
        serviceBrowser.searchForServices(ofType: "_raop._tcp.", inDomain: "")
    }

    func setSignOutBtn() {
        navigationItem.hidesBackButton = true
        let signOutButton = UIBarButtonItem(
            image: UIImage(systemName: "rectangle.portrait.and.arrow.right"),
            style: .plain,
            target: self,
            action: #selector(signOutTapped)
        )
        navigationItem.rightBarButtonItem = signOutButton
    }
    
    @objc func signOutTapped() {
        do {
            try Auth.auth().signOut()
            resetToLogin()
        } catch {
            print("Sign out failed:", error.localizedDescription)
        }
    }

    func resetToLogin() {
        guard
            let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let sceneDelegate = scene.delegate as? SceneDelegate
        else { return }
        sceneDelegate.showLogin()
    }

    func extractIPAddress(from service: NetService) -> String {
        guard let addresses = service.addresses else { return "Unknown" }
        for data in addresses {
            var sockaddr = sockaddr_storage()
            (data as NSData).getBytes(&sockaddr, length: MemoryLayout<sockaddr_storage>.size)
            
            if sockaddr.ss_family == sa_family_t(AF_INET) {
                var addr = sockaddr_in()
                memcpy(&addr, &sockaddr, MemoryLayout<sockaddr_in>.size)
                return String(cString: inet_ntoa(addr.sin_addr))
            }
        }
        return "Unknown"
    }

}


extension HomeTableViewController: NetServiceBrowserDelegate {
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        service.delegate = self
        services.append(service)
        service.resolve(withTimeout: 5)
    }

    func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        markDeviceUnreachable(service.name)
    }
}

extension HomeTableViewController: NetServiceDelegate {

    func netServiceDidResolveAddress(_ sender: NetService) {
        let ip = extractIPAddress(from: sender)
        saveOrUpdateDevice(
            name: sender.name,
            ip: ip,
            reachable: true
        )
        tableView.reloadData()
    }

    func netService(_ sender: NetService, didNotResolve errorDict: [String : NSNumber]) {
        saveOrUpdateDevice(
            name: sender.name,
            ip: "Unknown",
            reachable: false
        )
    }
}

extension HomeTableViewController {
    
    func saveOrUpdateDevice(name: String, ip: String, reachable: Bool) {
        let request: NSFetchRequest<DeviceEntity> = DeviceEntity.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", name)

        let device = (try? context.fetch(request).first) ?? DeviceEntity(context: context)

        device.name = name
        device.ip = ip
        device.reachable = reachable
        device.lastSeen = Date()

        try? context.save()
        loadFromCoreData()
    }

    
    func loadFromCoreData() {
        let request: NSFetchRequest<DeviceEntity> = DeviceEntity.fetchRequest()
        let results = (try? context.fetch(request)) ?? []

        devices = results.map {
            DiscoveredDevice(
                name: $0.name ?? "",
                ip: $0.ip ?? "Unknown",
                reachable: $0.reachable
            )
        }

        tableView.reloadData()
    }

    func markDeviceUnreachable(_ name: String) {
        saveOrUpdateDevice(
            name: name,
            ip: "Unknown",
            reachable: false
        )
        tableView.reloadData()
    }

}
