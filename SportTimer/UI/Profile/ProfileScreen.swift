//
//  ProfileScreen.swift
//  SportTimer
//
//  Created by Nikolay Taran on 7/10/25.
//

import SwiftUI

struct ProfileScreen: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @StateObject var profileObservable = ProfileObservable()
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                
                    userAvatar.onTapGesture {
                        profileObservable.checkPermissionAndUpdateUserAvatar()
                    }
            
                    statistics
            
                    settings
                
                    about
                }
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
            
            if profileObservable.nowLoading {
                NowLoading()
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .alert(isPresented: $profileObservable.galleryPermissionError) {
                Alert(
                    title: Text("Missing permission"),
                    message: Text("This app needs photo gallery permission to change user avatar"),
                    dismissButton: .default(Text("OK"))
                )
            }.sheet(isPresented: $profileObservable.showPicker) {
                ImagePicker(sourceType: .photoLibrary) { asset in
                    profileObservable.updateUserAvatar(asset: asset)
                }
            }.onAppear {
                profileObservable.fetchUserProfile()
                profileObservable.fetchLatestTrainingItems(shouldLimit: true, context: viewContext)
            }.background(Color("Background"))
    }
    
    @ViewBuilder
    var userAvatar: some View {
        VStack {
            if let userAvatar = profileObservable.userAvatar {
                Image(uiImage: userAvatar)
                    .resizable()
                    .scaledToFill()
                    .frame(width: UIScreen.main.bounds.width / 3, height: UIScreen.main.bounds.width / 3)
                    .clipped()
                    .cornerRadius(UIScreen.main.bounds.width / 6)
            } else {
                Image(systemName: "person.2.circle.fill")
                    .resizable()
                    .frame(width: UIScreen.main.bounds.width / 3, height: UIScreen.main.bounds.width / 3)
            }
                
            Text(NSLocalizedString("ChangeAvatar", comment: ""))
                .multilineTextAlignment(.center)
        }.frame(maxWidth: .infinity)
            .background(Color("Background"))
    }
    
    @ViewBuilder
    var statistics: some View {
        VStack {
            Text(NSLocalizedString("YourStatistics", comment: ""))
                .font(.system(size: 20, weight: .semibold))
                .padding()
            
            StatsLabel(title: NSLocalizedString("TotalWorkouts", comment: ""), value: String(profileObservable.totalNumberOfWorkouts))
            
            SolidButton(text: NSLocalizedString("FullStatistics", comment: "")) {
                profileObservable.shouldNavigateToStatistics = true
            }
            
            NavigationLink("", destination: StatisticsScreen()
                            .navigationTitle(NSLocalizedString("StatisticsTitle", comment: "")),
                           isActive: $profileObservable.shouldNavigateToStatistics)
        }
    }
    
    @ViewBuilder
    var settings: some View {
        VStack {
            Text(NSLocalizedString("AppSettings", comment: ""))
                .font(.system(size: 20, weight: .semibold))
                .padding()
            
            SolidButton(text: NSLocalizedString("Settings", comment: "")) {
                profileObservable.shouldNavigateToSettings = true
            }

            NavigationLink("", destination: SettingsScreen()
                            .navigationTitle(NSLocalizedString("SettingsTitle", comment: "")),
                           isActive: $profileObservable.shouldNavigateToSettings)
        }
    }
    
    @ViewBuilder
    var about: some View {
        VStack {
            Text(NSLocalizedString("About", comment: ""))
                .font(.system(size: 20, weight: .semibold))
                .padding()
            
            Text(NSLocalizedString("AboutApp", comment: ""))
                .font(.system(size: 16, weight: .medium))
                .padding(.horizontal, 16)
        }
    }
}
