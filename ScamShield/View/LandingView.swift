import Foundation
import SwiftUI

struct ScamShieldOnboarding: View {
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    Color.white.ignoresSafeArea()
                    
                    VStack(spacing: 0) {
                        // Top section
                        VStack {
                            Spacer()
                            ZStack {
                                Circle()
                                    .fill(Color(red: 0.9, green: 0.9, blue: 1.0))
                                    .frame(width: 140, height: 140)

                                Image(systemName: "person.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 70, height: 70)
                                    .foregroundColor(.purple)

                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.blue)
                                    .frame(width: 30, height: 20)
                                    .offset(x: 40, y: -30)

                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.gray.opacity(0.7))
                                    .frame(width: 25, height: 16)
                                    .offset(x: 25, y: -10)
                            }
                            .padding(.bottom, 40)
                            Spacer()
                        }
                        .frame(height: geometry.size.height * 0.45)
                        
                        // Bottom section
                        ZStack {
                            ExactWaveShape()
                                .fill(Color(red: 0.13, green: 0.36, blue: 0.37))
                                .ignoresSafeArea(edges: .bottom)
                            
                            VStack {
                                Spacer().frame(height: 40)
                                
                                Text("ScamShield")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text("With Scam Shield, you'll be\nsafe today")
                                    .font(.system(size: 16))
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.white)
                                    .padding(.top, 5)
                                
                                Spacer()
                                
                                // Navigation buttons - Login and Sign up
                                VStack(spacing: 16) {
                                    NavigationLink(destination: LoginView()) {
                                        Text("Log In")
                                            .font(.system(size: 17, weight: .medium))
                                            .foregroundColor(.black)
                                            .frame(width: 180, height: 45)
                                            .background(Color(white: 0.9))
                                            .cornerRadius(22.5)
                                    }
                                    
                                    NavigationLink(destination: SignUpView()) {
                                        Text("Sign Up")
                                            .font(.system(size: 17, weight: .medium))
                                            .foregroundColor(Color(red: 0.13, green: 0.36, blue: 0.37))
                                            .frame(width: 180, height: 45)
                                            .background(Color.white)
                                            .cornerRadius(22.5)
                                    }
                                }
                                .padding(.bottom, 60)
                            }
                        }
                        .frame(height: geometry.size.height * 0.55)
                    }
                }
            }
        }
    }
}


struct ExactWaveShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: 0, y: 40))
        path.addCurve(
            to: CGPoint(x: rect.width, y: 40),
            control1: CGPoint(x: rect.width * 0.5, y: -30),
            control2: CGPoint(x: rect.width * 0.5, y: -30)
        )
        
        path.addLine(to: CGPoint(x: rect.width, y: rect.height + 20))
        path.addLine(to: CGPoint(x: 0, y: rect.height + 20))
        path.closeSubpath()
        
        return path
    }
}

struct ScamShieldOnboarding_Previews: PreviewProvider {
    static var previews: some View {
        ScamShieldOnboarding()
            .previewDevice("iPhone 14 Pro")
    }
}
