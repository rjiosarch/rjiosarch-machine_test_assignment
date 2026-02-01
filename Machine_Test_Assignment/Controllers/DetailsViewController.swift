//
//  DetailsViewController.swift
//  Machine_Test_Assignment
//
//  Created by Mr. Raj on 1/2/26.
//

import UIKit


class DetailsViewController: UIViewController {

    // Properties
    var device: DiscoveredDevice?
    
    @IBOutlet weak var infoLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let device = device else { return }
        title = device.name

        fetchPublicIP()
    }

    func fetchPublicIP() {

        guard let url = URL(string: "https://api.ipify.org?format=json") else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard
                error == nil,
                let data = data,
                let response = try? JSONDecoder().decode(Ip_Response.self, from: data)
            else {
                self.updateUI("Failed to fetch public IP")
                return
            }

            self.fetchIPDetails(ip: response.ip)

        }.resume()
    }

    func fetchIPDetails(ip: String) {

        guard let url = URL(string: "https://ipinfo.io/\(ip)/geo") else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard
                error == nil,
                let data = data,
                let info = try? JSONDecoder().decode(IpInfo.self, from: data)
            else {
                self.updateUI("Failed to fetch IP details")
                return
            }

            self.updateUI(self.formatInfo(ip: ip, info: info))

        }.resume()
    }
    
    func formatInfo(ip: String, info: IpInfo) -> String {

        return """
        🌐 Public IP
        \(ip)

        📍 Location
        \(info.city ?? "-"), \(info.region ?? "-"), \(info.country ?? "-")

        🗺 Coordinates
        \(info.loc ?? "-")

        🏢 Organization / Carrier
        \(info.org ?? "-")

        ⏱ Timezone
        \(info.timezone ?? "-")
        """
    }

    
    func updateUI(_ text: String) {
        DispatchQueue.main.async {
            self.infoLabel.text = text
        }
    }


}
