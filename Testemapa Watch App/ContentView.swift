//
//  ContentView.swift
//  Testemapa Watch App
//
//  Created by Joao pedro Leonel on 11/08/25.
//

import SwiftUI
import CoreMotion
import HealthKit
import CoreLocation

struct ContentView: View {
    // Gerenciador de calibração inicial via GPS/Bússola
//    @StateObject private var calibrationManager = MotionManager()
    // Gerenciador do treino e do PDR via CoreMotion/HealthKit
    @StateObject private var positionManager = managerPosition()
    
    // Garante que o WCSession (contato com o iphone basicamente) comece a ativar assim que o app for lançado
    private let connectivityManager = WatchConnectivityManager.shared
    
    @State private var mostrarAvisoCalibracao = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                
                // O estado do treino determina quais botões são mostrados.
                if positionManager.localizacaoRodando{
                    
                    Button("Parar Treino") {
                        positionManager.stopMotionUpdates()
                    }
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    
                } else {
                    // Antes do treino começar, mostra Calibrar ou Iniciar.
                    if /*calibrationManager.referenceHeading == nil*/ positionManager.origemDefinida == false{
                        //Se não calibrado, mostra o botão de calibrar.
                        Button("Definir Origem") {
                            self.mostrarAvisoCalibracao = true
                        }
                        .alert(isPresented: $mostrarAvisoCalibracao) {
                            Alert(
                                title: Text("Instrução"),
                                message: Text("Fique no centro da quadra, de frente para a rede, e toque em ORIGEM."),
                                dismissButton: .default(Text("ORIGEM")) {
//                                    calibrationManager.setOriginAndReference()
                                    positionManager.setOrigem()
                                }
                            )
                        }
                    } else {
                        // Se JÁ calibrado, mostra o botão de iniciar treino.
                        if !positionManager.localizacaoRodando{
                            Button("Iniciar Treino") {
                                // O guard let aqui é uma segurança extra so deixa iniciar o treino caso realmnete ja tenha os dados do calibrador
                                positionManager.startMotionUpdates()
                            }
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }else{
                            Button("Parar Treino") {
                                // O guard let aqui é uma segurança extra so deixa iniciar o treino caso realmnete ja tenha os dados do calibrador
                                positionManager.stopMotionUpdates()
                            }
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                        
                    }
                }
                
                // --- SEÇÃO DE STATUS EM TEMPO REAL ---
                // Mostra o status de calibragem se o valor existir
//                if let reference = calibrationManager.referenceHeading {
//                    Text("Calibrado: \(String(format: "%.1f", reference.trueHeading))°")
//                        .font(.footnote)
//                        .foregroundColor(.green)
//                }
                
                // Mostra os dados do treino se ele estiver rodando
                if positionManager.localizacaoRodando {
                    Text("Posição (X,Y): \(String(format: "%.2f", positionManager.currentPosition.x))m, \(String(format: "%.2f", positionManager.currentPosition.y))m")
                    Text("Passos Detectados: \(positionManager.path.count - 1)")
                }
            }
//            .onAppear {
//                // Inicia as atualizações de AMBOS os managers.
//                // O calibrationManager precisa ser iniciado para receber dados da bússola.
//                //self.calibrationManager.startUpdates()
//                self.positionManager.requestAuthorization()
//            }
        }
    }
}

