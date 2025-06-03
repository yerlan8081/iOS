import SwiftUI

struct ProductDetailView: View {
    @ObservedObject var viewModel: ProductViewModel
    @State var product: Product
    @Environment(\.presentationMode) var presentationMode
    
    @State private var errorMessage: String? = nil
    @State private var priceText: String
    
    init(viewModel: ProductViewModel, product: Product) {
        self.viewModel = viewModel
        self._product = State(initialValue: product)
        self._priceText = State(initialValue: String(product.price))
    }
    
    var body: some View {
        Form {
            Section(header: Text("商品信息")) {
                TextField("名称", text: $product.name)
                TextField("描述", text: $product.description)
                TextField("价格", text: $priceText)
                    .keyboardType(.decimalPad)
            }
            
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            Button("保存") {
                if validateInput() {
                    if let price = Double(priceText) {
                        product.price = price
                    }
                    Task {
                        await viewModel.updateProduct(product)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .disabled(product.name.isEmpty || priceText.isEmpty)
        }
        .navigationTitle("编辑商品")
    }
    
    private func validateInput() -> Bool {
        errorMessage = nil
        
        if product.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "名称不能为空"
            return false
        }
        
        if let price = Double(priceText) {
            if price < 0 {
                errorMessage = "价格不能为负数"
                return false
            }
        } else {
            errorMessage = "价格格式不正确"
            return false
        }
        
        return true
    }
}
