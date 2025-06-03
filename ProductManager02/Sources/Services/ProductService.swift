import Foundation

class ProductService {
    let baseURL = "http://localhost:3000/api"
    
    func fetchProducts() async throws -> [Product] {
        guard let url = URL(string: "\(baseURL)/products") else {
            throw URLError(.badURL)
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        let products = try JSONDecoder().decode([Product].self, from: data)
        return products
    }
    
    func createProduct(_ product: Product) async throws -> Product {
        guard let url = URL(string: "\(baseURL)/products") else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(product)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 201 else {
            throw URLError(.badServerResponse)
        }
        let newProduct = try JSONDecoder().decode(Product.self, from: data)
        return newProduct
    }
    
    func updateProduct(_ product: Product) async throws -> Product {
        guard let url = URL(string: "\(baseURL)/products/\(product.id)") else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(product)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        let updatedProduct = try JSONDecoder().decode(Product.self, from: data)
        return updatedProduct
    }
    
    func deleteProduct(id: String) async throws {
        guard let url = URL(string: "\(baseURL)/products/\(id)") else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let (_, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 204 else {
            throw URLError(.badServerResponse)
        }
    }
}
