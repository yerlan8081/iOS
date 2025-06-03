import SwiftUI

struct ProductEditView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: ProductViewModel
    
    @State private var name = ""
    @State private var description = ""
    @State private var price: Double = 0.0
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("新增商品")) {
                    TextField("名称", text: $name)
                    TextField("描述", text: $description)
                    TextField("价格", value: $price, formatter: NumberFormatter())
                        .keyboardType(.decimalPad)
                }
                
                Button("保存") {
                    let newProduct = Product(id: UUID().uuidString,
                                             name: name,
                                             description: description,
                                             price: price,
                                             createdAt: Date())
                    Task {
                        await viewModel.addProduct(newProduct)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .navigationTitle("新增商品")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}
