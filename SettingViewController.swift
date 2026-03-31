import UIKit

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let tableView = UITableView()
    let items = [
        "Получить UDID устройства", "Менеджер сертификатов", "Импорт ресурсов",
        "Настройки подписи", "WiFi", "WebDAV", "Темы", "Блокировка ориентации",
        "Работа в фоновом режиме", "Хранилище", "Join QQ Group", "Чат в Telegram",
        "Веб-сайт"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Настройки"
        setupTableView()
    }
    
    func setupTableView() {
        tableView.frame = view.bounds
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "settingsCell")
        view.addSubview(tableView)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return items.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath)
        cell.textLabel?.text = items[indexPath.row]
        cell.textLabel?.textColor = .red
        cell.backgroundColor = .white
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0: getUDID()
        case 1: navigationController?.pushViewController(CertificateManagerViewController(), animated: true)
        case 11: openTelegram()
        default: break
        }
    }
    
    func getUDID() {
        let udid = UIDevice.current.identifierForVendor?.uuidString ?? "Unknown"
        let alert = UIAlertController(title: "UDID", message: udid, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Копировать", style: .default) { _ in
            UIPasteboard.general.string = udid
        })
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(alert, animated: true)
    }
    
    func openTelegram() {
        if let url = URL(string: "https://t.me/geto320") {
            UIApplication.shared.open(url)
        }
    }
}
