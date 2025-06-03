import SwiftUI

struct ProductListView: View {
    @StateObject var viewModel = ProductViewModel()
    @State private var showAddSheet = false
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView("加载中...")
                } else if let error = viewModel.errorMessage {
                    Text(error).foregroundColor(.red)
                } else if viewModel.products.isEmpty {
                    Text("没有商品数据")
                } else {
                    List {
                        ForEach(viewModel.products) { product in
                            NavigationLink(destination: ProductDetailView(viewModel: viewModel, product: product)) {
                                VStack(alignment: .leading) {
                                    Text(product.name).font(.headline)
                                    Text("$\(product.price, specifier: "%.2f")").font(.subheadline)
                                    Text(product.description.isEmpty ? "无描述" : product.description)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .onDelete { offsets in
                            Task {
                                await viewModel.deleteProduct(at: offsets)
                            }
                        }
                    }
                }
            }
            .navigationTitle("商品管理")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button(action: {
                            Task {
                                await viewModel.loadProducts()
                            }
                        }) {
                            Image(systemName: "arrow.clockwise")
                        }
                        Button(action: { showAddSheet = true }) {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .task {
                await viewModel.loadProducts()
            }
            .sheet(isPresented: $showAddSheet) {
                ProductEditView(viewModel: viewModel)
            }
        }
    }
}
