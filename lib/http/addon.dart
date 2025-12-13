class HttpAddon {
  bool request = true;
  Future<String> method(String methodData) async {
    return methodData;
  }

  Future<Uri> uri(Uri uriData) async {
    return uriData;
  }

  Future<Object?> body(Object? bodyData) async {
    return bodyData;
  }

  Future<Map<String, String>> headers(Map<String, String> headersData) async {
    return headersData;
  }

  Future<int?> responseCode(int? codeData) async {
    return codeData;
  }

  Future<Map<String, String>?> responseHeaders(
    Map<String, String>? headersData,
  ) async {
    return headersData;
  }

  Future<List<int>> responseChunks(List<int> chunksData) async {
    return chunksData;
  }
}
