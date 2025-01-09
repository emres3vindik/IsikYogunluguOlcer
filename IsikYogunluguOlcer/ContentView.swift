import SwiftUI
import Charts

// MARK: - ContentView
/// Ana görünüm yapısı
struct ContentView: View {
    // MARK: - Properties
    @StateObject private var lightViewModel = LightViewModel()
    
    /// Işık seviyesine göre uygun rengi döndüren yardımcı fonksiyon
    /// - Parameter luxValue: Işık değeri (lux cinsinden)
    /// - Returns: Işık seviyesine uygun renk
    private func getColor(for luxValue: Double) -> Color {
        switch luxValue {
        case 0...50: return .blue    // Karanlık
        case 51...200: return .green // Normal
        case 201...500: return .yellow // Parlak
        default: return .red         // Çok parlak
        }
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // Arka plan gradyanı
            LinearGradient(gradient: Gradient(colors: [.blue.opacity(0.3), .purple.opacity(0.3)]),
                          startPoint: .topLeading,
                          endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Başlık
                Text("Işık Yoğunluğu Ölçer")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                // Dairesel gösterge
                ZStack {
                    // Arka plan dairesi
                    Circle()
                        .stroke(lineWidth: 20)
                        .opacity(0.3)
                        .foregroundColor(Color.gray)
                    
                    // Animasyonlu dolum dairesi
                    Circle()
                        .trim(from: 0.0, to: min(CGFloat(lightViewModel.luxValue) / 1000, 1.0))
                        .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                        .foregroundColor(getColor(for: lightViewModel.luxValue))
                        .rotationEffect(Angle(degrees: 270.0))
                        .animation(.linear(duration: 1.0), value: lightViewModel.luxValue)
                    
                    // Değer göstergesi
                    VStack {
                        Text("\(String(format: "%.1f", lightViewModel.luxValue))")
                            .font(.system(size: 40, weight: .bold))
                        Text("lux")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        Text(getLightDescription(luxValue: lightViewModel.luxValue))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(width: 200, height: 200)
                
                // Işık seviyesi göstergeleri
                HStack(spacing: 15) {
                    StatusIndicator(color: .blue, text: "Karanlık")
                    StatusIndicator(color: .green, text: "Normal")
                    StatusIndicator(color: .yellow, text: "Parlak")
                    StatusIndicator(color: .red, text: "Çok Parlak")
                }
                .padding()
                
                // Grafik bölümü
                if #available(iOS 16.0, *) {
                    Chart {
                        ForEach(lightViewModel.measurements) { measurement in
                            LineMark(
                                x: .value("Zaman", measurement.time, unit: .second),
                                y: .value("Lux", measurement.value)
                            )
                            .foregroundStyle(getColor(for: measurement.value))
                        }
                    }
                    .frame(height: 150)
                    .padding()
                    .chartYScale(domain: 0...1000)
                    .chartXAxis {
                        AxisMarks(values: .automatic(desiredCount: 5)) { value in
                            AxisValueLabel {
                                if let date = value.as(Date.self) {
                                    Text(date, format: .dateTime.hour().minute().second())
                                }
                            }
                        }
                    }
                } else {
                    // iOS 16 öncesi için alternatif görünüm
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(lightViewModel.measurements) { measurement in
                                VStack {
                                    Text("\(Int(measurement.value))")
                                        .font(.headline)
                                    Text(measurement.time, style: .time)
                                        .font(.caption)
                                }
                                .padding()
                                .background(Color.secondary.opacity(0.1))
                                .cornerRadius(10)
                            }
                        }
                    }
                    .frame(height: 100)
                    .padding()
                }
                
                // Yenileme butonu
                Button(action: {
                    lightViewModel.fetchLightValue()
                }) {
                    Label("Yenile", systemImage: "arrow.clockwise")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 200)
                        .background(Color.blue)
                        .cornerRadius(15)
                        .shadow(radius: 5)
                }
            }
        }
        .onAppear {
            // Otomatik yenileme için timer başlat
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                lightViewModel.fetchLightValue()
            }
        }
    }
    
    /// Işık değerine göre açıklayıcı metin döndüren yardımcı fonksiyon
    /// - Parameter luxValue: Işık değeri (lux cinsinden)
    /// - Returns: Açıklayıcı metin
    private func getLightDescription(luxValue: Double) -> String {
        switch luxValue {
        case 0...50: return "Karanlık Ortam"
        case 51...200: return "Normal Aydınlık"
        case 201...500: return "Parlak Ortam"
        default: return "Çok Parlak Ortam"
        }
    }
}

// MARK: - StatusIndicator
/// Durum göstergesi için yardımcı view yapısı
struct StatusIndicator: View {
    let color: Color
    let text: String
    
    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            Text(text)
                .font(.caption)
        }
    }
}
