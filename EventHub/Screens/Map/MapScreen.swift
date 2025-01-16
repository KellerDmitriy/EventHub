//
//  MapScreen.swift
//  EventHub
//
//  Created by Руслан on 18.11.2024.
//

import SwiftUI
import MapKit

struct MapScreen: View {
    @StateObject private var viewModel: MapViewModel
    @State private var selectedEvent: MapEventModel?
    @EnvironmentObject private var coreDataManager: CoreDataManager
    
    let locationFetcher = LocationFetcher()
    
    private var isFavorite: Bool {
        coreDataManager.events.contains { event in
            Int(event.id) == self.selectedEvent?.id
        }
    }
    
    // MARK: - Init
    init() {
        self._viewModel = StateObject(wrappedValue: MapViewModel())
    }
    
    // MARK: - Body
    var body: some View {
        //        VStack {
        //            Button("Start Tracking Location") {
        //                locationFetcher.start()
        //            }
        //
        //            Button("Read Location") {
        //                if let location = locationFetcher.lastKnownLocation {
        //                    print("Your location is \(location)")
        //                } else {
        //                    print("Your location is unknown")
        //                }
        //            }
        //        }
        ZStack(alignment: .top) {
            // Карта с аннотациями
//                Map(initialPosition: startPosition) {
//                    ForEach(viewModel.locations) { location in
//                        Annotation(location.name, coordinate: location.coordinate) {
//                            Image(systemName: "star.circle")
//                                .resizable()
//                                .foregroundStyle(.red)
//                                .frame(width: 44, height: 44)
//                                .background(.white)
//                                .clipShape(.circle)
//                                .onTapGesture {
//                                    print("Long press")
//                                    viewModel.selectedPlace = location
//                                }
//                        }
//                    }
//                }
//                .onTapGesture { position in
//                    if let coordinate = proxy.convert(position, from: .local) {
//                        viewModel.addLocation(at: coordinate)
//                    }
//                }
//                .sheet(item: $viewModel.selectedPlace) { place in
//                    EditView(location: place) { newLocation in
//                        viewModel.update(location: newLocation)
//                    }
//                }
            Map(
                coordinateRegion: $viewModel.region,
                showsUserLocation: true,
                annotationItems: viewModel.events
            ) { event in
                MapAnnotation(coordinate: event.coords) {
                    EventMarker(event: event)
                        .onTapGesture {
                            selectedEvent = event
                        }
                }
            }
            .edgesIgnoringSafeArea(.all)
            
            // Верхняя панель поиска и кнопка центрирования
            VStack(spacing: 10) {
                topControls
                    .padding(.top, 50) // Отступ от верхнего края экрана
                
                CategoryScroll(
                    categories: viewModel.categories,
                    onCategorySelected: { selectedCategory in
                        viewModel.currentCategory = selectedCategory.category.slug
                    }
                )
                .padding(.top, 10)
            }
            .padding(.horizontal, 25)
            
            // Карточка выбранного события
            if let event = selectedEvent {
                eventCard(event: event)
            }
        }
        .task {
            await viewModel.fetchCategories()
            await viewModel.fetchEvents()
        }
    }
    
    // MARK: - Subviews
    
    // Верхняя панель с поиском и кнопкой
    private var topControls: some View {
        HStack {
            SearchBarForMap(searchText: $viewModel.searchText)
                .previewLayout(.sizeThatFits)
            
            Button(action: {
                centerOnUserLocation()
            }) {
                Rectangle()
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .frame(width: 51, height: 51)
                    .shadow(
                        color: Color(red: 0.83, green: 0.82, blue: 0.85).opacity(0.5),
                        radius: 30,
                        x: 0,
                        y: 40
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .inset(by: 0.5)
                            .stroke(Color(red: 0.93, green: 0.93, blue: 0.93), lineWidth: 1)
                    )
                    .overlay(
                        Image("myLoc")
                            .frame(width: 16, height: 16)
                    )
            }
            .padding(.leading, 8)
            .buttonStyle(.plain)
        }
    }
    
    // Карточка выбранного события
    private func eventCard(event: MapEventModel) -> some View {
        let coreDataEvent: ExploreModel = .init(model: event)
        
        return VStack {
            Spacer()
            SmallEventCard(
                image: event.image,
                date: event.date,
                title: event.title,
                place: event.place,
                showPlace: true,
                showBookmark: true
            ) {
                if !isFavorite {
                    coreDataManager.createEvent(event: coreDataEvent)
                } else {
                    coreDataManager.deleteEvent(eventID: coreDataEvent.id)
                }
            }
            .padding(33)
            .onTapGesture {
                selectedEvent = nil
            }
        }
    }
    
    // MARK: - Helpers
    private func centerOnUserLocation() {
        if let location = viewModel.locationManager.location {
            viewModel.region = MKCoordinateRegion(
                center: location,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        }
    }
}

#Preview {
    MapScreen()
}
