import SwiftUI

struct AddObservationView: View {
    @StateObject var viewModel: AddObservationViewModel
    @Environment(\.dismiss) var dismiss

    init(plant: PlantModel? = nil) {
        _viewModel = StateObject(wrappedValue: AddObservationViewModel(plant: plant))
    }

    var body: some View {
        ZStack {
            Color.gtBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - Header
                headerView
                    .padding(.top, GTSpacing.sm)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: GTSpacing.lg) {
                        // MARK: - Form Fields
                        VStack(spacing: GTSpacing.md) {
                            GTPickerField(
                                label: "Plant",
                                placeholder: "Select plant",
                                selection: $viewModel.selectedPlant,
                                options: viewModel.plantOptions,
                                formatter: { $0 }
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
                                    selection: $viewModel.potGroundType,
                                    options: viewModel.typeOptions,
                                    formatter: { $0 }
                                )
                            }
                            
                            // MARK: - Tags
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
                            
                            // MARK: - Observation
                            GTTextArea(
                                label: "Observation",
                                placeholder: "Any observation about the plant...",
                                text: $viewModel.observationNote
                            )
                        }
                        
                        // MARK: - Action Buttons
                        VStack(spacing: GTSpacing.sm) {
                            GTButton(
                                title: "Add Observation",
                                trailingIcon: "arrow.right",
                                style: .primary,
                                action: {
                                    viewModel.saveObservation()
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
            
            Text("Add New Observation")
                .font(GTFont.displaySmall())
                .foregroundColor(.gtTextPrimary)
            
            Spacer()
        }
        .padding(.vertical, GTSpacing.sm)
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
                .fill(tag == "Fragrant" ? Color(white: 0.8) : Color.gtPaleGreen)
                .overlay(
                    Capsule()
                        .stroke(Color.gtBorder, lineWidth: 1)
                )
        )
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

// Simple FlowLayout for Tags

#Preview {
    AddObservationView(plant: PlantModel.samples[1])
}
