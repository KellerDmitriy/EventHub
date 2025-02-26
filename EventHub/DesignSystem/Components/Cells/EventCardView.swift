import SwiftUI
import Kingfisher

struct EventCardView: View {
    @EnvironmentObject private var coreDataManager: CoreDataManager
    let event: ExploreModel
    
    // MARK: - Properties
    private var isFavorite: Bool {
        coreDataManager.events.contains { Int($0.id) == event.id }
    }

    // MARK: - Body
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack(alignment: .leading) {
                ZStack(alignment: .top) {
                    eventImageView
                    favoriteButton
                    eventDateView
                }
                .padding(.top, Drawing.topPadding)
                
                eventTitleView
                visitorsView
                addressView
            }
            .padding([.top, .horizontal, .bottom], Drawing.contentPadding)
        }
        .frame(width: Drawing.cardWidth, height: Drawing.cardHeight)
        .clipShape(RoundedRectangle(cornerRadius: Drawing.cardCornerRadius))
        .shadow(color: .gray.opacity(Drawing.shadowOpacity), radius: Drawing.shadowRadius, x: 0, y: Drawing.shadowYOffset)
    }

    // MARK: - Views
    private var eventImageView: some View {
        Group {
            if let imageUrl = event.image, let url = URL(string: imageUrl) {
                KFImage(url)
                    .placeholder { ShimmeringImageView() }
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: Drawing.imageWidth, height: Drawing.imageHeight)
                    .clipShape(RoundedRectangle(cornerRadius: Drawing.imageCornerRadius))
                    .clipped()
            } else {
                Image(.cardImg1)
                    .resizable()
                    .frame(width: Drawing.imageWidth, height: Drawing.imageHeight)
                    .clipShape(RoundedRectangle(cornerRadius: Drawing.imageCornerRadius))
            }
        }
    }
    
    private var favoriteButton: some View {
        Button {
            isFavorite ? coreDataManager.deleteEvent(eventID: event.id) : coreDataManager.createEvent(event: event)
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: Drawing.favoriteButtonCornerRadius)
                    .frame(width: Drawing.favoriteButtonSize, height: Drawing.favoriteButtonSize)
                    .foregroundStyle(.appOrangeSecondary)
                    .opacity(Drawing.buttonOpacity)
                Image(isFavorite ? .bookmarkFill : .bookmarkOverlay)
                    .resizable()
                    .frame(width: Drawing.bookmarkIconSize, height: Drawing.bookmarkIconSize)
                    .foregroundStyle(.appRed)
            }
        }
        .padding(.top, Drawing.topPadding)
        .offset(x: Drawing.favoriteButtonOffsetX)
    }
    
    private var eventDateView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Drawing.dateViewCornerRadius)
                .frame(width: Drawing.dateViewSize, height: Drawing.dateViewSize)
                .foregroundStyle(.appOrangeSecondary)
                .opacity(Drawing.buttonOpacity)
            Text(event.date.formattedDate(format: "dd\nMMM"))
                .foregroundStyle(.appDateText)
                .airbnbCerealFont(AirbnbCerealFont.book, size: 18)
                .multilineTextAlignment(.center)
        }
        .padding(.top, Drawing.topPadding)
        .offset(x: Drawing.dateViewOffsetX)
    }
    
    private var eventTitleView: some View {
        Text(event.title.localized)
            .airbnbCerealFont(AirbnbCerealFont.medium, size: 18)
            .frame(width: Drawing.titleWidth, height: Drawing.titleHeight, alignment: .leading)
            .padding(.bottom, Drawing.titleBottomPadding)
            .foregroundStyle(Color.appForegroundStyle)
    }
    
    private var visitorsView: some View {
        Group {
            if let visitors = event.visitors, visitors.isEmpty {
                HStack {
                    ShimmerAvatarView()
                    Text("No visitors".localized)
                        .airbnbCerealFont(AirbnbCerealFont.book, size: 12)
                }
            } else if let visitors = event.visitors {
                HStack {
                    visitorsAvatarsView(visitors)
                    visitorsCountButton(visitors)
                }
            }
        }
    }
    
    private func visitorsAvatarsView(_ visitors: [Visitor]) -> some View {
        ZStack {
            ForEach(visitors.prefix(3).indices, id: \.self) { index in
                let visitor = visitors[index]
                let url = URL(string: visitor.image ?? "")
                
                KFImage(url)
                    .placeholder { ShimmerAvatarView() }
                    .resizable()
                    .frame(width: Drawing.avatarSize, height: Drawing.avatarSize)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(style: StrokeStyle(lineWidth: 1)).foregroundStyle(Color.white))
                    .offset(x: getOffset(index: index, visitorsCount: visitors.count))
            }
        }
    }
    
    private func visitorsCountButton(_ visitors: [Visitor]) -> some View {
        Button {
            print(visitors)
        } label: {
            HStack(spacing: 1) {
                Text(visitors.count > 3 ? "+" : "")
                    .airbnbCerealFont(AirbnbCerealFont.book, size: 12)
                Text("\(max(0, visitors.count - 3))")
                    .airbnbCerealFont(AirbnbCerealFont.book, size: 12)
                Text(visitors.count > 0 ? " " + "Going".localized : "")
                    .airbnbCerealFont(AirbnbCerealFont.book, size: 12)
            }
        }
        .padding(.leading, Drawing.visitorsButtonPadding)
    }
    
    private var addressView: some View {
        Button {
            // Show map
        } label: {
            HStack {
                Image(.mapPin)
                    .resizable()
                    .foregroundStyle(.geolocationText)
                    .frame(width: Drawing.mapPinSize, height: Drawing.mapPinSize)
                Text(event.address?.localized ?? "Адрес не доступен")
                    .airbnbCerealFont(AirbnbCerealFont.book, size: 13)
                    .foregroundStyle(.geolocationText)
            }
            .frame(width: Drawing.addressWidth, height: Drawing.addressHeight, alignment: .leading)
        }
    }

    // MARK: - Helpers
    private func getOffset(index: Int, visitorsCount: Int) -> CGFloat {
        let ratio: CGFloat = Drawing.avatarOffsetRatio
        return visitorsCount > 1 ? CGFloat(index) * -ratio : 0
    }
}

