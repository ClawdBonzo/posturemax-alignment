import SwiftUI
import SwiftData

struct PhotoJournalView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PosturePhoto.dateTaken, order: .reverse) private var photos: [PosturePhoto]
    @State private var selectedPhoto: PosturePhoto?
    @State private var timelinePosition: Double = 1.0
    @State private var compareMode = false
    @State private var comparePhoto1: PosturePhoto?
    @State private var comparePhoto2: PosturePhoto?

    private var isPro: Bool { PurchaseManager.shared.isPro }

    private var filteredPhotos: [PosturePhoto] {
        guard !photos.isEmpty else { return [] }
        let count = photos.count
        let endIndex = max(1, Int(Double(count) * timelinePosition))
        return Array(photos.prefix(endIndex))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if photos.isEmpty {
                    emptyState
                } else {
                    if compareMode {
                        compareView
                    } else {
                        galleryView
                    }

                    // Timeline slider
                    if photos.count > 1 {
                        timelineSlider
                    }
                }
            }
            .navigationTitle("Photo Journal")
            .toolbar {
                if photos.count >= 2 {
                    ToolbarItem(placement: .primaryAction) {
                        Button(compareMode ? "Gallery" : "Compare") {
                            compareMode.toggle()
                            if compareMode {
                                comparePhoto1 = photos.last
                                comparePhoto2 = photos.first
                            }
                        }
                    }
                }
            }
            .sheet(item: $selectedPhoto) { photo in
                PhotoDetailView(photo: photo)
            }
            .proGated(feature: "Photo Tracking", icon: "camera.fill", isPro: isPro)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "photo.stack")
                .font(.system(size: 60))
                .foregroundStyle(Color.pmPrimary.opacity(0.4))
            Text("No Photos Yet")
                .font(.title3.weight(.semibold))
            Text("Add photos through your daily log\nto track your posture transformation")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Spacer()
        }
    }

    private var galleryView: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 4),
                GridItem(.flexible(), spacing: 4),
                GridItem(.flexible(), spacing: 4)
            ], spacing: 4) {
                ForEach(filteredPhotos) { photo in
                    if let image = UIImage(data: photo.imageData) {
                        Button {
                            selectedPhoto = photo
                        } label: {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(minHeight: 120)
                                .clipped()
                                .overlay(alignment: .bottomLeading) {
                                    Text(photo.dateTaken.shortFormatted)
                                        .font(.system(size: 9, weight: .medium))
                                        .padding(4)
                                        .background(.ultraThinMaterial)
                                        .clipShape(Capsule())
                                        .padding(4)
                                }
                        }
                    }
                }
            }
        }
    }

    private var compareView: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                ComparePhotoSlot(
                    photo: comparePhoto1,
                    label: "Before",
                    allPhotos: photos
                ) { photo in
                    comparePhoto1 = photo
                }

                ComparePhotoSlot(
                    photo: comparePhoto2,
                    label: "After",
                    allPhotos: photos
                ) { photo in
                    comparePhoto2 = photo
                }
            }
            .padding(.horizontal)

            if let p1 = comparePhoto1, let p2 = comparePhoto2 {
                let daysBetween = Calendar.current.dateComponents([.day], from: p1.dateTaken, to: p2.dateTaken).day ?? 0
                Text("\(abs(daysBetween)) days between photos")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.top)
    }

    private var timelineSlider: some View {
        VStack(spacing: 4) {
            HStack {
                if let oldest = photos.last {
                    Text(oldest.dateTaken.shortFormatted)
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text("Now")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }

            Slider(value: $timelinePosition, in: 0.1...1.0)
                .tint(Color.pmPrimary)

            Text("\(filteredPhotos.count) of \(photos.count) photos")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.pmCardBackground)
    }
}

struct ComparePhotoSlot: View {
    let photo: PosturePhoto?
    let label: String
    let allPhotos: [PosturePhoto]
    let onSelect: (PosturePhoto) -> Void

    @State private var showPicker = false

    var body: some View {
        VStack(spacing: 8) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            if let photo, let image = UIImage(data: photo.imageData) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 280)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .onTapGesture { showPicker = true }

                Text(photo.dateTaken.mediumFormatted)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.pmCardBackground)
                    .frame(height: 280)
                    .overlay {
                        Image(systemName: "photo")
                            .font(.title)
                            .foregroundStyle(.secondary)
                    }
                    .onTapGesture { showPicker = true }
            }
        }
        .sheet(isPresented: $showPicker) {
            PhotoPickerSheet(photos: allPhotos, onSelect: onSelect)
        }
    }
}

struct PhotoPickerSheet: View {
    let photos: [PosturePhoto]
    let onSelect: (PosturePhoto) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 4) {
                    ForEach(photos) { photo in
                        if let image = UIImage(data: photo.imageData) {
                            Button {
                                onSelect(photo)
                                dismiss()
                            } label: {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(minHeight: 100)
                                    .clipped()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Photo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

struct PhotoDetailView: View {
    let photo: PosturePhoto
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack {
                if let image = UIImage(data: photo.imageData) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding()
                }

                VStack(spacing: 8) {
                    Text(photo.dateTaken.mediumFormatted)
                        .font(.headline)
                    Text(photo.category.capitalized)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    if !photo.notes.isEmpty {
                        Text(photo.notes)
                            .font(.body)
                            .padding(.top, 4)
                    }
                }
                .padding()

                Spacer()
            }
            .navigationTitle("Photo Detail")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
