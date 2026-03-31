import UIKit

class iOSSelectionViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    let pickerView = UIPickerView()
    let timerLabel = UILabel()
    var versions: [String] = []
    var timer: Timer?
    var remainingSeconds = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Выбрать iOS"
        
        // Генерация всех версий от 15.0 до 26.4 с шагом 0.1
        var ver = 15.0
        while ver <= 26.4 {
            let major = Int(ver)
            let minor = Int((ver - Double(major)) * 10)
            versions.append("iOS \(major).\(minor)")
            ver += 0.1
        }
        
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.frame = CGRect(x: 0, y: 100, width: view.frame.width, height: 200)
        view.addSubview(pickerView)
        
        timerLabel.frame = CGRect(x: 20, y: 320, width: view.frame.width - 40, height: 60)
        timerLabel.textAlignment = .center
        timerLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 28, weight: .bold)
        timerLabel.textColor = .red
        timerLabel.text = "Выберите версию iOS"
        view.addSubview(timerLabel)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return versions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return versions[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        startTimer()
    }
    
    func startTimer() {
        timer?.invalidate()
        remainingSeconds = 180
        updateTimerLabel()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(tick), userInfo: nil, repeats: true)
    }
    
    @objc func tick() {
        if remainingSeconds > 0 {
            remainingSeconds -= 1
            updateTimerLabel()
        } else {
            timer?.invalidate()
            timer = nil
            let alert = UIAlertController(title: "Требуется поддержка", message: "Напишите в Telegram @geto320", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Написать", style: .default) { _ in
                if let url = URL(string: "https://t.me/geto320") {
                    UIApplication.shared.open(url)
                }
            })
            alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
            present(alert, animated: true)
        }
    }
    
    func updateTimerLabel() {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        timerLabel.text = String(format: "Ожидание: %02d:%02d", minutes, seconds)
    }
}
