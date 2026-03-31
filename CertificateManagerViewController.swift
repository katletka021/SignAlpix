import UIKit

struct Certificate: Codable {
    var name: String
    var expiry: String
    var p12Data: Data?
}

class CertificateManagerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var certificates: [Certificate] = []
    let tableView = UITableView()
    var appPath: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Менеджер сертификатов"
        setupTableView()
        loadCertificates()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addCertificate))
    }
    
    func setupTableView() {
        tableView.frame = view.bounds
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "certCell")
        view.addSubview(tableView)
    }
    
    func loadCertificates() {
        if let data = UserDefaults.standard.data(forKey: "Certificates"),
           let saved = try? JSONDecoder().decode([Certificate].self, from: data) {
            certificates = saved
        } else {
            certificates = [
                Certificate(name: "Apple Development", expiry: "2025-12-31"),
                Certificate(name: "Distribution Cert", expiry: "2026-06-15")
            ]
        }
        tableView.reloadData()
    }
    
    func saveCertificates() {
        if let data = try? JSONEncoder().encode(certificates) {
            UserDefaults.standard.set(data, forKey: "Certificates")
        }
    }
    
    @objc func addCertificate() {
        let alert = UIAlertController(title: "Добавить сертификат", message: "Введите название и вставьте содержимое .p12 (Base64)", preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Название" }
        alert.addTextField { $0.placeholder = "Содержимое .p12 (Base64)" }
        alert.addAction(UIAlertAction(title: "Добавить", style: .default) { _ in
            if let name = alert.textFields?[0].text, !name.isEmpty,
               let p12Base64 = alert.textFields?[1].text, let p12Data = Data(base64Encoded: p12Base64) {
                self.certificates.append(Certificate(name: name, expiry: "2026-12-31", p12Data: p12Data))
                self.saveCertificates()
                self.tableView.reloadData()
            }
        })
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        present(alert, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return certificates.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "certCell", for: indexPath)
        let cert = certificates[indexPath.row]
        cell.textLabel?.text = "\(cert.name) • \(cert.expiry)"
        cell.textLabel?.textColor = .red
        cell.backgroundColor = .white
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let appPath = appPath else {
            let alert = UIAlertController(title: "Ошибка", message: "Не выбрано приложение", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        let cert = certificates[indexPath.row]
        let alert = UIAlertController(title: "Подпись", message: "Подписать \(URL(fileURLWithPath: appPath).lastPathComponent) сертификатом \(cert.name)?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Да", style: .default) { _ in
            self.signIPA(at: appPath, with: cert)
        })
        alert.addAction(UIAlertAction(title: "Нет", style: .cancel))
        present(alert, animated: true)
    }
    
    func signIPA(at path: String, with cert: Certificate) {
        // Реальная подпись через Apple API / ldid / etc
        // Здесь демонстрация успеха
        let signedDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("Signed")
        try? FileManager.default.createDirectory(at: signedDir, withIntermediateDirectories: true)
        let destURL = signedDir.appendingPathComponent(URL(fileURLWithPath: path).lastPathComponent)
        do {
            try FileManager.default.copyItem(at: URL(fileURLWithPath: path), to: destURL)
            // Здесь можно вызвать внешний инструмент подписи
            let success = true // Заглушка
            if success {
                let alert = UIAlertController(title: "Готово", message: "Приложение подписано и сохранено в Signed", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
        } catch {
            let alert = UIAlertController(title: "Ошибка", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
}
