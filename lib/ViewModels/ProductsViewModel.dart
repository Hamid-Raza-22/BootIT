import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../Databases/util.dart';
import '../Models/ScreenModels/products_model.dart';
import '../Repositories/ScreenRepositories/products_repository.dart';

class ProductsViewModel extends GetxController {
  var allProducts = <ProductsModel>[].obs;

  ProductsRepository productsRepository = Get.put(ProductsRepository());

  @override
  void onInit() {
    super.onInit();
    // fetchAndSaveProducts();
    fetchAllProductsModel();
  }

  fetchAllProductsModel() async {
    var products = await productsRepository.getProductsModel();
    allProducts.value = products;
  }

  addProductAll(ProductsModel productsModel) {
    productsRepository.add(productsModel);
    fetchAllProductsModel();
  }

  updateProductAll(ProductsModel productsModel) {
    productsRepository.update(productsModel);
    fetchAllProductsModel();
  }

  deleteProductsAll(int id) {
    productsRepository.delete(id);
    fetchAllProductsModel();
  }

  fetchAndSaveProducts() async {
    await productsRepository.fetchAndSaveProducts();
    fetchAllProductsModel();
  }

  Future<void> fetchProductsByBrands(String brand) async {
    try {
      String brand = userBrand;
      // Fetch products by brand from the repository
      List<ProductsModel> products =
          await productsRepository.getProductsByBrand(brand);

      // Set the products in the allProducts list
      allProducts.value = products;
    } catch (e) {

        debugPrint("Error fetching products by brand: $e");

    }
  }
}
