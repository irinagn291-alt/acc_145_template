import SwiftUI

struct ShelfSettingsView: View {
    @Bindable var viewModel: ShelfSettingsViewModel
    private let dateFormatter: DateFormatter = { let f = DateFormatter(); f.dateStyle = .medium; return f }()

    private var currentCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "books.vertical.fill").foregroundColor(.inkGold)
                Text("Current Shelves").font(InkTypography.header())
                Spacer()
            }
            Text(viewModel.currentShelf.map { "\($0) shelves" } ?? "Not set")
                .font(InkTypography.largeNumber()).foregroundColor(.inkNavy)
        }.inkCard().padding(.horizontal, 16)
    }

    private var saveForm: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Update Shelves")
                .font(InkTypography.header())
                .foregroundColor(Color.dynamicText)
            VStack(alignment: .leading, spacing: 8) {
                Text("Number of Shelves")
                    .font(InkTypography.caption())
                    .foregroundColor(Color.dynamicSecondaryText)
                TextField("Enter shelves count", text: $viewModel.newShelfCount)
                    .keyboardType(.numberPad)
                    .font(InkTypography.body())
                    .padding(12)
                    .background(Color.dynamicBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            VStack(alignment: .leading, spacing: 8) {
                Text("Effective Date")
                    .font(InkTypography.caption())
                    .foregroundColor(Color.dynamicSecondaryText)
                DatePicker("Effective Date", selection: $viewModel.newEffectiveDate, displayedComponents: .date)
                    .labelsHidden()
                    .tint(.inkNavy)
            }
            Text("Records when your shelves count changed. Analytics after this date use the new value.")
                .font(InkTypography.smallLabel())
                .foregroundColor(Color.dynamicSecondaryText)
            if let error = viewModel.errorMessage { ValidationMessageView(message: error, isError: true) }
            Button("Save Shelf Setup") { Task { await viewModel.save() } }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(!viewModel.canSave)
        }.inkCard().padding(.horizontal, 16)
    }
    private var historyBlock: some View {
        VStack(spacing: 8) {
            SectionHeaderView(title: "Shelves History")
            if viewModel.capacityHistory.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "books.vertical.fill")
                        .font(.system(size: 36))
                        .foregroundColor(.inkNavy.opacity(0.5))
                    Text("No shelves records yet")
                        .font(InkTypography.caption())
                        .foregroundColor(Color.dynamicSecondaryText)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .inkCard()
            } else {
                ForEach(viewModel.capacityHistory) { record in
                    ShelfRecordHistoryRowView(effectiveDate: dateFormatter.string(from: record.effectiveDate), shelfCount: record.shelfCount)
                        .inkListRow()
                        .contextMenu { Button(role: .destructive) { viewModel.confirmDelete(record) } label: { Label("Delete", systemImage: "trash") } }
                }
            }
        }
        .padding(.horizontal, 16)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                currentCard
                VStack(alignment: .leading, spacing: 12) {
                    Text("Choose Shelves count")
                        .font(InkTypography.header())
                    Picker("Count", selection: Binding(
                        get: { Int(viewModel.newShelfCount) ?? 1 },
                        set: { viewModel.newShelfCount = String($0) }
                    )) {
                        ForEach(1...30, id: \.self) { Text("\($0) shelves").tag($0) }
                    }.pickerStyle(.menu)
                }.inkCard().padding(.horizontal, 16)
                saveForm
                historyBlock
            }.padding(.vertical, 16)
        }

        .background(Color.dynamicBackground.ignoresSafeArea())
        .navigationTitle("Shelf Setup")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.loadData() }
        .alert("Delete Shelves Record", isPresented: $viewModel.showDeleteAlert) {
            Button("Delete", role: .destructive) { Task { await viewModel.deleteRecord() } }
            Button("Cancel", role: .cancel) {}
        } message: { Text("Delete this shelves record?") }
        .alert("Cannot Delete", isPresented: $viewModel.showDeleteError) {
            Button("OK", role: .cancel) {}
        } message: { Text(viewModel.deleteErrorMessage ?? "An error occurred") }
    }
}
