import Foundation
import WatchConnectivity
import CoreGraphics
import Combine

// Singleton responsável por comunicação com o Apple Watch via WCSession.
// Recebe pontos enviados pelo Watch e acumula no histórico.
final class WatchConnectivityManager: NSObject, WCSessionDelegate {
    
    static let shared = WatchConnectivityManager()
    
    // Mantém o histórico de pontos recebidos
    @Published var allPoints: [CGPoint] = []
    
    // Publisher Combine exposto para as Views
    private let subject = PassthroughSubject<[CGPoint], Never>()
    var workoutDataPublisher: AnyPublisher<[CGPoint], Never> {
        subject.eraseToAnyPublisher()
    }

    private override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) { }

    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) { }
    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }
    #endif

    func session(_ session: WCSession,
                 didReceiveUserInfo userInfo: [String : Any] = [:]) {
        guard let raw = userInfo["workoutPath"] as? [Any] else { return }

        var points: [CGPoint] = []
        points.reserveCapacity(raw.count)

        for item in raw {
            if let dict = item as? [String: Any] {
                let xVal = dict["x"]
                let yVal = dict["y"]

                func toCGFloat(_ v: Any?) -> CGFloat? {
                    switch v {
                    case let n as NSNumber: return CGFloat(truncating: n)
                    case let s as String:   return CGFloat(Double(s) ?? .nan)
                    default:                return nil
                    }
                }

                if let x = toCGFloat(xVal), let y = toCGFloat(yVal),
                   x.isFinite, y.isFinite {
                    points.append(CGPoint(x: x, y: y))
                }
            }
        }

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // 🔹 Acumula no histórico
            self.allPoints.append(contentsOf: points)
            
            // 🔹 Publica o histórico completo para as views
            self.subject.send(self.allPoints)
            
            print("📩 Recebido bloco com \(points.count) pontos. Total acumulado: \(self.allPoints.count)")
        }
    }
}
