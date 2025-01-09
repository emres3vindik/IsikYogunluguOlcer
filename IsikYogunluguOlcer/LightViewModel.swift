import Foundation

// MARK: - LightViewModel
/// Işık sensöründen gelen verileri yöneten ve işleyen view model sınıfı
class LightViewModel: ObservableObject {
    // MARK: - Properties
    /// Anlık ışık değeri (lux cinsinden)
    @Published var luxValue: Double = 0.0
    /// Son ölçümlerin tutulduğu dizi
    @Published var measurements: [LightMeasurement] = []
    /// ESP8266 modülünün IP adresi
    private let ipAddress = "172.20.10.2"
    /// Saklanacak maksimum ölçüm sayısı
    private let maxMeasurements = 10
    
    // MARK: - Methods
    /// ESP8266'dan ışık değerini çeken fonksiyon
    func fetchLightValue() {
        guard let url = URL(string: "http://\(ipAddress)/light") else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(LightResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.luxValue = result.lux
                        self.addMeasurement(value: result.lux)
                    }
                } catch {
                    print("Decode hatası: \(error)")
                }
            }
        }.resume()
    }
    
    /// Yeni bir ölçüm ekleyen private fonksiyon
    /// - Parameter value: Eklenecek ışık değeri
    private func addMeasurement(value: Double) {
        let measurement = LightMeasurement(
            id: UUID(),
            value: value,
            time: Date()
        )
        
        DispatchQueue.main.async {
            self.measurements.append(measurement)
            // Maksimum ölçüm sayısını aşınca en eski ölçümü sil
            if self.measurements.count > self.maxMeasurements {
                self.measurements.removeFirst()
            }
        }
    }
}

// MARK: - Data Models
/// ESP8266'dan gelen JSON yanıtı için model
struct LightResponse: Codable {
    let lux: Double
}

/// Tek bir ışık ölçümü için model
struct LightMeasurement: Identifiable {
    let id: UUID
    let value: Double
    let time: Date
}
