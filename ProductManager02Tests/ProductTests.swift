import XCTest
@testable import ProductManager02  // 替换成你的模块名

// 模拟服务，方便测试网络请求
class MockProductService: ProductService {
    var shouldReturnError = false
    var productsToReturn: [Product] = []
    
    override func fetchProducts() async throws -> [Product] {
        if shouldReturnError {
            throw URLError(.badServerResponse)
        }
        return productsToReturn
    }
    
    override func createProduct(_ product: Product) async throws -> Product {
        if shouldReturnError {
            throw URLError(.badServerResponse)
        }
        // 模拟添加成功，直接返回商品
        productsToReturn.append(product)
        return product
    }
    
    override func deleteProduct(id: String) async throws {
        if shouldReturnError {
            throw URLError(.badServerResponse)
        }
        if let index = productsToReturn.firstIndex(where: { $0.id == id }) {
            productsToReturn.remove(at: index)
        } else {
            throw URLError(.fileDoesNotExist)
        }
    }
}

@MainActor
class ProductTests: XCTestCase {
    
    var viewModel: ProductViewModel!
    var mockService: MockProductService!
    
    override func setUp() {
        super.setUp()
        mockService = MockProductService()
        viewModel = ProductViewModel()
        viewModel.service = mockService  // 记得修改 service 访问权限为 internal 或用 init 注入
    }
    
    override func tearDown() {
        viewModel = nil
        mockService = nil
        super.tearDown()
    }
    
    // 测试 1: 添加商品
    func testAddProduct() async {
        let newProduct = Product(id: "1", name: "新商品", description: "描述", price: 9.9, createdAt: Date())
        mockService.shouldReturnError = false
        mockService.productsToReturn = []
        
        await viewModel.addProduct(newProduct)
        
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.products.count, 1)
        XCTAssertEqual(viewModel.products.first?.id, "1")
    }
    
    // 测试 2: 获取商品列表
    func testFetchProducts() async {
        let product = Product(id: "2", name: "测试商品", description: "描述", price: 19.9, createdAt: Date())
        mockService.productsToReturn = [product]
        mockService.shouldReturnError = false
        
        await viewModel.loadProducts()
        
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.products.count, 1)
        XCTAssertEqual(viewModel.products.first?.id, "2")
    }
    
    // 测试 3: 删除商品
    func testDeleteProduct() async {
        let product1 = Product(id: "3", name: "商品1", description: "描述1", price: 10.0, createdAt: Date())
        let product2 = Product(id: "4", name: "商品2", description: "描述2", price: 20.0, createdAt: Date())
        mockService.productsToReturn = [product1, product2]
        mockService.shouldReturnError = false
        
        // 先加载
        await viewModel.loadProducts()
        XCTAssertEqual(viewModel.products.count, 2)
        
        // 删除第一个商品
        await viewModel.deleteProduct(at: IndexSet(integer: 0))
        
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.products.count, 1)
        XCTAssertEqual(viewModel.products.first?.id, "4")
    }
}
