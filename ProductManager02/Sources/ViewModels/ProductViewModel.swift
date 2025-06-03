import Foundation

@MainActor
class ProductViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
//    private let service = ProductService()
    
    var service: ProductService
       
       init(service: ProductService = ProductService()) {
           self.service = service
       }
    
    
    func loadProducts() async {
        isLoading = true
        errorMessage = nil
        do {
            products = try await service.fetchProducts()
        } catch {
            errorMessage = "加载商品失败: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    func addProduct(_ product: Product) async {
        isLoading = true
        errorMessage = nil
        do {
            let newProduct = try await service.createProduct(product)
            products.append(newProduct)
        } catch {
            errorMessage = "添加商品失败: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    func updateProduct(_ product: Product) async {
        isLoading = true
        errorMessage = nil
        do {
            let updated = try await service.updateProduct(product)
            if let index = products.firstIndex(where: { $0.id == updated.id }) {
                products[index] = updated
            }
        } catch {
            errorMessage = "更新商品失败: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    func deleteProduct(at offsets: IndexSet) async {
        isLoading = true
        errorMessage = nil
        for index in offsets {
            let product = products[index]
            do {
                try await service.deleteProduct(id: product.id)
                products.remove(at: index)
            } catch {
                errorMessage = "删除商品失败: \(error.localizedDescription)"
            }
        }
        isLoading = false
    }
}
