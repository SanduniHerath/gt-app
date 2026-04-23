import SwiftUI

struct AddPlantView: View {
    @StateObject private var viewModel = AddPlantViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.gtBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                    .padding(.top, GTSpacing.sm)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: GTSpacing.lg) {
                        // Photo Picker Region
                        photoPickerBox
                        
                        // Form Fields
                        VStack(spacing: GTSpacing.md) {
                            GTTextField(
                                label: "Plant name",
                                placeholder: "Rose Bush",
                                text: $viewModel.name
                            )
                            
                            GTTextField(
                                label: "Plant species",
                                placeholder: "e.g. Rosa hybrida",
                                text: $viewModel.species
                            )
                            
                            HStack(spacing: GTSpacing.md) {
                                GTPickerField(
                                    label: "Location",
                                    placeholder: "Select location",
                                    selection: $viewModel.location,
                                    options: viewModel.locationOptions,
                                    formatter: { $0 }
                                )
                                
                                GTPickerField(
                                    label: "Pot / Ground",
                                    placeholder: "Select type",
                                    selection: $viewModel.potType,
                                    options: viewModel.potTypeOptions,
                                    formatter: { $0 }
                                )
                            }
                            
                            // Date Planted
                            datePlantedField
                            
                            // Tags
                            tagsSection
                            
                            // Notes
                            GTTextArea(
                                label: "Notes (optional)",
                                placeholder: "Any initial observation about the plant...",
                                text: $viewModel.notes
                            )
                        }
                        
                        // Action Buttons
                        VStack(spacing: GTSpacing.sm) {
                            GTButton(
                                title: "Continue to care setup",
                                trailingIcon: "arrow.right",
                                style: .primary,
                                action: {
                                    viewModel.savePlant()
                                }
                            )
                            
                            GTButton(
                                title: "Cancel",
                                style: .secondary,
                                action: {
                                    dismiss()
                                }
                            )
                            .background(
                                RoundedRectangle(cornerRadius: GTRadius.xl)
                                    .stroke(Color.gtBorder, lineWidth: 1)
                            )
                        }
                        .padding(.top, GTSpacing.md)
                    }
                    .padding(.horizontal, GTSpacing.lg)
                    .padding(.vertical, GTSpacing.md)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.onSave = { dismiss() }
            viewModel.onCancel = { dismiss() }
        }
    }
    
    // MARK: - Subviews
    
    private var headerView: some View {
        HStack(spacing: GTSpacing.md) {
            Button {
                dismiss()
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 44, height: 44)
                        .gtShadow(GTShadow.card)
                    Image(systemName: "arrow.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.gtTextPrimary)
                }
            }
            .padding(.leading, GTSpacing.md)
            
            Text("Add New Plant")
                .font(GTFont.displaySmall())
                .foregroundColor(.gtTextPrimary)
            
            Spacer()
        }
        .padding(.vertical, GTSpacing.sm)
    }
    
    private var photoPickerBox: some View {
        Button {
            // Action to pick photo
        } label: {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .frame(width: 40, height: 40)
                    Image(systemName: "photo")
                        .foregroundColor(.gtDarkGreen)
                        .font(.system(size: 20))
                }
                
                VStack(spacing: 2) {
                    Text("Add a photo of your plant")
                        .font(GTFont.labelMedium())
                        .foregroundColor(.gtTextPrimary)
                    Text("Choose a photo from library")
                        .font(GTFont.bodySmall())
                        .foregroundColor(.gtTextSecondary)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 140)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: GTRadius.lg)
                        .fill(Color.gtPaleGreen.opacity(0.4))
                    
                    RoundedRectangle(cornerRadius: GTRadius.lg)
                        .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                        .foregroundColor(.gtMidGreen)
                }
            )
        }
    }
    
    private var datePlantedField: some View {
        VStack(alignment: .leading, spacing: GTSpacing.xxs) {
            Text("Date Planted")
                .font(GTFont.labelMedium())
                .foregroundColor(.gtTextSecondary)
            
            HStack {
                DatePicker(
                    "",
                    selection: $viewModel.datePlanted,
                    displayedComponents: .date
                )
                .labelsHidden()
                
                Spacer()
                
                Image(systemName: "calendar")
                    .foregroundColor(.gtTextSecondary)
            }
            .padding(.horizontal, GTSpacing.md)
            .padding(.vertical, GTSpacing.sm)
            .background(
                RoundedRectangle(cornerRadius: GTRadius.sm)
                    .fill(Color.gtPaleGreen.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: GTRadius.sm)
                            .stroke(Color.gtBorder, lineWidth: 1)
                    )
            )
        }
    }
    
    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: GTSpacing.xxs) {
            Text("Tags")
                .font(GTFont.labelMedium())
                .foregroundColor(.gtTextSecondary)
            
            FlowLayout(spacing: 8) {
                ForEach(viewModel.tags, id: \.self) { tag in
                    tagChip(tag)
                }
                
                addTagButton
            }
        }
    }
    
    private func tagChip(_ tag: String) -> some View {
        HStack(spacing: 4) {
            Text(tag)
                .font(GTFont.labelSmall())
            
            Button {
                viewModel.removeTag(tag)
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 8, weight: .bold))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .foregroundColor(.gtDarkGreen)
        .background(
            Capsule()
                .fill(chipColor(for: tag))
                .overlay(
                    Capsule()
                        .stroke(Color.gtBorder, lineWidth: 1)
                )
        )
    }
    
    private func chipColor(for tag: String) -> Color {
        switch tag {
        case "Flowering": return Color.gtPaleGreen
        case "Outdoor": return Color.gtMidGreen.opacity(0.2)
        case "Fragrant": return Color.gtTextMuted.opacity(0.2)
        default: return Color.gtPaleGreen
        }
    }
    
    private var addTagButton: some View {
        Button {
            viewModel.addTag()
        } label: {
            HStack(spacing: 4) {
                Text("+ Add tag")
                    .font(GTFont.labelSmall())
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .foregroundColor(.gtTextSecondary)
            .background(
                Capsule()
                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [4]))
                    .foregroundColor(.gtTextMuted)
            )
        }
    }
}

// FlowLayout is now moved to GTMiscComponents.swift

#Preview {
    AddPlantView()
}
