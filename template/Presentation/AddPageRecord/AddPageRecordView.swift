import SwiftUI

struct AddPageRecordView: View {
    @Bindable var viewModel: AddPageRecordViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var page = 0
    var body: some View {
        VStack {
            TabView(selection: $page) {
                VStack { 
                DatePicker("Date", selection: $viewModel.selectedDate, in: ...Date(), displayedComponents: .date)
                    .datePickerStyle(.graphical).tint(.inkNavy).inkCard().padding(.horizontal, 16)
; Spacer() }.tag(0)
                VStack(spacing: 20) {
                    TextField("0", text: $viewModel.pageCountText).font(InkTypography.largeNumber())
                        .keyboardType(.numberPad).multilineTextAlignment(.center).inkCard().padding(16)
                    Spacer()
                }.tag(1)
                VStack { 
                if let message = viewModel.validationMessage {
                    ValidationMessageView(message: message, isError: viewModel.isValidationError).padding(.horizontal, 16)
                }
                Button("Save") { Task { await viewModel.save() } }
                    .buttonStyle(PrimaryButtonStyle()).disabled(!viewModel.canSave).padding(.horizontal, 16)
                if viewModel.isEditing {
                    Button("Delete Record") { viewModel.showDeleteConfirmation = true }
                        .buttonStyle(DestructiveButtonStyle()).padding(.horizontal, 16)
                }
; Spacer() }.tag(2)
            }.tabViewStyle(.page(indexDisplayMode: .always))
            HStack {
                if page > 0 { Button("Back") { page -= 1 } }
                Spacer()
                if page < 2 { Button("Next") { page += 1 }.buttonStyle(CompactButtonStyle()) }
            }.padding(16)
        }

        .background(Color.dynamicBackground.ignoresSafeArea())
        .navigationTitle(viewModel.isEditing ? "Edit Record" : "Log Pages")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.onDateChanged() }
        .onChange(of: viewModel.selectedDate) { _, _ in Task { await viewModel.onDateChanged() } }
        .onChange(of: viewModel.pageCountText) { _, _ in viewModel.validate() }
        .onChange(of: viewModel.saveSucceeded) { _, ok in if ok { dismiss() } }
        .alert("Delete Record", isPresented: $viewModel.showDeleteConfirmation) {
            Button("Delete", role: .destructive) { Task { await viewModel.deleteRecord() } }
            Button("Cancel", role: .cancel) {}
        } message: { Text("Delete this record?") }
    }
}

