//
//  HeatmapResultView.swift
//  Testemapa
//
//  Created by Joao pedro Leonel on 29/08/25.
//

import SwiftUI
import Combine

// Contêiner que assina os pontos vindos do Watch e renderiza o Heatmap por cima de um fundo.
struct HeatmapResultView: View {
    @State private var latestPoints: [CGPoint] = []          // pontos recebidos
    @State private var subscription: AnyCancellable? = nil   // assinatura Combine

    // === BOUNDS DE DEBUG (12x12m centrado no zero) ===
    // Troque depois por meia-quadra se preferir:
    // let halfCourt = CGRect(x: -4, y: 0, width: 8, height: 8)
    private let debugSquare = CGRect(x: -6, y: -6, width: 12, height: 12)

    var body: some View {
        ZStack {
            // Fundo opcional (troque "mapacalor" pelo nome do seu asset ou remova)
//            Image("mapacalor")
//                .resizable()
//                .scaledToFit()

            // Overlay do heatmap (ocupa o mesmo frame do fundo)
            HeatmapView(
                points: latestPoints,
//                worldBounds: debugSquare,
                rotationDegrees: 220
            )
            .allowsHitTesting(false)
        }
        // Ajuste o frame conforme seu layout / imagem
        .frame(width: 280, height: 280)
        .onAppear {
            // Assina o publisher do WatchConnectivityManager
            subscription = WatchConnectivityManager.shared.workoutDataPublisher
                .receive(on: RunLoop.main)
                .sink { pts in
                    print("iPhone recebeu \(pts.count) pontos. Amostra:", pts.prefix(5))
                    latestPoints = pts
                }
        }
        .onDisappear {
            subscription?.cancel()
            subscription = nil
        }
    }
}

#Preview {
    HeatmapResultView()
}