// MARK: - Drawing Constants
private enum Drawing {
    static let topPadding: CGFloat = 10
    static let contentPadding: CGFloat = 15
    
    static let cardWidth: CGFloat = 237
    static let cardHeight: CGFloat = 255
    static let cardCornerRadius: CGFloat = 18
    static let shadowOpacity: CGFloat = 0.2
    static let shadowRadius: CGFloat = 5
    static let shadowYOffset: CGFloat = 2
    
    static let imageWidth: CGFloat = 218
    static let imageHeight: CGFloat = 131
    static let imageCornerRadius: CGFloat = 10
    
    static let favoriteButtonSize: CGFloat = 30
    static let favoriteButtonCornerRadius: CGFloat = 7
    static let favoriteButtonOffsetX: CGFloat = 85
    static let bookmarkIconSize: CGFloat = 14
    static let buttonOpacity: CGFloat = 0.7
    
    static let dateViewSize: CGFloat = 45
    static let dateViewCornerRadius: CGFloat = 10
    static let dateViewOffsetX: CGFloat = -77
    
    static let titleWidth: CGFloat = 207
    static let titleHeight: CGFloat = 21
    static let titleBottomPadding: CGFloat = 10
    
    static let avatarSize: CGFloat = 24
    static let avatarOffsetRatio: CGFloat = 15
    static let visitorsButtonPadding: CGFloat = 25
    
    static let mapPinSize: CGFloat = 16
    static let addressWidth: CGFloat = 185
    static let addressHeight: CGFloat = 17
}

#Preview {
    EventCardView(event: ExploreModel.example)
        .environmentObject(CoreDataManager())
}
